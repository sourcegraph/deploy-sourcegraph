# Scaling

Sourcegraph Data Center can be configured to scale to very large codebases and large numbers of users. If you notice
search latency is higher than desired, changing these parameters can yield a drastic improvement in performance.

<div class="alert-warn">

We are happy to help you tune Sourcegraph for maximum scalability. Contact us at <mailto:support@sourcegraph.com> for
help and best practices.

</div>

---

## Tuning replica counts for horizontal scalability

By default, your cluster has a single pod for each of `sourcegraph-frontend`, `searcher`, and `gitserver`. You can
increase the number of replicas of each of these services to handle higher scale.

We recommend setting the `sourcegraph-frontend`, `searcher`, and `gitserver` replica counts according to the following
table. See the following sections for how to modify your `config.json` file to apply these changes.

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

```json
  "deploymentOverrides": {
    "sourcegraph-frontend": {
      "replicas": 1,
      "containers": {
        "frontend": {
          "requests": {
            "cpu": "8",
            "memory": "8G"
          }
        }
      }
    },
    "searcher": {
      "replicas": 5
    }
    // ...
  },
  "gitserverCount": 3,
  "gitMaxConcurrentClones": 3,
  "repoListUpdateInterval": 15,
```

Notes:

*   After you change the `gitserver` replica count and run `helm upgrade`, you may get an error of the form `Error: UPGRADE FAILED: PersistentVolumeClaim "indexed-search" is invalid: spec: Forbidden: field is immutable after creation`. This occurs because the `indexed-search` volume's size depends on the `gitserver` replica count, and your
    Kubernetes cluster is running on infrastructure that does not support online volume resizing. To fix this, first `helm rollback sourcegraph N` (where `N` is the previous version number as reported by `helm history sourcegraph`), then run
    `kubectl delete deployment indexed-search && kubectl delete pvc indexed-search`, then run `helm upgrade sourcegraph ./helm-chart` again.
*   If your change requires `gitserver` pods to be restarted, and they are scheduled on another node when they restart,
    they may go offline for 60-90 seconds (and complain about a `Multi-Attach` error). This delay is caused by Kubernetes
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

```json
  "deploymentOverrides": {
    // ...
    "sourcegraph-frontend": {
      "replicas": 1
      "containers": {
        "frontend": {
          "requests": {
            "cpu": "4",
            "memory": "8G"
          }
        }
      }
    },
    "searcher": {
      "replicas": 1
      "containers": {
        "searcher": {
          "requests": {
            "cpu": "4",
            "memory": "24G"
          }
        }
      }
    },
    "gitserver-1": {
      "replicas": 1
      "containers": {
        "gitserver-1": {
          "requests": {
            "cpu": "4",
            "memory": "16G"
          }
        }
      }
    },
    "gitserver-2": {
      "replicas": 1
      "containers": {
        "gitserver-2": {
          "requests": {
            "cpu": "4",
            "memory": "16G"
          }
        }
      }
    }
  },
  "gitserverCount": 2,
```

---

## Configuring faster disk I/O for caches

Many parts of Sourcegraph's infrastructure benefit from using SSDs for caches. This is especially important for search
performance. By default, disk caches will use the Kubernetes
[hostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) and will be the same IO speed as the
underlying node's disk. Even if the node's default disk is a SSD, however, it is likely network-mounted rather than
local.

Some cloud providers optionally mount local SSDs. If you mount local SSDs on your nodes, add the following to your site
configuration to make Sourcegraph use the local SSDs:

```json
  "nodeSSDPath": "${SSD_MOUNT_PATH},
```

Replace `${SSD_MOUNT_PATH}` with the absolute directory path on the node where the local SSD is mounted.

For example, on Google Cloud Platform, add [Local SSDs](https://cloud.google.com/compute/docs/disks/local-ssd) to the
nodes running the searcher pods. Then add the following to your site config:

```json
  "nodeSSDPath": "/mnt/disks/ssd0",
```

---

## Cluster resource allocation guidelines

For production environments, we recommend the following resource allocations for the entire Kubernetes cluster, based on
the number of users in your organization:

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

## Using heterogeneous node pools in the Kubernetes cluster and specifying `nodeSelector`

If you're using multiple node pools in your Kubernetes cluster with different underlying node types, you can use
Kubernetes [`nodeSelector`](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) to ensure
that the cluster schedules pods on the most appropriate nodes.

This is useful if, for example, you have a very large monorepo that performs best when `gitserver` and `searcher` are on
very large nodes, but you want to use smaller nodes for `sourcegraph-frontend`, `repo-updater`, etc. In this example,
the configuration shown below uses `nodeSelector` in `deploymentOverrides` to specify these constraints.

```json
  "deploymentOverrides": {
    // ...
    "sourcegraph-frontend": {
      "nodeSelector": {
        "beta.kubernetes.io/instance-type": "m4.xlarge"
      }
    },
    "searcher": {
      "nodeSelector": {
        "beta.kubernetes.io/instance-type": "i3.2xlarge"
      }
    },
    "gitserver-1": {
      "nodeSelector": {
        "beta.kubernetes.io/instance-type": "i3.2xlarge"
      }
    },
    // ...
  },
```
