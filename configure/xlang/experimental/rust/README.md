# Rust language server

This folder contains the deployment files for the Rust language server.

🚨 **Warning**: This language server is experimental. Please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling it. 🚨

You can enable it by:

1. Append the `kubectl apply` command for the Rust language server deployment to `configure/kubectl-apply-all.sh`.

   ```bash
   # configure/kubectl-apply-all.sh
   kubectl apply --prune -l deploy=xlang-rust -f configure/experimental/rust --recursive
   ```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the Rust language server's existence.

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_RUST
       value: tcp://xlang-rust:8080
   ```

3. Apply your changes to `lsp-proxy` and the Rust language server to the cluster.

   ```bash
   ./configure/kubectl-apply-all.sh
   ```
