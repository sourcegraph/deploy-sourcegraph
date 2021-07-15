This kustomization injects initContainers in all pods with persistent volumes to transfer ownership of directories to
specified non-root users. It is used for migrating existing installations to a non-root environment.

```shell script
./overlay-generate-cluster.sh migrate-to-nonroot generated-cluster
```

After executing the script you can apply the generated manifests from the `generated-cluster` directory:

```shell script
kubectl apply --prune -l deploy=sourcegraph -f generated-cluster --recursive
```

