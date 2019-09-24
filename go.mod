module github.com/sourcegraph/deploy-sourcegraph

go 1.13

require (
	github.com/docker/docker v1.13.1 // indirect
	github.com/frankban/quicktest v1.4.2
	github.com/otiai10/copy v1.0.2
	github.com/pulumi/pulumi v1.0.0
	github.com/sethgrid/pester v0.0.0-20190127155807-68a33a018ad0
	github.com/stretchr/testify v1.4.0 // indirect
	golang.org/x/net v0.0.0-20190620200207-3b0461eec859 // indirect
	google.golang.org/appengine v1.5.0 // indirect
)

replace golang.org/x/xerrors v0.0.0-20190410155217-1f06c39b4373 => golang.org/x/xerrors v0.0.0-20190717185122-a985d3407aa7
