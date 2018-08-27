# PHP language server

This folder contains the deployment files for the PHP language server.

You can enable it by:

1. Append the `kubectl apply` command for the PHP language server deployment to `configure/kubectl-apply-all.sh`.

   ```bash
   # configure/kubectl-apply-all.sh
   kubectl apply --prune -l deploy=xlang-php -f configure/xlang/php/ --recursive
   ```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the PHP language server's existence:

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_PHP
       value: tcp://xlang-php:2088
   ```

3. Apply your changes to `lsp-proxy` and the PHP language server to the cluster.

   ```bash
   ./configure/kubectl-apply-all.sh
   ```
