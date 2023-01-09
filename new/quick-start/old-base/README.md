# Old Base Overlay

An overlay to generate resources similar to the old cluster.

IMPORTANT: RBAC must be enabled for your cluster.

## How to use

Run the following command (pick a command for your instance size) from the root of this repository:

```sh
# To generate manifests using the defaults values from the old base cluster:
kubectl kustomize new/quick-start/old-base/default -o new/generated-cluster.yaml

# To generate manifests for the old base cluster with resources updated each instance size:
kubectl kustomize new/quick-start/old-base/xs -o new/generated-cluster.yaml
kubectl kustomize new/quick-start/old-base/s -o new/generated-cluster.yaml
kubectl kustomize new/quick-start/old-base/m -o new/generated-cluster.yaml
kubectl kustomize new/quick-start/old-base/l -o new/generated-cluster.yaml
kubectl kustomize new/quick-start/old-base/xl -o new/generated-cluster.yaml
```
