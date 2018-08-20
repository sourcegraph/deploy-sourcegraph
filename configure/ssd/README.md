# SSDs

Using local SSDs dramatically speeds up many of Sourcegraph's services. Read your cloud provider's documentation for mouting local SSDs.

- [GCP](https://cloud.google.com/compute/docs/disks/local-ssd)
- [AWS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ssd-instance-store.html)

If you mount local SSDs on your nodes:

1. Change the `cache-ssd` volume to point to the absolute path of the SSD on each node.

   For example, GCP mounts the first SSD disk to `/mnt/disks/ssd0`, so the `cache-ssd` volume would be configured like this:

   ```yaml
   volumes:
     - hostPath:
         path: /mnt/disks/ssd0/pod-tmp
       name: cache-ssd
   ```

2. Deploy the provided `pod-tmp-gc` [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) to periodically clean up files in the SSD on each node. This is necessary because files on the SSDs are not automatically cleaned up if pods crash or are rescheduled which can cause the SSDs to fill up.

Here is a convenience script:

```bash
SSD_NODE_PATH=/mnt/disks/ssd0 # update this to reflect the absolute path where SSDs are mounted on each node

# Mount the SSDs path in each deployment
find . -name "*Deployment.yaml" -exec sh -c "cat {} | yj | jq '(.spec.template.spec.volumes | select(. != null) | .[] | select(.name == \"cache-ssd\")) |= (del(.emptyDir) + {hostPath: {path: \"$SSD_NODE_PATH/pod-tmp\"}})' | jy -o {}" \;

# Update pod-tmp-gc.DaemonSet.yaml with SSD_NODE_PATH
DS=configure/ssd/pod-tmp-gc.DaemonSet.yaml
cat $DS | yj | jq ".spec.template.spec.volumes = [{name: \"pod-tmp\", hostPath: {path: \"$SSD_NODE_PATH/pod-tmp\"}}]" | jy -o $DS

# Deploy everything
kubectl apply --prune -l deploy=sourcegraph -f base --recursive
kubectl apply --prune -l deploy=pod-tmp-gc -f configure/ssd --recursive
```
