# R language server

This folder contains the deployment files for the R language server.

🚨 **Warning**: This language server is experimental. Please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling it. 🚨

You can enable it by:

1. Append the `kubectl apply` command for the R language server deployment to `kubectl-apply-all.sh`.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-r -f configure/experimental/r --recursive >> kubectl-apply-all.sh
   ```

1. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the R language server's existence.

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_R
       value: tcp://xlang-r:8080
   ```

1. Add the following entry for the R language server to the `langservers` array in your site configuration.

   ```yaml
   # base/config-file.ConfigMap.yaml

   config.json: |-
     {
       "langservers": [
         {
           "language": "r"
         }
       ]
     }
   ```

1. Apply your changes to `lsp-proxy`, `base/config-file.ConfigMap.yaml`, and the R language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
