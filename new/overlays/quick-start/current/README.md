# Current base cluster Overlay

An overlay to start a new cluster using the old cluster using the default configurations.

This overlay does not support any components created for the new cluster. Use the `old-base` overlay instead.

## How to use

**IMPORTANT:**

1. RBACs must be enabled for your cluster to use this overlay.
2. Does not support any components that modify the manifests for `searcher` and `symbols` as all components are created to support `searcher` and `symbols` as `Statefulset` instead of `Deployment`

### Local build

If you have this repository cloned locally, check out a version branch that support this overlay, and then run the command below at the root of this repository to generate the manifests for with this overlay:

```sh
# Replace bee/newBase to a version branch that support this overlay
# Example: git checkout v4.4.0
git checkout $VERSION_NUMBER
# Generate manifests with resources from the old base cluster
# RBACs required
kubectl kustomize new/overlays/quick-start/current -o new/preview-cluster
```

The manifests will be grouped and exported to the new/preview-cluster directory.

### Remote build

You can generate the manifests without cloning the repository using the kustomize remote build feature. To do that, run the command below in your terminal:

```sh
# Replace bee/newBase to a version branch that support this overlay
kubectl kustomize https://github.com/sourcegraph/deploy-sourcegraph/new/overlays/quick-start/old?ref=bee/newBase -o preview-cluster.yaml
```

The manifests will be grouped and exported to the preview-cluster.yaml in the directory where you run the command from.
