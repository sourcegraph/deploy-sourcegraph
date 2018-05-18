> Note to existing customers: if you are migrating from the old version of Data Center (configured
> using `sourcegraph-server-gen`), see [README.migrate.md](README.migrate.md).

# Sourcegraph Data Center (beta)

The Data Center deployment option for Sourcegraph is for organizations that need highly scalable, highly available code
search and intelligence for 10,000s of repositories and users. See [pricing](https://about.sourcegraph.com/pricing/),
and [contact us](https://about.sourcegraph.com/contact/sales) for more information.


## Install

Sourcegraph Data Center is deployed using Kubernetes. Before proceeding with these
instructions, [provision a Kubernetes](README.k8s.md) cluster on the infrastructure of your choice.

1. Install Tiller with RBAC privileges (the server-side counterpart to Helm) on your cluster:

   ```bash
   # Give Helm privileges to create RBAC resources.
   kubectl create serviceaccount --namespace kube-system tiller
   kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

   # Add Helm to your cluster using the created service account.
   helm init --service-account tiller
   ```

   * If installing Tiller is not an option, consult the instructions below for installing without Tiller.
   * If your Kubernetes environment does not permite RBAC, consult the instructions below for
     installing without RBAC.

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


### Install without RBAC

Sourcegraph Data Center communicates with the Kubernetes API for service discovery. It also has some janitor DaemonSets
that clean up temporary cache data. To do that we need to create RBAC resources. For details, see
Helm's
[Role-based Access Control documentation](https://github.com/kubernetes/helm/blob/v2.8.2/docs/rbac.md).

If using RBAC is not an option, you can set `"site.rbac": "disabled"` in your `values.yaml` and run `helm init` instead of
`helm init --service-account tiller` to install Tiller.


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

## Configuration

You can set additional values in `values.yaml` to configure your cluster. The default set of configuration values is
defined by the `values.yaml` file in *this* directory.

The configuration structure is split into two top-level fields:
- `site` defines application-level settings like code host integrations and authentication settings. The full set of
  options for `site` is described here: https://about.sourcegraph.com/docs/config/settings.
- `cluster` defines settings specific to the configuration of the Kubernetes cluster, like replica counts and CPU/memory
  allocation. Refer to the `values.yaml` in this repository to see which `cluster` fields can be overridden.

### Secrets

In some cases, it is desirable to set config fields to the contents of external files. The Helm CLI
supports this with the `--set` flag. For example, if you had an AWS Code Commit access key and a SSH
`known_hosts` file, you could use the following command to incorporate these values into the config
while deploying:

```bash
helm install --name sourcegraph -f values.yaml \
    --set "site.awsCodeCommit[0].secretAccessKey"="$(cat secretAccessKeyFile)" \
    --set "site.gitserverSSH.known_hosts"="$(cat known_hosts)" \
    https://github.com/sourcegraph/datacenter/archive/latest.tar.gz
```

## Update

To update to a new version of Sourcegraph Data Center, do the following:

1. Check the diff the update will apply to your Kubernetes cluster:
   ```bash
   helm diff upgrade -f values.yaml sourcegraph https://github.com/sourcegraph/datacenter/archive/$VERSION.tar.gz | less -R
   ```
   You can find a list of all version releases here: https://github.com/sourcegraph/deploy-sourcegraph/releases.
1. Apply the update:
   ```bash
   helm upgrade -f values.yaml sourcegraph https://github.com/sourcegraph/datacenter/archive/$VERSION.tar.gz
   ```
1. Check the health of the cluster after upgrade:
   ```bash
   kubectl get pods
   ```

### Rollback

```
helm history sourcegraph
helm rollback sourcegraph [REVISION]
```

## Contributing

We understand there is great diversity in Kubernetes environments from company to company, which is
why we've made this Helm chart open source. If there is a configuration point or Kubernetes option
you would like to add, we would love to incorporate it. Pull requests are reviewed and responded to
quickly, and let us know if you have any questions along the way!
