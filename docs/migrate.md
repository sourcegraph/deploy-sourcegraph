# Migrating from Data Center 2.10.x or prior

Two things have changed in 2.11.x that require migration:

- Gitserver is now configured using [StatefulSet](#StatefulSet-migration).
- We have a [new deployment strategy](#Deployment-migration).

## Defering migration

If you want to update to 2.11.x without performing any migrations, you can use 2.11.x-no-migration tags.

2.12.x will require both migrations.

## StatefulSet migration

`gitserver`'s configuration has been migrated to use [StatefulSet](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/) instead of having multiple deployments and associated services.

In order be able to re-use your existing `gitserver`'s persistent volumes with [StatefulSet](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/) (so that you can avoid re-cloning existing repositories), you will need to run the following manual steps before upgrading to 2.11.x ([click here to read more about why this is necessary](https://github.com/kubernetes/kubernetes/issues/48609#issuecomment-314066616)):

_Note that these steps will cause a small amount of unavoidable downtime._

_The following steps assume that you have [jq](https://stedolan.github.io/jq/) installed._

1. Set the reclaim policy for your existing `gitserver` deployments to `retained`

   ```bash
   kubectl get pv -o json | jq --raw-output  ".items | map(select(.spec.claimRef.name | contains(\"gitserver-\"))) | .[] | \"kubectl patch pv -p '{\\\"spec\\\":{\\\"persistentVolumeReclaimPolicy\\\":\\\"Retain\\\"}}' \\(.metadata.name)\"" | bash
   ```

2. **Downtime starts here**

   Delete the `gitserver` deployment

   ```bash
   kubectl delete deploy -l type=gitserver
   ```

3. Delete the old `gitserver`'s persistent volume claims

   ```bash
   kubectl get pvc -o json | jq --raw-output ".items | map(select(.metadata.name | contains(\"gitserver-\"))) | .[] | \"kubectl delete pvc \\(.metadata.name)\"" | bash
   ```

4. Update `gitserver` persistent volumes so they can be reused by the new StatefulSet

   This step transforms the the old `claimRef.name`s that looked like `gitserver-1, gitserver-2, ...` into `repos-gitserver-0, repos-gitserver-1, ...`.

   ```bash
   kubectl get pv -o json | jq --raw-output ".items | map(select(.spec.claimRef.name | contains(\"gitserver-\"))) | .[] | \"kubectl patch pv -p '{\\\"spec\\\":{\\\"claimRef\\\":{\\\"uid\\\":null,\\\"name\\\":\\\"repos-gitserver-\\(.spec.claimRef.name | ltrimstr(\"gitserver-\") | tonumber - 1)\\\"}}}' \\(.metadata.name)\"" | bash
   ```

5. Proceed with the normal [update steps](update.md).

   **Downtime ends once upgrade is complete**

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

TODO(nick,geoffrey)

- uninstall tiller (or if you want to keep using tiller)
- old cluster services doesn't have `deploy: sourcegraph` labels
