# Javascript / Typescript language server

This folder contains the deployment files for the Javascript / Typescript language server.

You can enable it by:

1. Append the `kubectl apply` command for the Javascript / Typescript language server deployment to `kubectl-apply-all.sh.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-typescript -f configure/xlang/typescript/ --recursive >> kubectl-apply-all.sh
   ```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the Javascript / Typescript language server's existence.

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_JAVASCRIPT
       value: tcp://xlang-typescript:2088
     - name: LANGSERVER_JAVASCRIPT_BG
       value: tcp://xlang-typescript-bg:2088
     - name: LANGSERVER_TYPESCRIPT
       value: tcp://xlang-typescript:2088
     - name: LANGSERVER_TYPESCRIPT_BG
       value: tcp://xlang-typescript-bg:2088
   ```

3. Apply your changes to `lsp-proxy` and the Javascript / Typescript language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
