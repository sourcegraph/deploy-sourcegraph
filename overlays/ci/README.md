# CI overlay


This overlay is used for the e2e cluster tests. They reduces cluster resource usage.

Use `kustomize set

Note: `persistentVolumeClaim: null` is needed to avoid https://github.com/kubernetes-sigs/kustomize/issues/2037