This kustomization is for Sourcegraph installations in clusters with security restrictions.
It avoids creating `Roles` and does all the rolebinding in a namespace. It configures Prometheus to work in the namespace
and not require ClusterRole wide privileges when doing service discovery for scraping targets.

```shell script
cd overlays/non-privileged
kubectl -n ns-sourcegraph apply -l deploy=sourcegraph,rbac-admin!=escalated -k .
```
