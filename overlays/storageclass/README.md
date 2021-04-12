# storageclass

This is a convenient kustomization that adds the specified storageclass to all pvc's and statefulsets.

You need to create the storageclass if it doesn't exist yet. See [these docs](https://docs.sourcegraph.com/admin/install/kubernetes/configure#configure-a-storage-class) for more instructions.

To use it, update the two patch files in this directory with your storageclass name.

To generate to the cluster, execute the following command:
```shell script
./overlay-generate-cluster.sh storageclass generated-cluster
```

After executing the script you can apply the generated manifests from the `generated-cluster` directory:

```shell script
kubectl apply --prune -l deploy=sourcegraph -f generated-cluster --recursive
```
