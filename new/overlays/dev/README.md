# Low Resources overlay

This overlay is intended for Sourcegraph internal CI tests. It removes resource requests including cpu, memory and persistent volumes to reduce load on shared clusters. 

Note: `persistentVolumeClaim: null` is needed to avoid https://github.com/kubernetes-sigs/kustomize/issues/2037