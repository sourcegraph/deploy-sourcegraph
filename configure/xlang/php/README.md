# PHP language server

This folder contains the deployment files for the PHP language server.

You can enable it by:

1. Apply the deployment files to your cluster:

   ```shell
   kubectl apply -f configure/xlang/php/ --recursive
   ```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the PHP language server's existence:

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_PHP
       value: tcp://xlang-php:2088
   ```

3. `kubectl apply` your changes so that the `lsp-proxy` deployment sees the new environment variables.

   ```bash
   kubectl apply --prune -l deploy=sourcegraph -f base --recursive
   ```
