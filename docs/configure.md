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
- [Assign resource-hungry pods to larger nodes](#assign-resource-hungry-pods-to-larger-nodes)
- [Configure Prometheus](../configure/prometheus/README.md)
  - [Configure Alertmanager](../configure/prometheus/alertmanager/README.md)
- [Configure Jaeger tracing](../configure/jaeger/README.md)
- [Configure Lightstep tracing](#configure-lightstep-tracing)
- [Configure custom Redis](#configure-custom-redis)
- [Configure custom PostgreSQL](#configure-custom-redis)
- [Install without RBAC](#install-without-rbac)

## Configure network access

You need to make the main web server accessible over the network to external users.

There are a few approaches, but using a load balancer is recommended.

### Load balancer (recommended)

For production environments, we recommend using a [load balancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/).

Run one of the following commands depending on your desired transport protocol:

- HTTP
  ```
  kubectl expose deployment sourcegraph-frontend --type=LoadBalancer --name=sourcegraph-frontend-loadbalancer --port=80 --target-port=3080
  ```
- HTTPS (requires you to [configure TLS/SSL](#configure-tlsssl))
  ```
  kubectl expose deployment sourcegraph-frontend --type=LoadBalancer --name=sourcegraph-frontend-loadbalancer --port=443 --target-port=3443
  ```

Add the command you ran to [create-new-cluster.sh](../create-new-cluster.sh) and commit the change.

Once the load balancer has acquired an external IP address, you should be able to access Sourcegraph using that. You can check the external IP address by running the following command:

```bash
kubectl get service sourcegraph-frontend-loadbalancer -o=custom-columns=EXTERNAL-IP:.status.loadBalancer.ingress[*].ip
```

### Network rule

Add a network rule that allows ingress traffic to port 30080 (HTTP) and/or 30081 (HTTPS) on at least one node.

- [Google Cloud Platform Firewall rules](https://cloud.google.com/compute/docs/vpc/using-firewalls).

  1. Expose the necessary ports.

     ```bash
     gcloud compute --project=$PROJECT firewall-rules create sourcegraph-frontend-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:30080
     gcloud compute --project=$PROJECT firewall-rules create sourcegraph-frontend-https --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:30081
     ```

  2. Find a node name.

     ```bash
     kubectl get pods -l app=sourcegraph-frontend -o=custom-columns=NODE:.spec.nodeName
     ```

  3. Get the EXTERNAL-IP address (will be ephemeral unless you [make it static](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#promote_ephemeral_ip)).
     ```bash
     kubectl get node $NODE -o wide
     ```

- [AWS Security Group rules](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html).

Sourcegraph should now be accessible at `$EXTERNAL_ADDR:30080` and/or `$EXTERNAL_ADDR:30081`, where `$EXTERNAL_ADDR` is the address of _any_ node in the cluster.

### Ingress controller

You can also use an [Ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress/).

## Update site configuration

The site configuration is stored inside a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#add-configmap-data-to-a-volume), which is mounted inside every deployment that needs it. You can change the site configuration by editing
[base/config-file.ConfigMap.yaml](../base/config-file.ConfigMap.yaml).

Updates to the site configuration are [propagated to the relevant services](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#mounted-configmaps-are-updated-automatically) in about 1 minute. ([Future Kubernetes versions will decrease this latency.](https://github.com/kubernetes/kubernetes/pull/64752))

For the impatient, site configuration changes can be applied immediately by changing the name of the ConfigMap. `kubectl apply`ing these changes will force the relevant pods to restart immediately with the new config:

1. Change the name of the ConfigMap in all deployments.

   The following convenience script changes the name of the site configuration's ConfigMap (and all references to it) by appending the current date and time. This script should be run
   at the root of your `deploy-sourcegraph-$VERSION` folder.

   ```bash
   #!/bin/bash

   # e.g. 2018-08-15t23-42-08z
   CONFIG_DATE=$(date -u +"%Y-%m-%dt%H-%M-%Sz")

   # update all references to the site config's ConfigMap
   # from: 'config-file.*' , to:' config-file-$CONFIG_DATE'
   find . -name "*yaml" -exec sed -i.sedibak -e "s/name: config-file.*/name: config-file-$CONFIG_DATE/g" {} +

   # delete sed's backup files
   find . -name "*.sedibak" -delete
   ```

2. Apply the new configuration to your Kubernetes cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```

## Configure TLS/SSL

If you intend to make your Sourcegraph instance accessible on the Internet or another untrusted network, you should use TLS so that all traffic will be served over HTTPS.

1. Create a [secret](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables) that contains your TLS certificate and private key.

   ```bash
   kubectl create secret generic tls --from-file=cert=$PATH_TO_CERT --from-file=key=$PATH_TO_KEY
   ```

   Update [create-new-cluster.sh](../create-new-cluster.sh) with the previous command.

   ```
   echo kubectl create secret generic tls --from-file=cert=$PATH_TO_CERT --from-file=key=$PATH_TO_KEY >> create-new-cluster.sh
   ```

2. Add the `TLS_CERT` and `TLS_KEY` environment variables to [base/frontend/sourcegraph-frontend.Deployment.yaml](../base/frontend/sourcegraph-frontend.Deployment.yaml).

   ```yaml
   # base/frontend/sourcegraph-frontend.Deployment.yaml
   env:
     - name: TLS_CERT
       valueFrom:
         secretKeyRef:
           key: cert
           name: tls
     - name: TLS_KEY
       valueFrom:
         secretKeyRef:
           key: key
           name: tls
   ```

   Convenience script:

   ```bash
   # This script requires https://github.com/sourcegraph/jy and https://github.com/sourcegraph/yj
   FE=base/frontend/sourcegraph-frontend.Deployment.yaml
   cat $FE | yj | jq '(.spec.template.spec.containers[] | select(.name == "frontend") | .env) += [{name: "TLS_CERT", valueFrom: {secretKeyRef: {key: "cert", name: "tls"}}}, {name: "TLS_KEY", valueFrom: {secretKeyRef: {key: "key", name: "tls"}}}]' | jy -o $FE
   ```

3. Change your `appURL` in the site configuration stored in `base/config-file.ConfigMap.yaml`.

   ```json
   {
     "appURL": "https://example.com:3443" // Must begin with "https"; replace with the public IP or hostname of your machine
   }
   ```

4. Deploy the changes by following the [instructions to update to the site configuration](#update-site-configuration).

5. Refer to the [Configure network access](#configure-network-access) section to make sure that `sourcegraph-frontend`'s port `3443` is properly exposed.

**WARNING:** Do NOT commit the actual TLS cert and key files to your fork (unless your fork is
private **and** you are okay with storing secrets in it).

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

> Code intelligence is a paid upgrade on top of the Data Center deployment option. After following these instructions to confirm it works, [buy code intelligence](https://about.sourcegraph.com/pricing).

Code intelligence provides advanced code navigation and cross-references for your code on Sourcegraph.

After setting up the base Sourcegraph deployment, refer to the following docs for each language for instructions about how to deploy / configure each language server:

- [Go](../configure/xlang/go/README.md)
- [Java](../configure/xlang/java/README.md)
- [PHP](../configure/xlang/php/README.md)
- [Python](../configure/xlang/python/README.md)
- [Javascript / Typescript](../configure/xlang/typescript/README.md)

We also have the following experimental language servers (please [read about the caveats](https://about.sourcegraph.com/docs/code-intelligence/experimental-language-servers/#caveats-of-experimental-language-servers) before enabling them):

- [Bash](../configure/xlang/experimental/bash/README.md)
- [Clojure](../configure/xlang/experimental/clojure/README.md)
- [C++](../configure/xlang/experimental/cpp/README.md)
- [C#](../configure/xlang/experimental/cs/README.md)
- [CSS](../configure/xlang/experimental/css/README.md)
- [Dockerfile](../configure/xlang/experimental/dockerfile/README.md)
- [Elixir](../configure/xlang/experimental/elixir/README.md)
- [HTML](../configure/xlang/experimental/html/README.md)
- [Lua](../configure/xlang/experimental/lua/README.md)
- [OCaml](../configure/xlang/experimental/ocaml/README.md)
- [R](../configure/xlang/experimental/r/README.md)
- [Ruby](../configure/xlang/experimental/ruby/README.md)
- [Rust](../configure/xlang/experimental/rust/README.md)

## Increase memory or CPU limits

If your instance contains a large number of repositories or monorepos, changing the compute resources allocated to containers can improve performance. See [Kubernetes' official documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for information about compute resources and how to specify then, and see [docs/scale.md](scale.md) for specific advice about what resources to tune.

## Configure gitserver replica count

**Note:** If you're creating a new cluster and would like to change `gitserver`'s replica count, do
so _before_ running `./kubectl-apply-all.sh` for the first time. Changing this after the cluster
configuration has been applied will require manually resizing the `indexed-search` volume.

Increasing the number of `gitserver` replicas can improve performance when your instance contains a large number of repositories. Repository clones are consistently striped across all `gitserver` replicas. Other services need to be aware of how many `gitserver` replicas exist so they can resolve an individual repo.

To change the number of `gitserver` replicas:

1. Update the `replicas` field in [gitserver.StatefulSet.yaml](../base/gitserver/gitserver.StatefulSet.yaml).
1. Update the `SRC_GIT_SERVERS` environment variable in all services to reflect the number of replicas.

   For example, if there are 2 gitservers then `SRC_GIT_SERVERS` should have the value `gitserver-0.gitserver:3178 gitserver-1.gitserver:3178`:

   ```yaml
   - env:
       - name: SRC_GIT_SERVERS
         value: gitserver-0.gitserver:3178 gitserver-1.gitserver:3178
   ```

1. Update the requested `storage` capacity in [base/indexed-search/indexed-search.PersistentVolumeClaim.yaml](../base/indexed-search/indexed-search.PersistentVolumeClaim.yaml) to be `200Gi` multiplied by the number of `gitserver` replicas.

   For example, if there are 2 `gitserver` replicas then the `storage` requested in [base/indexed-search/indexed-search.PersistentVolumeClaim.yaml](../base/indexed-search/indexed-search.PersistentVolumeClaim.yaml) should have the value `400Gi`.

   ```yaml
   # base/indexed-search/indexed-search.PersistentVolumeClaim.yaml
   spec:
     resources:
       requests:
         storage: 400Gi
   ```

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

IDX_SEARCH=base/indexed-search/indexed-search.PersistentVolumeClaim.yaml

# Update the storage requested in indexed-search's persistent volume claim
cat $IDX_SEARCH | yj | jq --arg REPLICA_COUNT "$REPLICA_COUNT" '.spec.resources.requests.storage = ((($REPLICA_COUNT |tonumber)  * 200) | tostring)+"Gi"' | jy -o $IDX_SEARCH

# Delete sed's backup files
find . -name "*.sedibak" -delete
```

Commit the outstanding changes.

## Assign resource-hungry pods to larger nodes

If you have a heterogeneous cluster where you need to ensure certain more resource-hungry pods are assigned to more powerful nodes (e.g. `indexedSearch`), you can [specify node constraints](https://kubernetes.io/docs/concepts/configuration/assign-pod-node) (such as `nodeSelector`, etc.).

This is useful if, for example, you have a very large monorepo that performs best when `gitserver`
and `searcher` are on very large nodes, but you want to use smaller nodes for
`sourcegraph-frontend`, `repo-updater`, etc. Node constraints can also be useful to ensure fast
updates by ensuring certain pods are assigned to specific nodes, preventing the need for manual pod
shuffling.

See [the official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) for instructions about applying node constraints.

## Configure a storage class

Sourcegraph expects there to be storage class named `sourcegraph` that it uses for all its persistent volume claims. This storage class must be configured before applying the base configuration to your cluster. The configuration details differs depending on your hosting provider, so you should:

1. Create a stub `base/sourcegraph.StorageClass.yaml`.

   ```yaml
   # base/sourcegraph.StorageClass.yaml
   kind: StorageClass
   apiVersion: storage.k8s.io/v1
   metadata:
     name: sourcegraph
     labels:
       deploy: sourcegraph
   #
   # The values of the "provisioner" and "parameters" fields will differ depending on the cloud provider that you are using. Please read through https://kubernetes.io/docs/concepts/storage/storage-classes/ in order to know what values to add. 🚨 We recommend specifying SSDs as the disk type if possible. 🚨
   #
   # For example, if you are using GKE with a cluster whose nodes are all in the "us-central1-a" zone, you could use the following values:
   #
   # provisioner: kubernetes.io/gce-pd
   # parameters:
   #  type: pd-ssd
   #  zones: us-central1-a
   ```

1. Read through the [Kubernetes storage class documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/), and fill in the `provisioner` and `parameters` fields in `base/sourcegraph.StorageClass.yaml` with the correct values for your hosting provider (e.x.: [GCP](https://kubernetes.io/docs/concepts/storage/storage-classes/#gce), [AWS](https://kubernetes.io/docs/concepts/storage/storage-classes/#aws), [Azure](https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-disk)). **We highly recommend that the storage class use SSDs as the underlying disk type.**

1. Commit `base/sourcegraph.StorageClass.yaml` to your fork.

If you wish to use a different storage class for Sourcegraph, then you need to update all PersistentVolumeClaims with the name of the desired storage class.

```bash
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
- storing information (session data) (specified via the `REDIS_STORE_ENDPOINT` environment variable)

If you want to specify a custom Redis server, you'll need specify the corresponding environment variable for each of the following deployments:

- `sourcegraph-frontend`
- `indexer`
- `lsp-proxy`
- `repo-updater`
- `xlang-go`
- `xlang-go-bg`

## Configure custom PostgreSQL

You may prefer to configure Sourcegraph to store data in an external PostgreSQL instance if you already have existing database management or backup infrastructure.

Simply edit the relevant PostgreSQL environment variables (e.g. PGHOST, PGPORT, PGUSER, [etc.](http://www.postgresql.org/docs/current/static/libpq-envars.html)) in [base/frontend/sourcegraph-frontend.Deployment.yaml](../base/frontend/sourcegraph-frontend.Deployment.yaml) to point to your existing PostgreSQL instance.

## Install without RBAC

Sourcegraph Data Center communicates with the Kubernetes API for service discovery. It also has some janitor DaemonSets that clean up temporary cache data. To do that we need to create RBAC resources.

If using RBAC is not an option, then you will not want to apply `*.Role.yaml` and `*.RoleBinding.yaml` files.
