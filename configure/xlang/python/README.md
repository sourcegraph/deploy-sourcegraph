# Python language server

This folder contains the deployment files for the Python language server.

You can enable it by:

1. Apply the deployment files to your cluster:

   ```shell
   kubectl apply -f configure/xlang/python/ --recursive
   ```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the Python language server's existence:

```yaml
# base/lsp-proxy/lsp-proxy.Deployment.yaml
env:
  - name: LANGSERVER_PYTHON
    value: tcp://xlang-python:2087
  - name: LANGSERVER_PYTHON_BG
    value: tcp://xlang-python-bg:2087
```
