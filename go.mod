module github.com/sourcegraph/deploy-sourcegraph

go 1.16

require (
	github.com/docker/docker v1.13.1 // indirect
	github.com/pulumi/pulumi v1.12.0
	github.com/sethgrid/pester v1.1.0
	github.com/sourcegraph/sourcegraph/enterprise/dev/ci/images v0.0.0-20210921092609-ce1bb5d0a710
	github.com/sourcegraph/update-docker-tags v0.8.0
	golang.org/x/crypto v0.0.0-20191011191535-87dc89f01550 // indirect
	golang.org/x/xerrors v0.0.0-20191011141410-1b5146add898 // indirect
)

replace github.com/Azure/go-autorest => github.com/Azure/go-autorest v12.4.3+incompatible
