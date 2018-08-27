# Elixir language server

This folder contains the deployment files for the Elixir language server.

🚨 **Warning**: This language server is experimental. Please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling it. 🚨

You can enable it by:

1. Append the `kubectl apply` command for the Elixir language server deployment to `configure/kubectl-apply-all.sh`.

   ```bash
   # configure/kubectl-apply-all.sh
   kubectl apply --prune -l deploy=xlang-elixir -f configure/experimental/elixir --recursive
   ```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the Elixir language server's existence.

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_ELIXIR
       value: tcp://xlang-elixir:8080
   ```

3. Apply your changes to `lsp-proxy` and the Elixir language server to the cluster.

   ```bash
   ./configure/kubectl-apply-all.sh
   ```
