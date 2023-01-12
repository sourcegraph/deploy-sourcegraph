# Base overlay

The base overlays are for deploying the main Sourcegraph stacks without monitoring services.

```bash
# NOTE: replace `xs` with your instance size.
kubectl kustomize new/quick-start/base/xs -o new/generated-cluster.yaml
```
