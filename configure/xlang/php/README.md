# PHP language server

This folder contains the deployment files for the PHP language server.

You can enable it by:

1. Append the `kubectl apply` command for the PHP language server deployment to `kubectl-apply-all.sh`.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-php -f configure/xlang/php/ --recursive >> kubectl-apply-all.sh
   ```

1. Add the following entry for the PHP language server to the `langservers` array in your site configuration.

   ```yaml
   # base/config-file.ConfigMap.yaml

   config.json: |-
     {
       "langservers": [
         {
           "language": "php",
           "address": "tcp://xlang-php:2088"
         }
       ]
     }
   ```

1. Apply your changes to `base/config-file.ConfigMap.yaml`, and the PHP language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
