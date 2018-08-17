# Python Language Server

This folder contains the deployment files for the Python Language server.

You can enable it by:

1. Running `kubectl apply -f configure/xlang/python/ --recursive` to apply the deployment files to your cluster:

```shell
> kubectl apply -f configure/xlang/python/ --recursive

deployment "xlang-python-bg" created
service "xlang-python-bg" created
deployment "xlang-python" created
service "xlang-python" created
```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the
   Python language server's existence:

`base/lsp-proxy/lsp-proxy.Deployment.yaml`:

```yaml
env:
  - name: LANGSERVER_PYTHON
    value: tcp://xlang-python:2087
  - name: LANGSERVER_PYTHON_BG
    value: tcp://xlang-python-bg:2087
```
