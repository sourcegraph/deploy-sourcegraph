# K3s Overlay

An overlay to start a pre-configured Sourcegraph instance for deploying to a k3s cluster.

## How to use

### Local build

If you have this repository cloned locally, check out a version branch that support this overlay, and then run the command below at the root of this repository to generate the manifests for with this overlay:

```sh
# Replace xs with your instance size
kustomize build new/overlays/quick-start/k3s/xs > new/generated-cluster.yaml
```

The manifests will be grouped and exported to the generated-cluster.yaml file in the new directory.

### Remote build

You can generate the manifests without cloning the repository using the kustomize remote build feature. To do that, run the command below in your terminal:

```sh
# Replace xs with your instance size
# Replace bee/newBase to a version branch that support this overlay
kustomize build https://github.com/sourcegraph/deploy-sourcegraph/new/overlays/quick-start/k3s/xs?ref=bee/newBase > generated-cluster.yaml
```

The manifests will be grouped and exported to the generated-cluster.yaml file in the directory where you run the command from.
