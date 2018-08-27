# Clojure language server

This folder contains the deployment files for the Clojure language server.

🚨 **Warning**: This language server is experimental. Please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling it. 🚨

You can enable it by:

1. Append the `kubectl apply` command for the Clojure language server deployment to `kubectl-apply-all.sh.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-clojure -f configure/experimental/clojure --recursive >> kubectl-apply-all.sh
   ```

2. Add the following environment variables to the `lsp-proxy` deployment to make it aware of the Clojure language server's existence.

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_CLOJURE
       value: tcp://xlang-clojure:8080
   ```

3. Apply your changes to `lsp-proxy` and the Clojure language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
