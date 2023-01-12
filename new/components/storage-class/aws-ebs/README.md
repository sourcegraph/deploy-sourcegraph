# # Storageclass Component for AWS EBS

For more information, please refer to our documentation on [configuring a storage class for your cloud provider](https://docs.sourcegraph.com/admin/deploy/kubernetes/configure#configure-a-storage-class).

This component:

- creates storage class for aws
- sets the provisioner to `ebs.csi.aws.com`.

Use this provisioner when using the self-managed Amazon EBS Container Storage Interface driver
