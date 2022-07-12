# Kustomize Overlay - Envoy Filter

This overlay applies a new envoy filter to enable HTTP trailers for gitserver to resolve the following error message caused by enabling service mesh:

```
"git command [git rev-parse HEAD] failed (stderr: \"\"): strconv.Atoi: parsing \"\"
```

### Step 1: update namespace

Update the namespace field with your namespace in the `kustomization.yaml` file

> Note: Uses `ns-sourcegraph` as namespace by default

### Step 2: generate manifests

Execute the following command from the root directory of this repository to generate manifests with the new resources:

```shell script
./overlay-generate-cluster.sh envoy generated-cluster
```

After the command is executed without error outputs, you should be able to see the resources have been updated in the files inside the newly created `generated-cluster` folder.

### Step 3: apply the newly generateg manifests

Apply the generated manifests that contain the updated resources from the `generated-cluster` directory:

```shell script
kubectl apply -n ns-sourcegraph --prune -l deploy=sourcegraph -f generated-cluster --recursive
```
