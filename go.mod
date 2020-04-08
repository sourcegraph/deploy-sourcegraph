module github.com/sourcegraph/deploy-sourcegraph

go 1.14

require (
	github.com/docker/docker v1.13.1 // indirect
	github.com/frankban/quicktest v1.4.2
	github.com/pulumi/pulumi v1.12.0
	github.com/sethgrid/pester v1.1.0
)

replace github.com/Azure/go-autorest => github.com/Azure/go-autorest v12.4.3+incompatible
