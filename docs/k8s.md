# Provisioning a Kubernetes cluster

<div class="alert alert-info">

**Security note:** If you intend to set this up as a production instance, we recommend you create the cluster in a VPC
or other secure network that restricts unauthenticated access from the public Internet. You can later expose the
necessary ports via an
[Internet Gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html) or equivalent
mechanism. Take care to secure your cluster in a manner that meets your organization's security requirements.

</div>

Follow the instructions linked in the table below to provision a Kubernetes cluster for the
infrastructure provider of your choice, using the recommended node and list types in the
table.

> Note: Sourcegraph Data Center can run on any Kubernetes cluster, so if your infrastructure
> provider is not listed, see the "Other" row. Pull requests to add rows for more infrastructure
> providers are welcome!

<div class="resources">
<table class="table">
  <tr>
    <th colspan="3">Compute nodes</th>
  </tr>
  <tr><th>Provider</th><th>Node type</th><th>Boot/ephemeral disk size</th></tr>
  <tr><td><a href="/docs/k8s.eks.md">Amazon EKS (better than plain EC2)</a> </td><td>m5.4xlarge</td><td>N/A</td></tr>
  <tr><td><a href="https://kubernetes.io/docs/getting-started-guides/aws/">AWS EC2</a></td><td>m5.4xlarge</td><td>N/A</td></tr>
  <tr><td><a href="https://cloud.google.com/kubernetes-engine/docs/quickstart">Google Kubernetes Engine (GKE)</a></td><td>n1-standard-16</td><td>100 GB (default)</td></tr>
  <tr><td><a href="/docs/k8s.azure.md">Azure</a> </td><td>D16 v3</td><td>100 GB (SSD preferred)</td></tr>
  <tr><td><a href="https://kubernetes.io/docs/setup/pick-right-solution/">Other</a></td><td>16 vCPU, 60 GiB memory per node</td><td>100 GB (SSD preferred)</td></tr>
</table>
</div>
