module github.com/sourcegraph/deploy-sourcegraph

go 1.16

require (
	cloud.google.com/go/logging v1.4.2 // indirect
	github.com/docker/docker v1.13.1 // indirect
	github.com/fatih/color v1.10.0 // indirect
	github.com/pkg/errors v0.9.1
	github.com/pulumi/pulumi v1.14.1
	github.com/pulumi/pulumi/pkg v1.14.1
	github.com/sethgrid/pester v1.1.0
	github.com/sourcegraph/sourcegraph/enterprise/dev/ci/images v0.0.0-20220415005223-782c819e0d4d
	github.com/sourcegraph/update-docker-tags v0.10.0
	github.com/spf13/cobra v1.1.3 // indirect
	github.com/stretchr/testify v1.7.0
	golang.org/x/sys v0.0.0-20210510120138-977fb7262007 // indirect
	gopkg.in/yaml.v3 v3.0.0-20210107192922-496545a6307b // indirect
)

replace github.com/Azure/go-autorest => github.com/Azure/go-autorest v12.4.3+incompatible
