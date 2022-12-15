# Overlays

An overlay specifies customizations for a base directory of Kubernetes manifests, in this case the [base/](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph@master/-/tree/base) directory in the [deploy-sourcegraph repository](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph@master).

Each overlay is created with different kustomize components that are located inside the components directory.

## How to use

### Build an overlay

To build a new set of manifests using the overlay:

1. Run the following command from the root of this repository:

```bash
# OPTION 1 - When using kustomize:
$ kustomize build new/kustomize/overlays/$OVERLAY_NAME -o generated-cluster/
# Example: kustomize build new/kustomize/overlays/example -o generated-cluster/

# OPTION 2 - When using kubectl:
$ kubectl apply -k new/kustomize/overlays/$OVERLAY_NAME > generated-cluster/
# Example: kubectl apply -k new/kustomize/overlays/example > generated-cluster/
```

The new set of manifests will be output to the [generated-cluster](../../../generated-cluster/) directory.

### Apply an overlay

To apply the customiziation made with the overlay:

1. Run the following command from the root of this repository:

```bash
# OPTION 1 - When using kustomize:
$ kustomize build new/kustomize/overlays | kubectl apply -f -

# OPTION 2 - When using kubectl:
$ kubectl apply -k new/kustomize/overlays
```
