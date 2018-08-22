# Migrating from Data Center 2.10.x or prior

Two things have changed in 2.11.x that require migration:

- Gitserver is now configured using [StatefulSet](#StatefulSet-migration).
- We have a [new deployment strategy](#Deployment-migration).

## Deferring migration

If you want to update to 2.11.x without performing any migrations, you can use 2.11.x-no-migration tags.

2.12.x will require this migration.

## Deployment migration

### The old way

2.10.x and prior was deployed by configuring `values.yaml` and using `helm` to generate the final yaml to deploy to a cluster.

There were a few downsides with this approach:

- `values.yaml` was a custom configuration format defined by us which implicitly made configuring certain Kubernetes settings special cases. We didn't want this to grow over time into an unmaintainable/unusable mess.
- If customers wanted to configure things not supported in `values.yaml`, then we would either need to add support or the customer would need to make further modifications to the generated yaml.
- Writing Go templates inside of yaml was error prone and hard to maintain. It was too easy to make a silly mistake and generate invalid yaml. Our editors could not help us because Go template logic made the yaml templates not valid yaml.
- It required using `helm` to generate templates even though some customers don't care to use `helm` to deploy the yaml.

### The new way

Our new approach is simpler and more flexible.

- We have removed our dependency on `helm`. It is no longer needed to generate templates, and we no longer recommend it as the easiest way to deploy our yaml to a cluster. You are still free to use `helm` to deploy to your cluster if you wish.
- Our base config is pure yaml which can be deployed directly to a cluster. It is easier for you to use, and also easier for us to maintain.
- You can configure our base yaml using whatever process best for you (Git ops, [Kustomize](https://github.com/kubernetes-sigs/kustomize), custom scripts, etc.). We provide [documentation and recipies for common customizations](configure.md).

### Steps

1. Set the reclaim policy for your existing deployments to `retained`.

   ```bash
   kubectl get pv -o json | jq --raw-output  ".items | map(select(.spec.claimRef.name)) | .[] | \"kubectl patch pv -p '{\\\"spec\\\":{\\\"persistentVolumeReclaimPolicy\\\":\\\"Retain\\\"}}' \\(.metadata.name)\"" | bash
   ```

2. (**Downtime starts here**) Delete the `sourcegraph` release from your cluster.

   ```bash
   helm del --purge sourcegraph
   ```

3. Remove `tiller` from your cluster

   ```bash
   helm reset
   ```

4. Update the old persistent volumes so they can be reused by the new deployment

   ```bash
   # mark all persistent volumes as claimable by the new deployments

   kubectl get pv -o json | jq --raw-output ".items | map(select(.spec.claimRef.name)) | .[] | \"kubectl patch pv -p '{\\\"spec\\\":{\\\"claimRef\\\":{\\\"uid\\\":null}}}' \\(.metadata.name)\"" | bash

   # rename the `gitserver` persistent volumes so that the new `gitserver` stateful set can re-use it

   kubectl get pv -o json | jq --raw-output ".items | map(select(.spec.claimRef.name | contains(\"gitserver-\"))) | .[] | \"kubectl patch pv -p '{\\\"spec\\\":{\\\"claimRef\\\":{\\\"name\\\":\\\"repos-gitserver-\\(.spec.claimRef.name | ltrimstr(\"gitserver-\") | tonumber - 1)\\\"}}}' \\(.metadata.name)\""  | bash
   ```

5. Proceed with the normal [installation steps](install.md).

   **Downtime ends once installation is complete**

## Assorted Notes

### Java Language Server

If you were previously configuring Gradle and Articfactory for the Java Language Server, you'll now need to set those options via environment variables instead of just the site configuration. [configure/xlang/java/README.md](../configure/xlang/java/README.md#Gradle-and-Aritfactory-configuration) contains information about the environment variables that you'll need to set.
