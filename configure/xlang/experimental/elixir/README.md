# Elixir language server

This folder contains the deployment files for the Elixir language server.

🚨 **Warning**: This language server is experimental. Please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling it. 🚨

You can enable it by:

1. Append the `kubectl apply` command for the Elixir language server deployment to `kubectl-apply-all.sh`.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-elixir -f configure/experimental/elixir --recursive >> kubectl-apply-all.sh
   ```

1. Add the following entry for the Elixir language server to the `langservers` array in your site configuration.

   ```yaml
   # base/config-file.ConfigMap.yaml

   config.json: |-
     {
       "langservers": [
         {
           "language": "elixir",
           "address": "tcp://xlang-elixir:8080"
         }
       ]
     }
   ```

1. Apply your changes to `base/config-file.ConfigMap.yaml`, and the Elixir language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
