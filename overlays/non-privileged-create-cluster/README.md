This kustomization is for Sourcegraph installations in clusters with security restrictions.
It avoids creating `Roles` and does all the rolebinding in a namespace. It configures Prometheus to work in the namespace
and not require ClusterRole wide privileges when doing service discovery for scraping targets.

This version and `non-privileged` need to stay in sync. This version is only used for cluster creation.

To use it, execute the following command from the root directory of this repository:

```shell script
./overlay-generate-cluster.sh non-privileged generated-cluster
```

After executing the script you can apply the generated manifests from the `generated-cluster` directory:

```shell script
kubectl apply --prune -l deploy=sourcegraph -f generated-cluster --recursive
```
