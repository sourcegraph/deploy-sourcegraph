# Dockerfile language server

This folder contains the deployment files for the Dockerfile language server.

🚨 **Warning**: This language server is experimental. Please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling it. 🚨

You can enable it by:

1. Append the `kubectl apply` command for the Dockerfile language server deployment to `kubectl-apply-all.sh`.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-dockerfile -f configure/experimental/dockerfile --recursive >> kubectl-apply-all.sh
   ```

1. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the Dockerfile language server's existence.

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_DOCKERFILE
       value: tcp://xlang-dockerfile:8080
   ```

1. Add the following entry for the Dockerfile language server to the `langservers` array in your site configuration.

   ```yaml
   # base/config-file.ConfigMap.yaml

   config.json: |-
     {
       "langservers": [
         {
           "language": "dockerfile"
         }
       ]
     }
   ```

1. Apply your changes to `lsp-proxy`, `base/config-file.ConfigMap.yaml`, and the Dockerfile language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
