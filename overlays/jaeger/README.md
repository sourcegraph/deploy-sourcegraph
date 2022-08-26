# Kustomize Overlay - Jaeger

This overlay enables a Jaeger backend, consisting of its [Collector](https://www.jaegertracing.io/docs/1.37/architecture/#collector) and [Query](https://www.jaegertracing.io/docs/1.37/architecture/#query) components. It also [configures](https://github.com/sourcegraph/sourcegraph/blob/main/docker-images/opentelemetry-collector/configs/jaeger.yaml) the `otel-collector` to export to this Jaeger instance.

### Step 1: update namespace

Update the namespace field with your namespace in the `kustomization.yaml` file

> Note: Uses `ns-sourcegraph` as namespace by default

### Step 2: generate manifests

Execute the following command from the root directory of this repository to generate manifests with the new resources:

```shell script
./overlay-generate-cluster.sh jaeger generated-cluster
```

After the command is executed without error outputs, you should be able to see the resources have been updated in the files inside the newly created `generated-cluster` folder.

### Step 3: apply the newly generated manifests

Apply the generated manifests that contain the updated resources from the `generated-cluster` directory:

```shell script
kubectl apply -n ns-sourcegraph --prune -l deploy=sourcegraph -f generated-cluster --recursive
```
