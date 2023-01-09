# Privileged Overlay

An overlay to enable service discover for frontend. It also starts all non-monitoring services with root user and allows privilege.

IMPORTANT: RBACs must be enabled for your cluster to use this overlay.

## How to use

### Local build

If you have this repository cloned locally, check out a version branch that support this overlay, and then run the command below at the root of this repository to generate the manifests for with this overlay:

```sh
# Replace xs with your instance size
kubectl kustomize new/overlays/quick-start/privileged/xs -o new/generated-cluster.yaml
```

The manifests will be grouped and exported to the new/generated-cluster.yaml directory.

### Remote build

You can generate the manifests without cloning the repository using the kustomize remote build feature. To do that, run the command below in your terminal:

```sh
# Replace xs with your instance size
# Replace bee/newBase to a version branch that support this overlay
kubectl kustomize https://github.com/sourcegraph/deploy-sourcegraph/new/overlays/quick-start/privileged/xs?ref=bee/newBase -o new/generated-cluster.yaml
```

The manifests will be grouped and exported to the preview-cluster.yaml file in the directory where you run the command from.
