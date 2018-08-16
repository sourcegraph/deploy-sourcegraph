# SSDs

Many parts of Sourcegraph's infrastructure benefit from using SSDs for caches. This is especially important for search / language server performance. By default, disk caches will use the Kubernetes `hostPath` and will be the same IO speed as the underlying node's disk. Even if the node's default disk is a SSD, however, it is likely network-mounted rather than local.

## Using SSDs with Deployments

The deployments that refer to the `cache-ssd` volume are capable of using SSDs to boost their performance. Some cloud providers optionally mount local SSDs. If you mount local SSDs on your nodes, you can change the `cache-ssd` volume from:

```yaml
 volumes:
    ...

    - emptyDir: {}
    name: cache-ssd
```

to:

```yaml
 volumes:
    ...

    - hostPath:
        path: ${SSD_MOUNT_PATH}/pod-tmp
    name: cache-ssd
```

Replace `${SSD_MOUNT_PATH}` with the absolute directory path on the node where the local SSD is mounted.

For example, on Google Cloud Platform, add Local SSDs to the nodes running the searcher pods. Then change the following fields in your deployment :

```yaml
 volumes:
    ...

    - hostPath:
        path: /mnt/disks/ssd0/pod-tmp
    name: cache-ssd
```

## `pod-tmp-gc`

Sometimes, the pods that access the SSD aren't able to clean up after themselves. This can
lead to filling up the disk. We offer a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) `pod-tmp-gc` that runs on each node and periodically cleans up those files.

You can deploy it to your cluster by:

1. Replacing `${SSD_MOUNT_PATH}` in [`pod-tmp-gc.DaemonSet.yaml`](pod-tmp-gc/pod-tmp-gc.DaemonSet.yaml) with with the absolute directory path on the node where the local SSD is mounted.

For example you'd specify the following for a cluster running on GCP:

```yaml
volumeMounts:
  - mountPath: /mnt/disks/ssd0/pod-tmp
    name: pod-tmp
```

2. Runnning `kubectl apply -R -f ./pod-tmp-gc/` to deploy it to your cluster
