This kustomization injects initContainers in all pods with persistent volumes to transfer ownership of directories to
specified non-root users. It is used for migrating existing installations to a non-root environment.

This only needs to be run once for installations that want to upgrade to 3.14. Afterwards it can be ignored.

```shell script
cd overlays/migrate-to-nonroot
kubectl apply -k .
```

