# StorageClassName Overlay

This is a convenient kustomization that adds the specified storageclass to all pvc's and statefulsets.

You will need to create a storageclass if it doesn't exist yet. See [these docs](https://docs.sourcegraph.com/admin/install/kubernetes/configure#configure-a-storage-class) for detailed instructions.

## How to use

1. cd into this directory [overlays/storageclass-name](./README.md)
2. [OPTIONAL] Update the `namespace` value
3. Update the variable `DEPLOY_SOURCEGRAPH_STORAGECLASS_NAME` inside the [.sourcegraph_config.env](.sourcegraph_config.env) file
4. To generate the manifests with this overlay, run `kubectl kustomize . -o generated-cluster.yaml`
5. Make sure the values in `generated-cluster.yaml` are generated correctly
6. To apply, run `kubectl apply -f generated-cluster.yaml`
