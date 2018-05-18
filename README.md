Note: This is pre-release software. Existing users of Sourcegraph Data Center should still refer to the installation
instructions here: https://about.sourcegraph.com/docs/datacenter/.

# Sourcegraph Data Center (pre-release)

The Data Center deployment option for Sourcegraph is for organizations that need highly scalable, highly available code
search and intelligence for 10,000s of repositories and users. See [pricing](https://about.sourcegraph.com/pricing/),
and [contact us](https://about.sourcegraph.com/contact/sales) for more information.


## Install

Sourcegraph Data Center is deployed using Kubernetes. Before proceeding with these
instructions, [provision a Kubernetes](README.k8s.md) cluster on the infrastructure of your choice.

1. Install Tiller (the server-side counterpart to Helm) on your cluster:

   ```bash
   # Give Helm privileges to create RBAC resources.
   kubectl create serviceaccount --namespace kube-system tiller
   kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

   # Add Helm to your cluster using the created service account.
   helm init --service-account tiller
   ```

   If installing Tiller is not an option, consult the instructions below for installing without Tiller. If your
   Kubernetes environment does not permite RBAC, consult the instructions below for installing without RBAC.

Azure AKS doesn't have RBAC https://github.com/Azure/AKS/issues/67

1. Create a `values.yaml` file with the following contents:

```
cluster:
  storageClass:
    create: {none,aws,gcp,managed-premium}
site: {}
```

Set the `create` field to "aws" or "gcp" if you are using AWS or Google Cloud. Set it to `managed-premium` if you're using Azure. Otherwise, set it to "none".
- If you set it to "aws" or "gcp", you also need to set `cluster.storageClass.zone` to the zone in which your cluster resides.
- If you set it to "none", you need to create
  a [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/) in your cluster with name "default"
  that defines the persistent volumes to be auto-provisioned in the cluster (we recommend low-latency SSDs). For more
  info, see the section below on [creating a storage class manually](#Creating-a-storage-class-manually).

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
which clean up temporary cache data. To do that we need to create RBAC resources. For details, see
Helm's
[Role-based Access Control documentation](https://github.com/kubernetes/helm/blob/v2.8.2/docs/rbac.md).

If using RBAC is not an option, you can set `"site.rbac": "disabled"` in `values.yaml` and run `helm init` instead of
`helm init --service-account tiller` to install Tiller.


### Install without Tiller

If installing Tiller is not an option, you can locally generate the Kubernetes configuration by running the following:

```
mkdir -p generated
helm template -f constants.yaml -f values.yaml . --output-dir=generated
kubectl apply -R -f ./generated/sourcegraph/templates
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
defined by the `values.yaml` file in this directory.

The configuration structure is split into two top-level fields:
- `site` defines application-level settings like code host integrations and authentication settings. The full set of
  options for `site` is described here: https://about.sourcegraph.com/docs/config/settings.
- `cluster` defines settings specific to the configuration of the Kubernetes cluster, like replica counts and CPU/memory
  allocation. All `cluster` settings are explicitly set in `values.yaml`, so refer to this file if you wish to override
  any of the default values.

## Update

Versions of Sourcegraph Data Center are released as tags in this Git repository. To update to a new version, fetch this
repository and check out the appropriate tag. To conveniently update to new versions of Data Center while additionally
tracking changes to your specific configuration (`values.yaml`), we recommend the following procedure:

1. Fork this repository.
1. Clone your fork and configure the local clone to have an additional remote `upstream` set to `https://github.com/sourcegraph/datacenter`.
1. Copy `defaults.yaml` to `values.yaml` and keep your custom configuration in `values.yaml`. Push changes to `master` in your fork.
1. On update:
   1. Run `git fetch upstream && git rebase upstream/master`. There should never be conflicts, because you have
      not modified any of the original files.
   1. Run `git checkout $VERSION && git cherry-pick upstream/master...master` to cherry-pick your `values.yaml` onto the
      tagged revision that contains the source files for the new version of Data Center.
   1. Install the `helm-diff` plugin (`helm plugin install https://github.com/databus23/helm-diff`). Then run `helm diff
      -f constants.yaml -f values.yaml sourcegraph .` to display the update diff.
   1. Run `helm update -f constants.yaml -f values.yaml sourcegraph .`.
   1. After updating, run `watch kubectl get pods -o wide` to verify the health of the cluster.

If you need to make changes to any of the existing files in this repository, please upstream your changes--pull requests
are very welcome!

### Rollback

```
helm history sourcegraph
helm rollback sourcegraph [REVISION]
```
