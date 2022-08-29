# Kustomize Overlay - Resources Update

This overlay allows you to customize the values for the resources described in the [Sourcegraph resource estimator](https://docs.sourcegraph.com/admin/deploy/resource_estimator) for your instance through a kustomization file.

### Step 1: update the resources.yaml file

Look for the names of the services inside the `resources.yaml` file in this directory and update the values for the resources within the file

> IMPORTANT: Make sure the untouched services stay commented, and the services you have made changes to are uncommented.

### Step 2: generate manifests

Execute the following command from the root directory of this repository to generate manifests with the new resources:

```shell script
./overlay-generate-cluster.sh resources-update generated-cluster
```

After the command is executed without error outputs, you should be able to see the resources have been updated in the files inside the newly created `generated-cluster` folder.

### Step 3: apply the newly generateg manifests

Apply the generated manifests that contain the updated resources from the `generated-cluster` directory:

```shell script
kubectl apply -n ns-sourcegraph --prune -l deploy=sourcegraph -f generated-cluster --recursive
```
