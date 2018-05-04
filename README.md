# Sourcegraph Data Center

The Data Center deployment option for Sourcegraph is for organizations that need highly scalable, highly available code
search and intelligence for 10,000s of repositories and users. See [pricing](https://about.sourcegraph.com/pricing/),
and [contact us](https://about.sourcegraph.com/contact/sales) for more information.

## Install

Sourcegraph Data Center is deployed using Kubernetes. Before proceeding with these
instructions, [provision a Kubernetes](README.k8s.md) cluster on the infrastructure of your choice.

1. Clone this repository.

1. Set the appropriate value for `opsconf.storageClass.create` in `conf.yaml`. If you set this field to anything other
   than `none`, you'll need to specify a value for `opsconf.storageClass.zone`, too. These options
   configure [Dynamic Volume Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/) in the
   Kubernetes cluster.

1. Edit the other fields in `conf.yaml` to set the configuration values of your choice. At the top level,
   `conf.yaml` has two fields:
   * `opsconf` contains cluster-level configuration. Consult
     the [scaling documentation](https://about.sourcegraph.com/docs/datacenter/scaling) for advice on tuning the CPU,
     memory, and replication options.
   * `conf` contains (for the most part) app-level configuration, which
     is [documented here](https://about.sourcegraph.com/docs/config/settings)

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

1. Install the Helm chart on your cluster. From the root of this directory, run the following:

   ```bash
   helm install -f constants.yaml -f conf.yaml --name sourcegraph .
   ```

   If you see the error `could not find a ready tiller pod`, wait a minute and try again.

1. Confirm that your deployment is launching by running `kubectl get pods`. If pods get stuck in `Pending` status, run
   `kubectl get pv` to check if the necessary volumes have been provisioned (you should see at least 4). Google Cloud
   Platform users may need to [request an increase in storage quota](https://cloud.google.com/compute/quotas).

1. When the deployment completes, you need to make the main web server accessible over the network to external users. To
   do so, connect port 30080 (or the value of `httpNodePort`) on the nodes in your cluster to the Internet. The easiest
   way to do this is to add a network rule that allows ingress traffic to port 30080 on at least one node (see
   [AWS Security Group rules](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html),
   [Google Cloud Platform Firewall rules](https://cloud.google.com/compute/docs/vpc/using-firewalls)). Sourcegraph
   should then be accessible at `$EXTERNAL_ADDR_OF_YOUR_NODE:30080`. For production environments, we recommend using an
   [Internet Gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html) (or equivalent)
   and configuring a load balancer in Kubernetes.

You will now see the Sourcegraph setup page when you visit the address of your instance. If you made your instance
accessible on the public Internet, make sure you secure it before adding your private repositories.


## Install without RBAC

Sourcegraph Data Center communicates with the Kubernetes API for service discovery. It also has some janitor DaemonSets
which clean up temporary cache data. To do that we need to create RBAC resources. Please see
Helm's [Role-based Access Control](https://github.com/kubernetes/helm/blob/v2.8.2/docs/rbac.md) documentation to find
out alternative approaches. Alternatively, if you are not using RBAC you can set `"conf.rbac": "disabled"` in
`conf.yaml` and run `helm init` instead of `helm init --service-account tiller` to install Tiller.

## Install without Tiller

If installing Tiller on your cluster is not an option, you can locally generate the Kubernetes configuration by running
the following from this directory:

```
helm template -f constants.yaml -f conf.yaml . --output-dir=generated
kubectl apply -R -f ./generated/sourcegraph/templates
```
