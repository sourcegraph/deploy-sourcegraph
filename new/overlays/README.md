# Overlays

An overlay specifies customizations for a base directory of Kubernetes manifests, in this case the [base/](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph@master/-/tree/base) directory in the [deploy-sourcegraph repository](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph@master).

Each overlay is created with different kustomize components that are located inside the components directory.

## How to use

### Generate manifests

Run the following command from the root of this repository to generate a new set of manifests from an overlay:

```bash
# Example: kubectl kustomize new/kustomize/overlays/quick-start/basic/xs -o new/generated-cluster.yaml
$ kubectl kustomize $PATH_TO_OVERLAY -o new/generated-cluster.yaml
```

The new set of manifests can then be found in the [new/generated-cluster.yaml](../preview-cluster/) directory.

### Apply an overlay

To apply the customiziation made with an overlay:

1. Follow the steps above to build manifests from an overlay
2. Make sure the manifests in the output directory `generated-cluster/` are generated correctly
3. Run the following command from the root of this repository to apply the manifests from the output directory `new/generated-cluster.yaml`

   ```bash
   $ kubectl apply -k --prune -l deploy=sourcegraph -f new/generated-cluster.yaml
   ```
