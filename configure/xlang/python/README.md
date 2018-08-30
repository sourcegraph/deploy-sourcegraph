# Python language server

This folder contains the deployment files for the Python language server.

You can enable it by:

1. Append the `kubectl apply` command for the Python language server deployment to `kubectl-apply-all.sh.

   ```bash
   echo kubectl apply --prune -l deploy=xlang-python -f configure/xlang/python/ --recursive >> kubectl-apply-all.sh
   ```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the Python language server's existence:

   ```yaml
   # base/lsp-proxy/lsp-proxy.Deployment.yaml
   env:
     - name: LANGSERVER_PYTHON
       value: tcp://xlang-python:2087
     - name: LANGSERVER_PYTHON_BG
       value: tcp://xlang-python-bg:2087
   ```

3. Apply your changes to `lsp-proxy` and the Python language server to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```
