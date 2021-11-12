module github.com/sourcegraph/deploy-sourcegraph

go 1.14

require (
	github.com/docker/docker v1.13.1 // indirect
	github.com/pulumi/pulumi v1.12.0
	github.com/sethgrid/pester v1.1.0
	github.com/slimsag/update-docker-tags v0.7.0
	github.com/sourcegraph/sourcegraph/enterprise/dev/ci/images v0.0.0-20201220021356-213efca6309f
)

replace github.com/Azure/go-autorest => github.com/Azure/go-autorest v12.4.3+incompatible
