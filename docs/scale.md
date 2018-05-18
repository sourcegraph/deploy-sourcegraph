# Scaling

Sourcegraph Data Center can be configured to scale to very large codebases and large numbers of
users. If you notice latency for search or code intelligence is higher than desired, changing these
parameters can yield a drastic improvement in performance.

> For assistance scaling and tuning Sourcegraph, contact us
> at <mailto:support@sourcegraph.com>. We're happy to help!


## Tuning replica counts for horizontal scalability

By default, your cluster has a single pod for each of `sourcegraph-frontend`, `searcher`, and `gitserver`. You can
increase the number of replicas of each of these services to handle higher scale.

We recommend setting the `sourcegraph-frontend`, `searcher`, and `gitserver` replica counts according to the following
table. See the following sections for how to modify your `values.yaml` file to apply these changes.

<div class="table">

| Users      | Number of `sourcegraph-frontend` replicas |
| ---------- | ----------------------------------------- |
| 10-500     | 1                                         |
| 500-2000   | 2                                         |
| 2000-4000  | 6                                         |
| 4000-10000 | 18                                        |
| 10000+     | 28                                        |

<br>

| Repositories | Number of `searcher` replicas        |
| ------------ | ------------------------------------ |
| 1-20         | 1                                    |
| 20-50        | 2                                    |
| 50-200       | 3-5                                  |
| 200-1k       | 5-10                                 |
| 1k-5k        | 10-15                                |
| 5k-25k       | 20-40                                |
| 25k+         | 40+ (contact us for scaling advice)  |
| Monorepo     | 1-25 (contact us for scaling advice) |

<br>

| Repositories | Number of `gitserver` replicas      |
| ------------ | ----------------------------------- |
| 1-200        | 1                                   |
| 200-500      | 2                                   |
| 500-1000     | 3                                   |
| 1k-5k        | 4-8                                 |
| 5k-25k       | 8-20                                |
| 25k+         | 20+ (contact us for scaling advice) |
| Monorepo     | 1 (contact us for scaling advice)   |

</div>

---

## Improving performance with a large number of repositories

When you're using Sourcegraph with many repositories (100s-10,000s), the most important parameters to tune are:

*   `sourcegraph-frontend` CPU/memory resource allocations
*   `searcher` replica count
*   `gitserver` replica count
*   `gitMaxConcurrentClones`, because `git clone` and `git fetch` operations are IO- and CPU-intensive
*   `repoListUpdateInterval` (in minutes), because each interval triggers `git fetch` operations for all repositories

Consult the tables above for the recommended replica counts to use. **Note:** the `gitserver` replica count is specified
differently from the replica counts for other services; this will be standardized in a future release (in a
backward-compatible manner).

The following configuration fragment shows a sample configuration for using Sourcegraph with a large number of
repositories:

```yaml
cluster:
  frontend:
    replicas: 4
    containers:
      frontend:
        limits:
          cpu: "8"
          memory: 8G
        requests:
          cpu: "8"
          memory: 8G
  searcher:
    replicas: 8
  gitserver:
    shards: 3
```

Notes:

*   After you change the `gitserver` shard count and run `helm upgrade`, you may see an error of the
    form `Error: UPGRADE FAILED: PersistentVolumeClaim "indexed-search" is invalid: spec: Forbidden:
    field is immutable after creation`. This occurs because the `indexed-search` volume's size
    depends on the `gitserver` replica count, and your Kubernetes cluster is running on
    infrastructure that does not support online volume resizing. To fix this, first `helm rollback
    sourcegraph N` (where `N` is the previous version number as reported by `helm history sourcegraph`).
    Then run `kubectl delete deployment indexed-search && kubectl delete pvc
    indexed-search` and `helm upgrade sourcegraph ./helm-chart` again.
*   If your change requires `gitserver` pods to be restarted and they are scheduled on another node when they restart,
    they may go offline for 60-90 seconds (and temporarily show a `Multi-Attach` error). This delay is caused by Kubernetes
    detaching and reattaching the volume. Mitigation steps depend on your cloud provider; contact us for advice.

---

## Improving performance with large monorepos

When you're using Sourcegraph with a large monorepo (or several large monorepos), the most important parameters to tune
are:

*   `sourcegraph-frontend` CPU/memory resource allocations
*   `searcher` CPU/memory resource allocations (allocate enough memory to hold all non-binary files in your repositories)
*   `gitserver` CPU/memory resource allocations (allocate enough memory to hold your Git packed bare repositories)

<!-- * `indexed-search` CPU/memory resource allocations? TODO(sqs) -->

**Note:** the `gitserver` resource allocations are specified differently (one per replica) from the those for other
services; this will be standardized in a future release (in a backward-compatible manner).

The following configuration fragment shows a sample configuration for using Sourcegraph with multi-gigabyte monorepo:

```yaml
cluster:
  frontend:
    replicas: 1
    containers:
      frontend:
        limits:
          cpu: "4"
          memory: 8G
        requests:
          cpu: "4"
          memory: 8G
  searcher:
    replicas: 1
    containers:
      searcher:
        limits:
          cpu: "4"
          memory: 24G
        requests:
          cpu: "4"
          memory: 24G
  gitserver:
    shards: 1
    containers:
      gitserver:
        limits:
          cpu: "4"
          memory: 16G
        requests:
          cpu: "4"
          memory: 16G
```


---

## Configuring faster disk I/O for caches

Many parts of Sourcegraph's infrastructure benefit from using SSDs for caches. This is especially
important for search performance. By default, disk caches will use the
Kubernetes [hostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) and will be the
same IO speed as the underlying node's disk. Even if the node's default disk is a SSD, however, it
is likely network-mounted rather than local.

Some cloud providers optionally mount local SSDs. If you mount local SSDs on your nodes, add the
following to your site configuration to make Sourcegraph use the local SSDs:

```yaml
site: {
  "nodeSSDPath": "${SSD_MOUNT_PATH}",
}
```

Replace `${SSD_MOUNT_PATH}` with the absolute directory path on the node where the local SSD is mounted.

For example, on Google Cloud Platform,
add [Local SSDs](https://cloud.google.com/compute/docs/disks/local-ssd) to the nodes running the
searcher pods. Then add the following to your site config:

```yaml
site: {
  "nodeSSDPath": "/mnt/disks/ssd0",
}
```

---

## Cluster resource allocation guidelines

For production environments, we recommend the following resource allocations for the entire
Kubernetes cluster, based on the number of users in your organization:

<div class="table">

| Users        | vCPUs | Memory | Attached Storage | Root Storage |
| ------------ | ----- | ------ | ---------------- | ------------ |
| 10-500       | 10    | 24 GB  | 500 GB           | 50 GB        |
| 500-2,000    | 16    | 48 GB  | 500 GB           | 50 GB        |
| 2,000-4,000  | 32    | 72 GB  | 900 GB           | 50 GB        |
| 4,000-10,000 | 48    | 96 GB  | 900 GB           | 50 GB        |
| 10,000+      | 64    | 200 GB | 900 GB           | 50 GB        |

</div>

---

<a id="node-selector">

## Using heterogeneous node pools with `nodeSelector`

If you're using multiple node pools in your Kubernetes cluster with different underlying node types,
you can
use
[node selectors](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector)
to ensure that the cluster schedules pods on the most appropriate nodes.

This is useful if, for example, you have a very large monorepo that performs best when `gitserver`
and `searcher` are on very large nodes, but you want to use smaller nodes for
`sourcegraph-frontend`, `repo-updater`, etc. Node selectors can also be useful to ensure fast
updates by ensuring certain pods are assigned to specific nodes, preventing the need for manual pod
shuffling.

To use node selectors, do the following:

1. Apply the label to the desired nodes in the cluster. For example, to reserve one of the nodes in
   the cluster for the `indexed-search` pod, run the following:

   ```bash
   kubectl label nodes <node-name> node_type=indexed-search
   ```

   Then run the following for all the other nodes in the cluster:

   ```bash
   kubectl label nodes <node-name> node_type=regular
   ```

   If either of these fails with an "invalid command" error, you are likely using an older version
   of Kubernetes and can refer to
   the
   [legacy instructions for applying a label to a node](https://github.com/kubernetes/kubernetes/blob/a053dbc313572ed60d89dae9821ecab8bfd676dc/examples/node-selection/README.md).

1. Set `cluster.${DEPLOYMENT}.nodeSelector` to the appropriate map of selectors for each deployment in `values.yaml`:

   ```yaml
   cluster:
     frontend:
       nodeSelector:
         node_type: regular
     searcher:
       nodeSelector:
         node_type: regular
     symbols:
       nodeSelector:
         node_type: regular
     gitserver:
       nodeSelector:
         node_type: regular
     indexedSearch:
       nodeSelector:
         node_type: indexed-search
     lspProxy:
       nodeSelector:
         node_type: regular
     xlangGo:
       nodeSelector:
         node_type: regular
     xlangJava:
       nodeSelector:
         node_type: regular
     xlangJavascriptTypescript:
       nodeSelector:
         node_type: regular
     xlangPython:
       nodeSelector:
         node_type: regular
     xlangPHP:
       nodeSelector:
         node_type: regular
   ```

   Note: you must apply a `nodeSelector` label to every deployment in order to ensure that no
   non-`indexed-search` deployment pods are ever assigned to the `index-search`-labeled node.

In addition to user-defined labels, Kubernetes has a
some
[built-in labels](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#interlude-built-in-node-labels),
which you can use if you have a heterogeneous cluster where you wish certain pods to be assigned to
certain types of nodes. For example, if you had a heterogeneous AWS cluster with `m4.2xlarge` and
`m4.10xlarge` instances and you wished to reserve the `m4.10xlarge` instances for `indexed-search`,
you could add the following to `values.yaml`:

   ```yaml
   cluster:
     frontend:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
     searcher:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
     symbols:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
     gitserver:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
     indexedSearch:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.10xlarge
     lspProxy:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
     xlangGo:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
     xlangJava:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
     xlangJavascriptTypescript:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
     xlangPython:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
     xlangPHP:
       nodeSelector:
         beta.kubernetes.io/instance-type: m4.2xlarge
   ```

Again, you must apply a `nodeSelector` label to every deployment in order to ensure that no
non-`indexed-search` pods are ever assigned to the `m4.10xlarge` nodes.

The [examples directory](/examples) contains a cluster config that uses node selectors.
