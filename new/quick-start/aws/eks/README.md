# # Quick start overlay for AWS EKS

For more information, please refer to our documentation on [configuring a storage class for your cloud provider](https://docs.sourcegraph.com/admin/deploy/kubernetes/configure#configure-a-storage-class).

This overlay:

- deploy Sourcegraph without monitoring services
- configure all services with size XS resources
- creates storage class for aws
- sets the provisioner to `kubernetes.io/aws-ebs`.

Use this provisioner when using the `Amazon EBS CSI Driver` as an Amazon EKS add-on
