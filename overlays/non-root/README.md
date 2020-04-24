This kustomization is for Sourcegraph installations that want to run containers as non-root user.

> Note: To create a fresh installation use `non-root-create-cluster` first and then use this overlay.

To use it, execute the following command from the root directory of this repository:

```shell script
./overlay-generate-cluster.sh non-root generated-cluster
```

After executing the script you can apply the generated manifests from the `generated-cluster` directory:

```shell script
kubectl apply --prune -l deploy=sourcegraph -f generated-cluster --recursive
```
