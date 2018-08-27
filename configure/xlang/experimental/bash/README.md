# Bash language server

This folder contains the deployment files for the Bash language server.

🚨 **Warning**: This language server is experimental. Please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling it. 🚨

You can enable it by:

1. Append the `kubectl apply` command for the Bash language server deployment to `configure/kubectl-apply-all.sh`.

   ```bash
   # configure/kubectl-apply-all.sh
   kubectl apply --prune -l deploy=xlang-bash -f configure/experimental/bash --recursive
   ```

2. Add the following environment variables to the `lsp-proxy` deployment to make it aware of the Bash language server's existence.

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_BASH
       value: tcp://xlang-bash:8080
   ```

3. Apply your changes to `lsp-proxy` and the Bash language server to the cluster.

   ```bash
   ./configure/kubectl-apply-all.sh
   ```
