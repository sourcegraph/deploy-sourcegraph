# Configuring Sourcegraph

Sourcegraph Data Center is configured by applying Kubernetes YAML files and simple `kubectl` commands.

Since everything is vanilla Kubernetes, you can configure Sourcegraph as flexibly as you need to meet the requirements of your deployment environment.
We provide simple instructions for common things like setting up TLS, enabling code intelligence, and exposing Sourcegraph to external traffic below.

## Fork this repository

We recommend you fork this repository to track your configuration changes in Git.
This will make upgrades far easier and is a good practice not just for Sourcegraph, but for any Kubernetes application.

1. Create a fork of this repository.

   - The fork can be public **unless** you plan to store secrets in the repository itself.
   - We recommend not storing secrets in the repository itself and these instructions document how.

1. Create a release branch to track all of your customizations to Sourcegraph.
   When you upgrade Sourcegraph Data Center, you will merge upstream into this branch.

   ```bash
   git checkout HEAD -b release
   ```

   If you followed the installation instructions, `HEAD` should point at the Git tag you've deployed to your running Kubernetes cluster.

1. Commit customizations to your release branch:

   - Commit manual modifications to Kubernetes YAML files.
   - Commit commands that should be run on every update (e.g. `kubectl apply`) to [./kubectl-apply-all.sh](../kubectl-apply-all.sh).
   - Commit commands that generally only need to be run once per cluster to (e.g. `kubectl create secret`, `kubectl expose`) to [./create-new-cluster.sh](../create-new-cluster.sh).

## Dependencies

Configuration steps in this file depend on [jq](https://stedolan.github.io/jq/),
[yj](https://github.com/sourcegraph/yj) and [jy](https://github.com/sourcegraph/jy).

## Table of contents

### Common configuration

- [Configure a storage class](#configure-a-storage-class)
- [Configure network access](#configure-network-access)
- [Update site configuration](#update-site-configuration)
- [Configure TLS/SSL](#configure-tlsssl)
- [Configure repository cloning via SSH](#configure-repository-cloning-via-ssh)
- [Configure language servers](#configure-language-servers)
- [Configure SSDs to boost performance](../configure/ssd/README.md).
- [Increase memory or CPU limits](#increase-memory-or-cpu-limits)

### Less common configuration

- [Configure gitserver replica count](#configure-gitserver-replica-count)
- [Configure indexed-search replica count](#configure-indexed-search-replica-count)
- [Assign resource-hungry pods to larger nodes](#assign-resource-hungry-pods-to-larger-nodes)
- [Configure Alertmanager](../configure/prometheus/alertmanager/README.md)
- [Configure Jaeger tracing](../configure/jaeger/README.md)
- [Configure Lightstep tracing](#configure-lightstep-tracing)
- [Configure custom Redis](#configure-custom-redis)
- [Configure custom PostgreSQL](#configure-custom-postgres)
- [Install without RBAC](#install-without-rbac)
- [Use non-default namespace](#use-non-default-namespace)
- [Pulling images locally](#pulling-images-locally)

## Configure network access

You need to make the main web server accessible over the network to external users.

There are a few approaches, but using an ingress controller is recommended.

### Ingress controller (recommended)

For production environments, we recommend using the [ingress-nginx](https://kubernetes.github.io/ingress-nginx/) [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).

As part of our base configuration we install an ingress for [sourcegraph-frontend](../base/frontend/sourcegraph-frontend.Ingress.yaml). It installs rules for the default ingress, see comments to restrict it to a specific host.

In addition to the sourcegraph-frontend ingress, you'll need to install the NGINX ingress controller (ingress-nginx). Follow the instructions at https://kubernetes.github.io/ingress-nginx/deploy/ to create the ingress controller. Add the files to [configure/ingress-nginx](../configure/ingress-nginx), including an [install.sh](configure/ingress-nginx/install.sh) file which applies the relevant manifests. We include sample generic-cloud manifests as part of this repository, but please follow the official instructions for your cloud provider.

Add the [configure/ingress-nginx/install.sh](configure/ingress-nginx/install.sh) command to [create-new-cluster.sh](../create-new-cluster.sh) and commit the change:

```shell
echo ./configure/ingress-nginx/install.sh >> create-new-cluster.sh
```

Once the ingress has acquired an external address, you should be able to access Sourcegraph using that. You can check the external address by running the following command and looking for the `LoadBalancer` entry:

```bash
kubectl -n ingress-nginx get svc
```

If you are having trouble accessing Sourcegraph, ensure ingress-nginx IP is accessible above. Otherwise see [Troubleshooting ingress-nginx](https://kubernetes.github.io/ingress-nginx/troubleshooting/). The namespace of the ingress-controller is `ingress-nginx`.

#### Configuration

`ingress-nginx` has extensive configuration documented at [NGINX Configuration](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/). We expect most administrators to modify [ingress-nginx annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) in [sourcegraph-frontend.Ingress.yaml](../base/frontend/sourcegraph-frontend.Ingress.yaml). Some settings are modified globally (such as HSTS). In that case we expect administrators to modify the [ingress-nginx configmap](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/) in [configure/ingress-nginx/mandatory.yaml](../configure/ingress-nginx/mandatory.yaml).

### NGINX service

In cases where ingress controllers cannot be created, creating an explicit NGINX service is a viable
alternative. See the files in the [configure/nginx-svc](../configure/nginx-svc) folder for an
example of how to do this via a NodePort service (any other type of Kubernetes service will also
work):

1. Modify [configure/nginx-svc/nginx.ConfigMap.yaml](../configure/nginx-svc/nginx.ConfigMap.yaml) to
   contain the TLS certificate and key for your domain.

1. `kubectl apply -f configure/nginx-svc` to create the NGINX service.

1. Update [create-new-cluster.sh](../create-new-cluster.sh) with the previous command.

   ```
   echo kubectl apply -f configure/nginx-svc >> create-new-cluster.sh
   ```

### Network rule

> Note: this setup path does not support TLS.

Add a network rule that allows ingress traffic to port 30080 (HTTP) on at least one node.

- [Google Cloud Platform Firewall rules](https://cloud.google.com/compute/docs/vpc/using-firewalls).

  1. Expose the necessary ports.

     ```bash
     gcloud compute --project=$PROJECT firewall-rules create sourcegraph-frontend-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:30080
     ```

  1. Change the type of the `sourcegraph-frontend` service in [base/frontend/sourcegraph-frontend.Service.yaml](../base/frontend/sourcegraph-frontend.Service.yaml) from `ClusterIP` to `NodePort`:

     ```diff
     spec:
        ports:
        - name: http
          port: 30080
     +    nodePort: 30080
     -  type: ClusterIP
     +  type: NodePort
     ```

  1. Directly applying this change to the service [will fail](https://github.com/kubernetes/kubernetes/issues/42282). Instead, you must delete the old service and then create the new one (this will result in a few seconds of downtime):

  ```shell
  kubectl delete svc sourcegraph-frontend
  kubectl apply -f base/frontend/sourcegraph-frontend.Service.yaml
  ```

  1. Find a node name.

     ```bash
     kubectl get pods -l app=sourcegraph-frontend -o=custom-columns=NODE:.spec.nodeName
     ```

  1. Get the EXTERNAL-IP address (will be ephemeral unless you [make it static](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#promote_ephemeral_ip)).
     ```bash
     kubectl get node $NODE -o wide
     ```

- [AWS Security Group rules](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html).

Sourcegraph should now be accessible at `$EXTERNAL_ADDR:30080`, where `$EXTERNAL_ADDR` is the address of _any_ node in the cluster.

## Update site configuration

Sourcegraph's application configuration is stored in the PostgreSQL database. For editing this configuration you may use the web UI. See [site configuration](https://docs.sourcegraph.com/admin/config/site_config) for more information.

## Configure TLS/SSL

If you intend to make your Sourcegraph instance accessible on the Internet or another untrusted network, you should use TLS so that all traffic will be served over HTTPS.

### Ingress controller

If you exposed your Sourcegraph instance via an ingress controller as described in ["Ingress controller (recommended)"](#ingress-controller-recommended):

1. Create a [TLS secret](https://kubernetes.io/docs/concepts/configuration/secret/) that contains your TLS certificate and private key.

   ```bash
   kubectl create secret tls sourcegraph-tls --key $PATH_TO_KEY --cert $PATH_TO_CERT
   ```

   Update [create-new-cluster.sh](../create-new-cluster.sh) with the previous command.

   ```
   echo kubectl create secret tls sourcegraph-tls --key $PATH_TO_KEY --cert $PATH_TO_CERT >> create-new-cluster.sh
   ```

1. Add the tls configuration to [base/frontend/sourcegraph-frontend.Ingress.yaml](../base/frontend/sourcegraph-frontend.Ingress.yaml).

   ```yaml
   # base/frontend/sourcegraph-frontend.Ingress.yaml
   tls:
     - hosts:
         #  Replace 'sourcegraph.example.com' with the real domain that you want to use for your Sourcegraph instance.
         - sourcegraph.example.com
       secretName: sourcegraph-tls
   rules:
     - http:
         paths:
         - path: /
           backend:
             serviceName: sourcegraph-frontend
             servicePort: 30080
       # Replace 'sourcegraph.example.com' with the real domain that you want to use for your Sourcegraph instance.
       host: sourcegraph.example.com
   ```

1. Change your `externalURL` in [the site configuration](https://docs.sourcegraph.com/admin/config/site_config) to e.g. `https://sourcegraph.example.com`:

**WARNING:** Do NOT commit the actual TLS cert and key files to your fork (unless your fork is
private **and** you are okay with storing secrets in it).

### NGINX service

If you exposed your Sourcegraph instance via the altenative nginx service as described in ["nginx service"](#nginx-service), those instructions already walked you through setting up TLS/SSL.

## Configure repository cloning via SSH

Sourcegraph will clone repositories using SSH credentials if they are mounted at `/root/.ssh` in the `gitserver` deployment.

1. [Create a secret](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables) that contains the base64 encoded contents of your SSH private key (_make sure it doesn't require a password_) and known_hosts file.

   ```bash
   kubectl create secret generic gitserver-ssh \
    --from-file id_rsa=${HOME}/.ssh/id_rsa \
    --from-file known_hosts=${HOME}/.ssh/known_hosts
   ```

   Update [create-new-cluster.sh](../create-new-cluster.sh) with the previous command.

   ```bash
   echo kubectl create secret generic gitserver-ssh \
    --from-file id_rsa=${HOME}/.ssh/id_rsa \
    --from-file known_hosts=${HOME}/.ssh/known_hosts >> create-new-cluster.sh
   ```

2. Mount the [secret as a volume](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod) in [gitserver.StatefulSet.yaml](../base/gitserver/gitserver.StatefulSet.yaml).

   For example:

   ```yaml
   # base/gitserver/gitserver.StatefulSet.yaml
   spec:
     containers:
       volumeMounts:
         - mountPath: /root/.ssh
           name: ssh
     volumes:
       - name: ssh
         secret:
           defaultMode: 384
           secretName: gitserver-ssh
   ```

   Convenience script:

   ```bash
   # This script requires https://github.com/sourcegraph/jy and https://github.com/sourcegraph/yj
   GS=base/gitserver/gitserver.StatefulSet.yaml
   cat $GS | yj | jq '.spec.template.spec.containers[].volumeMounts += [{mountPath: "/root/.ssh", name: "ssh"}]' | jy -o $GS
   cat $GS | yj | jq '.spec.template.spec.volumes += [{name: "ssh", secret: {defaultMode: 384, secretName:"gitserver-ssh"}}]' | jy -o $GS
   ```

3. Apply the updated `gitserver` configuration to your cluster.

   ```bash
    ./kubectl-apply-all.sh
   ```

**WARNING:** Do NOT commit the actual `id_rsa` and `known_hosts` files to your fork (unless
your fork is private **and** you are okay with storing secrets in it).

## Configure language servers

Code intelligence is provided through [Sourcegraph extensions](https://docs.sourcegraph.com/extensions). These language extensions communicate with language servers that are deployed inside your Sourcegraph cluster. See the README.md for each language for configuration information:

- Go: [configure/lang/go/README.md](../configure/lang/go/README.md)
- JavaScript/TypeScript: [configure/lang/typescript/README.md](../configure/lang/typescript/README.md)

## Increase memory or CPU limits

If your instance contains a large number of repositories or monorepos, changing the compute resources allocated to containers can improve performance. See [Kubernetes' official documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for information about compute resources and how to specify then, and see [docs/scale.md](scale.md) for specific advice about what resources to tune.

## Configure gitserver replica count

Increasing the number of `gitserver` replicas can improve performance when your instance contains a large number of repositories. Repository clones are consistently striped across all `gitserver` replicas. Other services need to be aware of how many `gitserver` replicas exist so they can resolve an individual repo.

To change the number of `gitserver` replicas:

1. Update the `replicas` field in [gitserver.StatefulSet.yaml](../base/gitserver/gitserver.StatefulSet.yaml).
1. Update the `SRC_GIT_SERVERS` environment variable in the frontend service to reflect the number of replicas.

   For example, if there are 2 gitservers then `SRC_GIT_SERVERS` should have the value `gitserver-0.gitserver:3178 gitserver-1.gitserver:3178`:

   ```yaml
   - env:
       - name: SRC_GIT_SERVERS
         value: gitserver-0.gitserver:3178 gitserver-1.gitserver:3178
   ```

1. Recommended: Increase [indexed-search replica count](#configure-indexed-search-replica-count)

Here is a convenience script that performs all three steps:

```bash
# This script requires https://github.com/sourcegraph/jy and https://github.com/sourcegraph/yj

GS=base/gitserver/gitserver.StatefulSet.yaml

REPLICA_COUNT=2 # number of gitserver replicas

# Update gitserver replica count
cat $GS | yj | jq ".spec.replicas = $REPLICA_COUNT" | jy -o $GS

# Compute all gitserver names
GITSERVERS=$(for i in `seq 0 $(($REPLICA_COUNT-1))`; do echo -n "gitserver-$i.gitserver:3178 "; done)

# Update SRC_GIT_SERVERS environment variable in other services
find . -name "*yaml" -exec sed -i.sedibak -e "s/value: gitserver-0.gitserver:3178.*/value: $GITSERVERS/g" {} +

IDX_SEARCH=base/indexed-search/indexed-search.StatefulSet.yaml

# Update indexed-search replica count
cat $IDX_SEARCH | yj | jq ".spec.replicas = $REPLICA_COUNT" | jy -o $IDX_SEARCH

# Delete sed's backup files
find . -name "*.sedibak" -delete
```

Commit the outstanding changes.

## Configure indexed-search replica count

Increasing the number of `indexed-search` replicas can improve performance and reliability when your instance contains a large number of repositories. Repository indexes are distributed evenly across all `indexed-search` replicas.

By default `indexed-search` relies on kubernetes service discovery, so adjusting the number of replicas just requires updating the `replicas` field in [indexed-search.StatefulSet.yaml](../base/indexed-search/indexed-search.StatefulSet.yaml).

Not Recommended: To use a static list of indexed-search servers you can configure `INDEXED_SEARCH_SERVERS` on `sourcegraph-frontend`. It uses the same format as `SRC_GIT_SERVERS` above. Adjusting replica counts will require the same steps as gitserver.

## Assign resource-hungry pods to larger nodes

If you have a heterogeneous cluster where you need to ensure certain more resource-hungry pods are assigned to more powerful nodes (e.g. `indexedSearch`), you can [specify node constraints](https://kubernetes.io/docs/concepts/configuration/assign-pod-node) (such as `nodeSelector`, etc.).

This is useful if, for example, you have a very large monorepo that performs best when `gitserver`
and `searcher` are on very large nodes, but you want to use smaller nodes for
`sourcegraph-frontend`, `repo-updater`, etc. Node constraints can also be useful to ensure fast
updates by ensuring certain pods are assigned to specific nodes, preventing the need for manual pod
shuffling.

See [the official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) for instructions about applying node constraints.

## Configure a storage class

Sourcegraph expects there to be storage class named `sourcegraph` that it uses for all its persistent volume claims. This storage class must be configured before applying the base configuration to your cluster.

Create `base/sourcegraph.StorageClass.yaml` with the appropriate configuration for your cloud provider and commit the file to your fork.

### Google Cloud Platform (GCP)

```yaml
# base/sourcegraph.StorageClass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: sourcegraph
  labels:
    deploy: sourcegraph
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd # This configures SSDs (recommended).
```

[Additional documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#gce-pd).

### Amazon Web Services (AWS)

```yaml
# base/sourcegraph.StorageClass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: sourcegraph
  labels:
    deploy: sourcegraph
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2 # This configures SSDs (recommended).
```

[Additional documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#aws-ebs).

### Azure

```yaml
# base/sourcegraph.StorageClass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: sourcegraph
  labels:
    deploy: sourcegraph
provisioner: kubernetes.io/azure-disk
parameters:
  storageaccounttype: Premium_LRS # This configures SSDs (recommended). A Premium VM is required.
```

[Additional documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-disk).

### Other cloud providers

```yaml
# base/sourcegraph.StorageClass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: sourcegraph
  labels:
    deploy: sourcegraph
# Read https://kubernetes.io/docs/concepts/storage/storage-classes/ to configure the "provisioner" and "parameters" fields for your cloud provider.
# SSDs are highly recommended!
# provisioner:
# parameters:
```

### Using a storage class with an alternate name

If you wish to use a different storage class for Sourcegraph, then you need to update all persistent volume claims with the name of the desired storage class. Convenience script:

```bash
#!/bin/bash

# This script requires https://github.com/sourcegraph/jy and https://github.com/sourcegraph/yj
STORAGE_CLASS_NAME=

find . -name "*PersistentVolumeClaim.yaml" -exec sh -c "cat {} | yj | jq '.spec.storageClassName = \"$STORAGE_CLASS_NAME\"' | jy -o {}" \;

GS=base/gitserver/gitserver.StatefulSet.yaml

cat $GS | yj | jq  --arg STORAGE_CLASS_NAME $STORAGE_CLASS_NAME '.spec.volumeClaimTemplates = (.spec.volumeClaimTemplates | map( . * {spec:{storageClassName: $STORAGE_CLASS_NAME }}))' | jy -o $GS
```

## Configure Lightstep tracing

Lightstep is a closed-source distributed tracing and performance monitoring tool created by some of the authors of Dapper. Every Sourcegraph deployment supports Lightstep, and it can be configured via the following environment variables (with example values):

```yaml
env:
  # https://about.sourcegraph.com/docs/config/site/#lightstepproject-string
  - name: LIGHTSTEP_PROJECT
    value: my_project

  # https://about.sourcegraph.com/docs/config/site/#lightstepaccesstoken-string
  - name: LIGHTSTEP_ACCESS_TOKEN
    value: abcdefg

  # If false, any logs (https://github.com/opentracing/specification/blob/master/specification.md#log-structured-data)
  # from spans will be omitted from the spans sent to Lightstep.
  - name: LIGHTSTEP_INCLUDE_SENSITIVE
    value: true
```

To enable this, you must first purchase Lightstep and create a project corresponding to the Sourcegraph instance. Then, add the above environment to each deployment.

## Configure custom Redis

Sourcegraph supports specifying a custom Redis server for:

- caching information (specified via the `REDIS_CACHE_ENDPOINT` environment variable)
- storing information (session data and job queues) (specified via the `REDIS_STORE_ENDPOINT` environment variable)

If you want to specify a custom Redis server, you'll need specify the corresponding environment variable for each of the following deployments:

- `sourcegraph-frontend`
- `repo-updater`
- `lsif-server`

## Configure custom PostgreSQL

You can use your own PostgreSQL v9.6+ server with Sourcegraph if you wish. For example, you may prefer this if you already have existing backup infrastructure around your own PostgreSQL server, wish to use Amazon RDS, etc.

Simply edit the relevant PostgreSQL environment variables (e.g. PGHOST, PGPORT, PGUSER, [etc.](http://www.postgresql.org/docs/current/static/libpq-envars.html)) in [base/frontend/sourcegraph-frontend.Deployment.yaml](../base/frontend/sourcegraph-frontend.Deployment.yaml) to point to your existing PostgreSQL instance.

Note: Sourcegraph will create a secondary database in the same PostgreSQL instance with a name of the form `{PGDATABASE}_lsif`. It is assumed the PostgreSQL instance is dedicated solely to Sourcegraph.

## Install without RBAC

Sourcegraph Data Center communicates with the Kubernetes API for service discovery. It also has some janitor DaemonSets that clean up temporary cache data. To do that we need to create RBAC resources.

If using RBAC is not an option, then you will not want to apply `*.Role.yaml` and `*.RoleBinding.yaml` files.

## Add license key

Sourcegraph's Kubernetes deployment [requires an Enterprise license key](https://about.sourcegraph.com/pricing).

1. Create an account on or sign in to sourcegraph.com, and go to https://sourcegraph.com/subscriptions/new to obtain a license key.

1. Once you have a license key, add it to your [site configuration](https://docs.sourcegraph.com/admin/config/site_config).

## Use non-default namespace

If you're deploying Sourcegraph into a non-default namespace,
refer to [base/prometheus/README.md#Namespaces](../base/prometheus/README.md#Namespaces) and
[base/grafana/README.md#Namespaces](../base/grafana/README.md#Namespaces) for further configuration instructions.

## Pulling images locally

In some cases, a site admin may want to pull all Docker images used in the cluster locally. For
example, if your organization requires use of a private registry, you may need to do this as an
intermediate step to mirroring them on the private registry. The following script accomplishes this
for all images under `base/`:

```bash
for IMAGE in $(grep --include '*.yaml' -FR 'image:' base | awk '{ print $(NF) }'); do docker pull "$IMAGE"; done;
```
