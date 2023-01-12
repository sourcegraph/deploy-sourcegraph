# Quick Start

This directory provides overlays that are ready to use for installing a pre-configured Sourcegraph instance in different environments

## How to use

### Build

To build manifests using an overlay without applying them to your cluster:

```bash
kubectl kustomize new/quick-start/$OVERLAY_NAME -o new/generated-cluster.yaml
```

### Deploy

Deploy using the resouces defined in the output file created during the build step above:

```bash
kubectl apply --prune -l deploy=sourcegraph -f new/generated-cluster.yaml
```
