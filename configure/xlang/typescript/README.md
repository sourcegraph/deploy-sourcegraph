# Javascript / Typescript language server

This folder contains the deployment files for the Javascript / Typescript language server.

You can enable it by:

1. Append the `kubectl apply` command for the Javascript / Typescript language server deployment to `kubectl-apply-all.sh`.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-typescript -f configure/xlang/typescript/ --recursive >> kubectl-apply-all.sh
   ```

1. Add the following entries for the Javascript / Typescript language server to the `langservers` array in your site configuration.

   ```yaml
   # base/config-file.ConfigMap.yaml

   config.json: |-
     {
       "langservers": [
         {
           "language": "javascript",
           "address": "tcp://xlang-typescript:2088"
         },
         {
           "language": "typescript",
           "address": "tcp://xlang-typescript:2088"
         }
       ]
     }
   ```

1. Apply your changes to `base/config-file.ConfigMap.yaml`, and the Javascript / Typescript language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
