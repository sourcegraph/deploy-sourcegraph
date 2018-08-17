# Go language server

This folder contains the deployment files for the Go language server.

You can enable it by:

1. Apply the deployment files to your cluster.

   ```shell
   kubectl apply -f configure/xlang/go/ --recursive
   ```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the Go language server's existence.

```yaml
# base/lsp-proxy/lsp-proxy.Deployment.yaml
env:
  - name: LANGSERVER_GO
    value: tcp://xlang-go:4389
  - name: LANGSERVER_GO_BG
    value: tcp://xlang-go-bg:4389
```
