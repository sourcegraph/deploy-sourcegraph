package fresh

import (
	"crypto/tls"
	"fmt"
	"net/http"
	"os"
	"sort"
	"testing"

	"github.com/kr/pretty"
	"github.com/pulumi/pulumi/pkg/testing/integration"
	"github.com/sethgrid/pester"
)

func TestFreshDeployment(t *testing.T) {

	config, err := baseConfig()
	if err != nil {
		pFatalf(t, "unable to generate base pulumi configuration, err: %s", err)
	}

	integration.ProgramTest(t, &integration.ProgramTestOptions{
		Dir: "step1",

		Config:               config,
		ExpectRefreshChanges: true,
		Quick:                false,

		ExtraRuntimeValidation: func(t *testing.T, stackInfo integration.RuntimeValidationStackInfo) {
			v, ok := stackInfo.Outputs["ingressIP"]
			if !ok {
				pFatalf(t, "expected ingressIP as stack output, output: %s", v)
			}

			ip, ok := v.(string)
			if !ok {
				pFatalf(t, "unable to cast ingressIP to string, ip:%s", v)
			}

			if ip == "" {
				pFatalf(t, "expected non-empty ip, got: %q", ip)
			}

			err := PingURL(fmt.Sprintf("http://%s", ip))
			if err != nil {
				pErrorf(t, "unable to ping frontend url, err: %s", err)
			}
		},
	})
}

func baseConfig() (map[string]string, error) {
	config := map[string]string{}

	for env, key := range map[string]string{
		"TEST_GCP_PROJECT":        "gcp:config:project",
		"TEST_GCP_ZONE":           "gcp:config:zone",
		"TEST_GCP_USERNAME":       "gcpUsername",
		"DEPLOY_SOURCEGRAPH_ROOT": "deploySourcegraphRoot",
	} {
		value, present := os.LookupEnv(env)
		if !present {
			if !present {
				return nil, fmt.Errorf("%q not set", env)
			}

			config[key] = value
		}
	}

	return config, nil
}

func PingURL(url string) error {
	client := pester.New()

	client.Concurrency = 3
	client.MaxRetries = 5
	client.Backoff = pester.ExponentialJitterBackoff
	client.KeepLog = true

	rt := client.Transport
	if rt == nil {
		rt = http.DefaultTransport
	}

	defaultTransport := rt.(*http.Transport)

	// Create new Transport that ignores self-signed SSL from ingress controllers
	client.Transport = &http.Transport{
		Proxy:                 defaultTransport.Proxy,
		DialContext:           defaultTransport.DialContext,
		MaxIdleConns:          defaultTransport.MaxIdleConns,
		IdleConnTimeout:       defaultTransport.IdleConnTimeout,
		ExpectContinueTimeout: defaultTransport.ExpectContinueTimeout,
		TLSHandshakeTimeout:   defaultTransport.TLSHandshakeTimeout,
		TLSClientConfig:       &tls.Config{InsecureSkipVerify: true},
	}

	_, err := client.Get(url)

	if err != nil {
		return pretty.Errorf("unable to ping url: %q, err: %s", url, err)
	}

	return nil
}

func pErrorf(t *testing.T, format string, args ...interface{}) {
	t.Error(pretty.Sprintf(format, args))
}

func pFatalf(t *testing.T, format string, args ...interface{}) {
	t.Fatal(pretty.Sprintf(format, args))
}

func SortResourcesByURN(stackInfo integration.RuntimeValidationStackInfo) {
	sort.Slice(stackInfo.Deployment.Resources, func(i, j int) bool {
		return stackInfo.Deployment.Resources[i].URN < stackInfo.Deployment.Resources[j].URN
	})
}
