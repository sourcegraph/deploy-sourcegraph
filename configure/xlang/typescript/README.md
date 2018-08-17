# Javascript / Typescript Language Server

This folder contains the deployment files for the Javascript / Typescript Language server.

You can enable it by:

1. Running `kubectl apply -f configure/xlang/typescript/ --recursive` to apply the deployment files to your cluster:

```shell
> kubectl apply -f configure/xlang/typescript/ --recursive

deployment "npm-proxy" created
persistentvolumeclaim "npm-proxy" created
service "npm-proxy" created
deployment "xlang-typescript-bg" created
service "xlang-typescript-bg" created
deployment "xlang-typescript" created
service "xlang-typescript" created
configmap "yarn-config" created
```

2. Adding the following environment variables to the `lsp-proxy` deployment to make it aware of the
   Javascript / Typescript language server's existence:

`base/lsp-proxy/lsp-proxy.Deployment.yaml`:

```yaml
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
