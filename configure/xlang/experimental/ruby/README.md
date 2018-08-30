# Ruby language server

This folder contains the deployment files for the Ruby language server.

🚨 **Warning**: This language server is experimental. Please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling it. 🚨

You can enable it by:

1. Append the `kubectl apply` command for the Ruby language server deployment to `kubectl-apply-all.sh`.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-ruby -f configure/experimental/ruby --recursive >> kubectl-apply-all.sh
   ```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the Ruby language server's existence.

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_RUBY
       value: tcp://xlang-ruby:8080
   ```

3. Apply your changes to `lsp-proxy` and the Ruby language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
