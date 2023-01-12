# # Quick start overlay for AWS EKS with EBS storage driver

For more information, please refer to our documentation on [configuring a storage class for your cloud provider](https://docs.sourcegraph.com/admin/deploy/kubernetes/configure#configure-a-storage-class).

This overlay:

- deploy Sourcegraph without monitoring services
- configure all services with size XS resources
- creates storage class for aws
- sets the storage class provisioner to `ebs.csi.aws.com`.

Use this overlay when using the **self-managed Amazon EBS Container Storage Interface driver**
