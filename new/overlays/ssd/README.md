# SSDs

Using local SSDs dramatically speeds up many of Sourcegraph's services. Even if the cluster's default storage class uses SSDs, it's likely network-mounted rather than local. Read your cloud provider's documentation for mouting local SSDs.

- [GCP](https://cloud.google.com/compute/docs/disks/local-ssd)
- [AWS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ssd-instance-store.html)

## Overview

If you mount local SSDs on your nodes, you can refer to this overlay that that includes:

1. A component `ssd` that create resources to use the SSDs
2. A configMapGenerator where you will need to provide the mount path for the SSD volume, which is an absolute path of the SSD on each node, using the [.sourcegraph_config.env](.sourcegraph_config.env) file.
3. A transformer is used to update the SSD Damonset we created in step 1 with the value you provided in step 2

# How to use

Update the SSD_NODE_PATH value in the [.sourcegraph_config.env](.sourcegraph_config.env) file under the configMapGenerator section with the absolute path to your SSD on each node.

## Example

For example, GCP mounts the first SSD disk to `/mnt/disks/ssd0`, so we would need to update the mountPath value to `/mnt/disks/ssd0` in our SSD Damonset.

To do that in this overlay, update the SSD_NODE_PATH value inside the .sourcegraph_config.env file:

```
SSD_NODE_PATH=/mnt/disks/ssd0
```

The `components/ssd` must be included in your `kustomization.yaml` to work properly.
