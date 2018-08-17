# PHP Language Server

This folder contains the deployment files for the PHP Language server.

You can enable it by:

1. Running `kubectl apply -f configure/xlang/php/ --recursive` to apply the deployment files to your cluster:

```shell
> kubectl apply -f configure/xlang/php/ --recursive

deployment "xlang-php" created
service "xlang-php" created
```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the
   PHP language server's existence:

`base/lsp-proxy/lsp-proxy.Deployment.yaml`:

```yaml
env:
  - name: LANGSERVER_PHP
    value: tcp://xlang-php:2088
```
