## How to use

### Build an overlay

To build a new set of manifests using the overlay:

1. Run the following command from the root of this repository:

```bash
# OPTION 1 - When using kustomize:
$ kustomize build new/kustomize/overlays -o generated-cluster/
# OPTION 2 - When using kubectl:
$ kubectl apply -k new/kustomize/overlays > generated-cluster/
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
