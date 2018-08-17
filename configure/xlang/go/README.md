# Go Language Server

This folder contains the deployment files for the Go Language server.

You can enable it by:

1. Running `kubectl apply -f configure/xlang/go/ --recursive` to apply the dpeloyment files to your cluster

```shell
> kubectl apply -f configure/xlang/go/ --recursive

deployment "xlang-go-bg" created
service "xlang-go-bg" created
deployment "xlang-go" created
service "xlang-go" created
```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the
   Go language server's existence:

`base/lsp-proxy/lsp-proxy.Deployment.yaml`:

```yaml
env:
  - name: LANGSERVER_GO
    value: tcp://xlang-go:4389
  - name: LANGSERVER_GO_BG
    value: tcp://xlang-go-bg:4389
```
