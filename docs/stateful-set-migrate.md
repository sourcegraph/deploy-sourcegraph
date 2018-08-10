# Gitserver Stateful Set Migration `(2.10.* -> 2.11.*+)`

Starting with Sourcegraph Data Center `2.11`, `gitserver`'s configuration has been migrated to use [StatefulSets](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/) instead of having multiple deployments and associated services.

In order be able to re-use your existing `gitserver`'s persistent volumes with [StatefulSets](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/) (so that you can avoid re-cloning existing repositories), your cluster's administrator will need to run the following manual steps before upgrading to `2.11` ([click here to read more about why this is necessary](https://github.com/kubernetes/kubernetes/issues/48609#issuecomment-314066616)):

## Steps

_Note that these steps will cause a small amount of unavoidable downtime._

_The following steps assume that you have [jq](https://stedolan.github.io/jq/) installed._

1. Make sure that the persistent volumes for your existing `gitserver` deployment are marked as `retained`

   ```bash
   kubectl get pv -o json | jq --raw-output  ".items | map(select(.spec.claimRef.name | contains(\"gitserver-\"))) | .[] | \"kubectl patch pv -p '{\\\"spec\\\":{\\\"persistentVolumeReclaimPolicy\\\":\\\"Retain\\\"}}' \\(.metadata.name)\"" | bash
   ```

2. (**downtime starts here**) Delete the `gitserver` deployment

   ```bash
   kubectl delete deploy -l type=gitserver
   ```

3. Delete the old `gitserver`'s persistent volume claims

   ```bash
   kubectl get pvc -o json | jq --raw-output ".items | map(select(.metadata.name | contains(\"gitserver-\"))) | .[] | \"kubectl delete pvc \\(.metadata.name)\"" | bash
   ```

4. Update `gitserver`'s persistent volumes so they can be reused by the new StatefulSet

   This step transforms the the old `claimRef.name`s that looked like `gitserver-1, gitserver-2, ...` into `repos-gitserver-0, repos-gitserver-1, ...`.

   ```bash
   kubectl get pv -o json | jq --raw-output ".items | map(select(.spec.claimRef.name | contains(\"gitserver-\"))) | .[] | \"kubectl patch pv -p '{\\\"spec\\\":{\\\"claimRef\\\":{\\\"uid\\\":null,\\\"name\\\":\\\"repos-gitserver-\\(.spec.claimRef.name | ltrimstr(\"gitserver-\") | tonumber - 1)\\\"}}}' \\(.metadata.name)\"" | bash
   ```

5. [Proceed with the normal upgrade steps](./update.md) (**downtime ends once upgrade is complete**)
