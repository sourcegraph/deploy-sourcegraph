# `xlang-go`

This folder contains the deployment files for the Go Language server.

You can enable it by:

1. Add the go language server to your site configuration:

```json
{
    ...

    "langservers": [
        {
            "language": "go",
            "address": "tcp://xlang-go:4389"
        }
    ]
}
```

2. Run `kubectl apply -f xlang-go --recursive` to apply the deployment files to your cluster

## `xlang-go-bg`

The Go language server also has an optional "background" deployment, `xlang-go-bg`, which can improve performance by offloading background indexing jobs from the existing `xlang-go` deployment.

You can enable it by:

1. Run `kubectl apply -f xlang-go-bg --recursive` to apply the deployment files to your cluster

2. Add the following environment variables to your `lsp-proxy` deployment to make it aware of `xlang-go-bg`'s existence:

`base/lsp-proxy/lsp-proxy.Deployment.yaml`:

```yaml
...

env:
- name: LANGSERVER_GO
    value: tcp://xlang-go:4389
- name: LANGSERVER_GO_BG
    value: tcp://xlang-go-bg:4389
```
