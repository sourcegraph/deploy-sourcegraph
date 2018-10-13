# Clojure language server

This folder contains the deployment files for the Clojure language server.

🚨 **Warning**: This language server is experimental. Please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling it. 🚨

You can enable it by:

1. Append the `kubectl apply` command for the Clojure language server deployment to `kubectl-apply-all.sh`.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-clojure -f configure/experimental/clojure --recursive >> kubectl-apply-all.sh
   ```

1. Add the following entry for the Clojure language server to the `langservers` array in your site configuration.

   ```yaml
   # base/config-file.ConfigMap.yaml

   config.json: |-
     {
       "langservers": [
         {
           "language": "clojure",
           "address": "tcp://xlang-clojure:8080"
         }
       ]
     }
   ```

1. Apply your changes to `base/config-file.ConfigMap.yaml`, and the Clojure language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
