# WIP - Generate endpoints locally

An example of using this generator plugin in an overlay to generate service endpoints based on replica counts.

1. Update replica numbers in `endpoint-generator.yaml`

2. Run

```bash
 kustomize build --enable-alpha-plugins --enable-exec new/plugins/example -o new/generated-cluster.yaml
```

3. Look for the ConfigMap named `sourcegraph-endpoints-map` inside `new/generated-cluster.yaml` to see the generated endpoints

## Issue

Inputting the numbers in `endpoint-generator.yaml` does not update the replica counts for the related services. They must be updated using the replicas component at the moment
