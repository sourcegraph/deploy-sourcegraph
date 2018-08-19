# Javascript / Typescript language server

This folder contains the deployment files for the Javascript / Typescript language server.

You can enable it by:

1. Apply the deployment files to your cluster.

   ```shell
   kubectl apply -f configure/xlang/typescript/ --recursive
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

3. `kubectl apply` your changes so that the `lsp-proxy` deployment sees the new environment variables.

   ```bash
   kubectl apply --prune -l deploy=sourcegraph -f base --recursive
   ```
