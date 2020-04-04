This kustomization is for Sourcegraph installations in clusters with security restrictions.
It avoids creating `Roles` and does all the rolebinding in a namespace. It configures Prometheus to work in the namespace
and not require ClusterRole wide privileges when doing service discovery for scraping targets.

This version and `non-privileged` need to stay in sync. This version is only used for cluster creation.

```shell script
cd overlays/non-privileged
kubectl -n ns-sourcegraph apply -l deploy=sourcegraph,rbac-admin!=escalated -k .
```
