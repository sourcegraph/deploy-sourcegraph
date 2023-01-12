# Full overlay

The full overlays are for deploying all Sourcegraph services, which include **RBAC resources.**

```bash
# NOTE: replace `xs` with your instance size.
kubectl kustomize new/quick-start/full/xs -o new/generated-cluster.yaml
```
