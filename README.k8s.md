# Provisioning a Kubernetes cluster for Sourcegraph Data Center

<div class="alert alert-info">

**Security note:** If you intend to set this up as a production instance, we recommend you create the cluster in a VPC
or other secure network that restricts unauthenticated access from the public Internet. You can later expose the
necessary ports via an
[Internet Gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html) or equivalent
mechanism. Take care to secure your cluster in a manner that meets your organization's security requirements.

</div>

1.  Follow the instructions in the table below for provisioning a Kubernetes cluster on your infrastructure. Use the
    listed node type for your cluster.

  <div class="resources">
  <table class="table">
    <tr>
      <th colspan="3">Compute nodes</th>
    </tr>
    <tr><th>Provider</th><th>Node type</th><th>Boot/ephemeral disk size</th></tr>
    <tr><td><a href="https://kubernetes.io/docs/getting-started-guides/aws/">AWS EC2</a></td><td>m4.4xlarge</td><td>N/A</td></tr>
    <tr><td><a href="https://cloud.google.com/container-engine/docs/quickstart">Google Compute Engine</a></td><td>n1-standard-16</td><td>100 GB (default)</td></tr>
    <tr><td><a href="https://azure.microsoft.com/en-us/services/container-service/kubernetes/">Azure VM</a></td><td>D16 v3</td><td>100 GB (SSD preferred)</td></tr>
    <tr><td><a href="https://kubernetes.io/docs/setup/pick-right-solution/">Other</a></td><td>16 vCPU, 60 GiB memory per node</td><td>100 GB (SSD preferred)</td></tr>
  </table>
  </div>

2. Set
    up
    [Dynamic Provisioning](http://blog.kubernetes.io/2017/03/dynamic-provisioning-and-storage-classes-kubernetes.html)
    for persistent volumes.
* If you are using AWS or Google Cloud, you can skip this step as you will configure the Sourcegraph Helm chart later to
  include a storage class.
* If you are using Azure, we recommend creating a storage class that uses a Premium Managed Disk (SSD) with Premium_LRS.
* If you are using another cloud provider, refer to
  the [Kubernetes storage documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storageclasses)
  for the appropriate configuration. For performance reasons, SSDs are recommended.
* You can also manually provision the persistent volumes required by Sourcegraph Data Center. If that is the case,
  inspect all files ending in ".PersistentVolumeClaim.yaml" and ensure a volume is created that satisfies each claim.
