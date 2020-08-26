module github.com/sourcegraph/deploy-sourcegraph-dogfood-k8s

go 1.14

require (
	github.com/docker/docker v1.13.1 // indirect
	github.com/pulumi/pulumi v1.12.0
	github.com/sethgrid/pester v0.0.0-20190127155807-68a33a018ad0
)

replace github.com/Azure/go-autorest => github.com/Azure/go-autorest v12.4.3+incompatible
