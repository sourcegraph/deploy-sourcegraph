package fresh

import (
	"sort"
	"testing"

	"github.com/kr/pretty"
	"github.com/pulumi/pulumi/pkg/testing/integration"
)

var step1Name interface{}
var step2Name interface{}
var step3Name interface{}

func TestAutonaming(t *testing.T) {
	integration.ProgramTest(t, &integration.ProgramTestOptions{
		Config: map[string]string{
			"gcp:config:project":    "sourcegraph-dev",
			"gcp:config:zone":       "us-central1-a",
			"deploySourcegraphRoot": "/Users/ggilmore/dev/go/src/github.com/sourcegraph/deploy",
		},
		Dir:                  "step1",
		ExpectRefreshChanges: true,
		Quick:                false,
		ExtraRuntimeValidation: func(t *testing.T, stackInfo integration.RuntimeValidationStackInfo) {
			t.Log(pretty.Sprint(stackInfo))
		},
	})
}

func SortResourcesByURN(stackInfo integration.RuntimeValidationStackInfo) {
	sort.Slice(stackInfo.Deployment.Resources, func(i, j int) bool {
		return stackInfo.Deployment.Resources[i].URN < stackInfo.Deployment.Resources[j].URN
	})
}
