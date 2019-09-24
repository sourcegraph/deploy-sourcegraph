package fresh

import (
	"crypto/tls"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	qt "github.com/frankban/quicktest"
	"github.com/otiai10/copy"
	"github.com/pulumi/pulumi/pkg/testing/integration"
	"github.com/sethgrid/pester"
)

func TestDeployments(t *testing.T) {

	type test struct {
		name             string
		previousVersions []string
	}

	for _, test := range []test{
		test{
			name:             "fresh deployment",
			previousVersions: nil,
		},
		test{
			name:             "previous version -> current commit upgrade",
			previousVersions: []string{"3.7.2"},
		},
		test{
			name:             "two previous versions -> current commit upgrade",
			previousVersions: []string{"3.6.3"},
		},
		test{
			name:             "two previous versions -> previous version -> current commit upgrade",
			previousVersions: []string{"3.6.3", "3.7.2"},
		},
	} {
		t.Run(test.name, func(t *testing.T) {
			testUpgradePath(t, test.previousVersions)
		})
	}
}

func testUpgradePath(t *testing.T, previousVersions []string) {
	c := qt.New(t)

	defer c.Done()

	if testing.Short() {
		c.Skip("skipping cluster integration test in short mode")
	}

	config, err := Config()
	if err != nil {
		c.Fatalf("unable to generate pulumi configuration, err: %s", err)
	}

	stepYamlDirs := []string{}

	for _, version := range previousVersions {
		oldYAMLDir, err := ioutil.TempDir("", fmt.Sprintf("deploy-sourcegraph-%s", version))
		if err != nil {
			c.Fatalf("unable to make temporary directoy for %q, err: %s", version, err)
		}
		c.Defer(func() { os.RemoveAll(oldYAMLDir) })

		err = prepareOldReleaseYAML(version, oldYAMLDir)
		if err != nil {
			c.Fatalf("failed to prepare yaml for version %q, err: %s", version, err)
		}

		stepYamlDirs = append(stepYamlDirs, oldYAMLDir)
	}

	currentYAMLDir, err := ioutil.TempDir("", fmt.Sprintf("deploy-sourcegraph-current-commit"))
	if err != nil {
		c.Fatalf("unable to make temporary directoy for current commit yaml,  err: %s", err)
	}
	c.Defer(func() { os.RemoveAll(currentYAMLDir) })

	err = prepareCurrentCommitYAML(currentYAMLDir)
	if err != nil {
		c.Fatalf("failed to prepare yaml for current commit err: %s", err)
	}

	stepYamlDirs = append(stepYamlDirs, currentYAMLDir)

	envVars := []string{}
	for i, dir := range stepYamlDirs {
		absPath, err := filepath.Abs(dir)
		if err != nil {
			c.Fatalf("failed to get absolute path, err: %s", err)
		}
		envVars = append(
			envVars,
			fmt.Sprintf("DEPLOY_SOURCEGRAPH_ROOT_STEP_%d=%s", i+1, absPath),
		)
	}

	editDirs := []integration.EditDir{}
	for i := range stepYamlDirs[1:] {
		editDirs = append(editDirs, integration.EditDir{
			Dir:                    fmt.Sprintf("step%d", i+1),
			Additive:               true,
			ExtraRuntimeValidation: ValidateFrontendIsReachable,
		})
	}

	integration.ProgramTest(t, &integration.ProgramTestOptions{
		Dir: "step1",

		Config:               config,
		ExpectRefreshChanges: true,
		Quick:                false,
		Verbose:              true,

		Env:      envVars,
		EditDirs: editDirs,

		ExtraRuntimeValidation: ValidateFrontendIsReachable,
	})
}

func Config() (map[string]string, error) {
	config := map[string]string{}

	for env, key := range map[string]string{
		"TEST_GCP_PROJECT":  "gcp:project",
		"TEST_GCP_ZONE":     "gcp:zone",
		"TEST_GCP_USERNAME": "gcpUsername",
		"BUILD_CREATOR":     "buildCreator",
	} {
		value, present := os.LookupEnv(env)
		if !present {
			return nil, fmt.Errorf("%q environment variable not set", env)
		}

		config[key] = value
	}

	return config, nil
}

func ValidateFrontendIsReachable(t *testing.T, stackInfo integration.RuntimeValidationStackInfo) {
	c := qt.New(t)

	ip, err := ingressIP(stackInfo.Outputs)

	if err != nil {
		c.Fatalf("failed to extract ingressIP from outputs, outputs: %v, err: %s", stackInfo.Outputs, err)
	}

	if ip == nil {
		c.Fatalf("expected non-nil frontend IP address from outputs, outputs: %v", stackInfo.Outputs)
	}

	url := fmt.Sprintf("http://%s", ip)
	err = pingURL(url)
	if err != nil {
		c.Fatalf("failed to contact frontend url, url: %q, err: %s", url, err)
	}
}

func pingURL(url string) error {
	client := newPesterIgnoreSSL()

	_, err := client.Get(url)

	return err
}

func newPesterIgnoreSSL() *pester.Client {
	c := pester.New()

	t := c.Transport
	if t == nil {
		t = http.DefaultTransport
	}

	defaultTransport := t.(*http.Transport)

	// Create new Transport that ignores self-signed SSL from ingress controllers
	c.Transport = &http.Transport{
		Proxy:                 defaultTransport.Proxy,
		DialContext:           defaultTransport.DialContext,
		MaxIdleConns:          defaultTransport.MaxIdleConns,
		IdleConnTimeout:       defaultTransport.IdleConnTimeout,
		ExpectContinueTimeout: defaultTransport.ExpectContinueTimeout,
		TLSHandshakeTimeout:   defaultTransport.TLSHandshakeTimeout,
		TLSClientConfig:       &tls.Config{InsecureSkipVerify: true},
	}

	return c
}

func ingressIP(outputs map[string]interface{}) (net.IP, error) {
	raw, ok := outputs["ingressIP"]
	if !ok {
		return nil, fmt.Errorf("expected ingressIP in stack output")
	}

	ipStr, ok := raw.(string)
	if !ok {
		return nil, fmt.Errorf("unable to cast ingressIP to string, ip:%v", raw)
	}

	return net.ParseIP(ipStr), nil
}

func prepareCurrentCommitYAML(destination string) error {
	rootDir, present := os.LookupEnv("DEPLOY_SOURCEGRAPH_ROOT")
	if !present {
		return errors.New("'DEPLOY_SOURCEGRAPH_ROOT' env var not set")
	}

	return copy.Copy(rootDir, destination)
}

func prepareOldReleaseYAML(version, destination string) error {
	archiveName := fmt.Sprintf("v%s.tar.gz", version)

	url := fmt.Sprintf("https://github.com/sourcegraph/deploy-sourcegraph/archive/%s", archiveName)

	tarDir, err := ioutil.TempDir("", "deploy-sourcegraph")
	if err != nil {
		return fmt.Errorf("unable to create temp dir for %q: %w", archiveName, err)
	}

	tarPath := filepath.Join(tarDir, archiveName)

	err = downloadFile(tarPath, url)
	if err != nil {
		return fmt.Errorf("unable to download %q: %w", url, err)
	}
	defer os.RemoveAll(tarDir)

	err = unarchive(tarPath, destination)
	if err != nil {
		return fmt.Errorf("unable to extract %q: %w", tarPath, err)
	}

	return nil
}

func unarchive(source, destination string) error {
	c := exec.Command("tar", "-xvf", source, "--strip-components=1", "-C", destination)

	out, err := c.CombinedOutput()
	if err != nil {
		return fmt.Errorf("unable to run 'tar %s', output: %s, err: %w", strings.Join(c.Args, ""), string(out), err)
	}

	return nil
}

func downloadFile(filepath, url string) error {
	file, err := os.Create(filepath)
	if err != nil {
		return fmt.Errorf("failed to create file: %w", err)
	}
	defer file.Close()

	resp, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("failed to fetch %q: %w", url, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("bad status when fetching %q: %s", url, resp.Status)
	}

	_, err = io.Copy(file, resp.Body)
	if err != nil {
		return fmt.Errorf("failed to write response body (%q) to file (%q): %w", url, filepath, err)
	}

	return nil
}
