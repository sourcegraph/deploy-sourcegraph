# Old Overlay

An overlay to start a new cluster using the old cluster using the default configurations.

## How to use

**IMPORTANT:**

1. RBACs must be enabled for your cluster to use this overlay.
2. Does not support any components that modify the manifests for `searcher` and `symbols` as all components are created to support `searcher` and `symbols` as `Statefulset` instead of `Deployment`

### Local build

If you have this repository cloned locally, check out a version branch that support this overlay, and then run the command below at the root of this repository to generate the manifests for with this overlay:

```sh
# Replace bee/newBase to a version branch that support this overlay
# Example: git checkout v4.4.0
git checkout bee/newBase
# Generate manifests with resources from the old base cluster
# RBACs required
kustomize build new/overlays/quick-start/old > new/generated-cluster.yaml
```

The manifests will be grouped and exported to the generated-cluster.yaml file in the new directory.

### Remote build

You can generate the manifests without cloning the repository using the kustomize remote build feature. To do that, run the command below in your terminal:

```sh
# Replace bee/newBase to a version branch that support this overlay
kustomize build https://github.com/sourcegraph/deploy-sourcegraph/new/overlays/quick-start/old?ref=bee/newBase > generated-cluster.yaml
```

The manifests will be grouped and exported to the generated-cluster.yaml file in the directory where you run the command from.
