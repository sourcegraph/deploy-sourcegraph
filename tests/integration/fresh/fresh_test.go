package fresh

import (
	"crypto/tls"
	"fmt"
	"net"
	"net/http"
	"os"
	"testing"

	"github.com/pulumi/pulumi/pkg/testing/integration"
	"github.com/sethgrid/pester"
)

func TestFreshDeployment(t *testing.T) {

	if testing.Short() {
		t.Skip("skipping fresh cluster integration test in short mode")
	}

	for _, k8sVersion := range []string{"1.15", "1.16", "1.17"} {
		k8sVersion := k8sVersion

		t.Run(fmt.Sprintf("GKE version %q", k8sVersion), func(t *testing.T) {

			config, err := commonConfig()
			if err != nil {
				t.Fatalf("unable to generate pulumi configuration, err: %s", err)
			}

			config["kubernetesVersionPrefix"] = k8sVersion
			integration.ProgramTest(t, &integration.ProgramTestOptions{
				Dir: "step1",

				Config:               config,
				ExpectRefreshChanges: true,
				Quick:                false,
				Verbose:              testing.Verbose(),

				ExtraRuntimeValidation: ValidateFrontendIsReachable,
			})
		})
	}
}

func commonConfig() (map[string]string, error) {
	config := map[string]string{}

	for env, key := range map[string]string{
		"TEST_GCP_PROJECT":        "gcp:project",
		"TEST_GCP_ZONE":           "gcp:zone",
		"DEPLOY_SOURCEGRAPH_ROOT": "deploySourcegraphRoot",
		"BUILD_CREATOR":           "buildCreator",
		"GENERATED_BASE":          "generatedBase",
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
	ip, err := ingressIP(stackInfo.Outputs)

	if err != nil {
		t.Fatalf("failed to extract ingressIP from outputs, outputs: %v, err: %s", stackInfo.Outputs, err)
	}

	if ip == nil {
		t.Fatalf("expected non-nil frontend IP address from outputs, outputs: %v", stackInfo.Outputs)
	}

	url := fmt.Sprintf("http://%s", ip)
	err = pingURL(url)
	if err != nil {
		t.Fatalf("failed to contact frontend url, url: %q, err: %s", url, err)
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
