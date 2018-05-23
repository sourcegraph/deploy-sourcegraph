# Installation

## Requirements

*   <a href="https://kubernetes.io/docs/tasks/tools/install-kubectl/" target="_blank">kubectl</a>, v1.8.6 or later
*   <a href="https://docs.helm.sh/using_helm/#installing-helm" target="_blank">Helm</a>, v2.9.1 or later
*   Access to server infrastructure on which you can create a Kubernetes cluster (see
    [resource allocation guidelines](scale.md))

## Install

> **Note:** Sourcegraph sends performance and usage data to Sourcegraph to help us make our product
> better for you. The data sent does NOT include any source code or file data (including URLs that
> might implicitly contain this information).  You can view traces and disable telemetry in the site
> admin area on the server.

Sourcegraph Data Center is deployed using Kubernetes. Before proceeding with these
instructions, [provision a Kubernetes](k8s.md) cluster on the infrastructure of your choice. Make
sure you have [configured `kubectl` to access your cluster](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/).


1. Install Tiller with RBAC privileges (the server-side counterpart to Helm) on your cluster:

   ```bash
   # Give Helm privileges to create RBAC resources.
   kubectl create serviceaccount --namespace kube-system tiller
   kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

   # Add Helm to your cluster using the created service account.
   helm init --service-account tiller
   ```

   * If installing Tiller is not an option, consult the instructions below
     for [installing without Tiller](#install-without-tiller).
   * If your Kubernetes environment does not permit RBAC, consult the instructions below
     for [installing without RBAC](#install-without-rbac).

1. Create a `values.yaml` file with the following contents:

   ```
   cluster:
     storageClass:
       create: {none,aws,gcp}
       name: $NAME
       zone: $ZONE
   site: {}
   ```

   - If using Google Cloud, set `cluster.storageClass.create` to `gcp` and
     `cluster.storageClass.zone` to the zone of your cluster (e.g., `us-west1-a`). Delete the
     `cluster.storageClass.name` line.
   - If using AWS, set `cluster.storageClass.create` to `aws` and `cluster.storageClass.zone` to the
     zone of your cluster (e.g., `us-east-1a`). Delete the `cluster.storageClass.name` line.
   - If using Azure, set `cluster.storageClass.create` to `none` and set `cluster.storageClass.name`
     to `managed-premium`. Delete the `cluster.storageClass.zone` line.
   - If using anything else OR if you would prefer to provide your own storage class, set
     `cluster.storageClass.create` to `none` and delete `cluster.storageClass.name` and
     `cluster.storageClass.zone`. Now create
     a [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/) in your
     Kubernetes cluster with name "default". We recommend that the storage class use SSDs as the
     underlying disk type. For more info, see the section below on "creating a storage class
     manually".

1. Install the Helm chart to your cluster:

   ```bash
   helm install --name sourcegraph -f values.yaml https://github.com/sourcegraph/datacenter/archive/latest.tar.gz
   ```

   If you see the error `could not find a ready tiller pod`, wait a minute and try again.

1. Confirm that your deployment is launching by running `kubectl get pods`. If pods get stuck in `Pending` status, run
   `kubectl get pv` to check if the necessary volumes have been provisioned (you should see at least 4). Google Cloud
   Platform users may need to [request an increase in storage quota](https://cloud.google.com/compute/quotas).

1. When the deployment completes, you need to make the main web server accessible over the network to external users. To
   do so, connect port 30080 (or the value of `httpNodePort` in the site config) on the nodes in the cluster to the
   Internet. The easiest way to do this is to add a network rule that allows ingress traffic to port 30080 on at least
   one node
   (see
   [AWS Security Group rules](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html),
   [Google Cloud Platform Firewall rules](https://cloud.google.com/compute/docs/vpc/using-firewalls)). Sourcegraph
   should then be accessible at `$EXTERNAL_ADDR_OF_YOUR_NODE:30080`. For production environments, we recommend using
   an [Internet Gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html) (or
   equivalent) and configuring a load balancer in Kubernetes.

You will now see the Sourcegraph setup page when you visit the address of your instance. If you made your instance
accessible on the public Internet, make sure you secure it before adding your private repositories.


### Add language servers for code intelligence

> Code intelligence is a [paid upgrade](https://about.sourcegraph.com/pricing/) on top of the Data
> Center deployment option. After following these instructions to confirm it
> works, [buy code intelligence](https://about.sourcegraph.com/contact/sales).

[Code intelligence](https://about.sourcegraph.com/docs/code-intelligence) provides advanced code
navigation and cross-references for your code on Sourcegraph.

To enable code intelligence, add a `site.langservers` property to your `values.yaml` file specifying which
language servers to run (omitting languages you don't want):

```yaml
# values.yaml

site: {
    "langservers": [
        { "language": "go" },
        { "language": "javascript" },
        { "language": "typescript" },
        { "language": "python" },
        { "language": "java" },
        { "language": "php" }
    ]
}
```

After modifying `values.yaml`, update your cluster:

```bash
helm upgrade -f values.yaml sourcegraph https://github.com/sourcegraph/datacenter/archive/$VERSION.tar.gz
```

For more information,
* Refer to the [examples](../examples) directory for an example of a cluster config with code
  intelligence enabled.
* See the [language-specific docs](https://about.sourcegraph.com/docs/code-intelligence) for
  configuring specific languages.
* [Contact us](mailto:support@sourcegraph.com) with questions or problems relating to code
  intelligence.

### Additional configuration

You can set additional fields in `values.yaml` to configure your cluster to index your code host,
add custom search scopes, enable TLS, turn on SSO, and more. The default set of configuration values
is defined by the `values.yaml` file in *this* directory.

The structure of `values.yaml` is split into two top-level fields:
- `site` defines application-level settings like code host integrations and authentication settings. The full set of
  options for `site` is described here: https://about.sourcegraph.com/docs/config/site.
- `cluster` defines settings specific to the configuration of the Kubernetes cluster, like replica counts and CPU/memory
  allocation. Refer to the `values.yaml` in this repository to see which `cluster` fields can be overridden.


### Troubleshooting

See the [Troubleshooting page](troubleshoot.md).


### Install without RBAC

Sourcegraph Data Center communicates with the Kubernetes API for service discovery. It also has some janitor DaemonSets
that clean up temporary cache data. To do that we need to create RBAC resources. For details, see
Helm's
[Role-based Access Control documentation](https://github.com/kubernetes/helm/blob/v2.8.2/docs/rbac.md).

If using RBAC is not an option, then
* Set `"site.rbac": "disabled"` in your `values.yaml`
* Run `helm init` instead of `helm init --service-account tiller` to install Tiller.


### Install without Tiller

If installing Tiller is not an option, you can locally generate the Kubernetes configuration by running the following:

```
mkdir -p generated
wget https://github.com/sourcegraph/datacenter/archive/latest.tar.gz && helm template -f values.yaml latest.tar.gz --output-dir=generated
kubectl apply -R -f generated/sourcegraph/templates
```

### Creating a storage class manually

If `cluster.storageClass.create` is set to `none`, then you will need to create a storage class manually:

1. Create a file called `storage-class.yaml` that meets
   the [requirements described in the Kubernetes docs](https://kubernetes.io/docs/concepts/storage/storage-classes/).
   The name of the storage class should match the name set in `cluster.storageClass.name` ("default" by default). We
   recommend specifying SSDs as the disk type if possible.
1. Run `kubectl apply -f storage-class.yaml`.
1. You should see the storage class appear when you run `kubectl get storageclass`.

After installing the Sourcegraph Helm chart, you should see persistent volume claims (`kubectl get pvc`) bound to
volumes provisioned using this storage class.

### Secrets

In some cases, it is desirable to set config fields to the contents of external files. The Helm CLI
supports this with the `--set` flag. For example, if you had an AWS Code Commit access key and a SSH
`known_hosts` file, you could use the following command to incorporate these values into the config
while deploying:

```bash
helm install --name sourcegraph -f values.yaml \
    --set "site.awsCodeCommit[0].secretAccessKey"="$(cat secretAccessKeyFile)" \
    --set "cluster.gitserver.ssh.known_hosts"="$(cat known_hosts)" \
    https://github.com/sourcegraph/datacenter/archive/latest.tar.gz
```
