# `xlang-go`

This folder contains the deployment files for the Go Language server. You can enable it by:

1. Add the go language server to your site configuration:

```json
{
    ...

    "langservers": [
        {
            "language": "go",
            "address": "tcp://xlang-go:3178"
        }
    ]
}
```

2. Run `kubectl apply -f xlang-go.Deployment.yaml xlang-go.Service.yaml` to apply the deployment files to your cluster

`xlang-go` also has an optional "background" deployment, `xlang-go-bg`, which can improve performance by offloading background indexing jobs from the existing `xlang-go` deployment.

You can enable it by:

1. Run `kubectl apply -f xlang-go-bg.Deployment.yaml xlang-go-bg.Service.yaml` to apply the deployment files to your cluster

2. Add the following environment variables to your `lsp-proxy` deployment:

```yaml
...

env:
- name: LANGSERVER_GO
    value: tcp://xlang-go:4389
- name: LANGSERVER_GO_BG
    value: tcp://xlang-go-bg:4389
```
