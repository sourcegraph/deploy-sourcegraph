# Common Customizations

TODO: write index:

- Expose port
- Site config
- Enable language servers
- TLS
- Gitserver ssh

## Make Sourcegraph accessbile to external users

TODO: needs cleanup

When the deployment completes, you need to make the main web server accessible over the network to external users. To do so, connect port 30080 on the nodes in the cluster to the internet. The easiest way to do this is to add a network rule that allows ingress traffic to port 30080 on at least one node
(see
[AWS Security Group rules](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html),
[Google Cloud Platform Firewall rules](https://cloud.google.com/compute/docs/vpc/using-firewalls)).
Sourcegraph should then be accessible at `$EXTERNAL_ADDR:30080`, where `$EXTERNAL_ADDR` is the
address of _any_ node in the cluster. For production environments, we recommend using
an [Internet Gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html) (or
equivalent) and configuring a load balancer in Kubernetes.

## Install without RBAC

Sourcegraph Data Center communicates with the Kubernetes API for service discovery. It also has some janitor DaemonSets that clean up temporary cache data. To do that we need to create RBAC resources.

If using RBAC is not an option, then you will not want to apply `*.Role.yaml` and `*.RoleBinding.yaml` files.

## Storage class

Sourcegraph relies on the default storage class of your cluster. If your cluster does not have a default storage class or if you wish to use a different storage class for Sourcegraph, then you need to update all PersistentVolumeClaims with the name of the desired storage class.

```bash
find . -name "*PersistentVolumeClaim.yaml" -exec sh -c "cat {} | yj | jq '.spec.storageClassName = \"$STORAGE_CLASS_NAME\"' | jy -o {}" \;
```

## Gitserver Replica Count

Increasing the `replica` count of the `gitserver` Stateful Set increases the scalability of your deployment. Repository clones are consistently striped across all `giterver` replicas, so other services need to be aware of how many `gitserver` replicas have been specified in order to know how to a resolve an individual repo.

Services that talk to `gitserver` are passed a list of `gitserver` addresses via the `SRC_GIT_SERVERS` environment variable. You'll need to update this environment variable for each deployment if you change `gitserver`'s `replica` count.

1. Get all the deployments which use `SRC_GIT_SERVERS`

```bash
> grep SRC_GIT_SERVERVS -l

language-servers/go/xlang-go.Deployment.yaml
language-servers/go/xlang-go-bg.Deployment.yaml
...
```

2. For each one of those files, change the value of `SRC_GIT_SERVERS`

The `SRC_GIT_SERVER` variable is a space separated list of addresses that look like the following:

```bash
# $REPLICA_COUNT = 1
gitserver-0.gitserver:3178

# $REPLICA_COUNT = 2
gitserver-0.gitserver:3178 gitserver-1.gitserver:3178

# ...

# $REPLICA_COUNT = n
gitserver-0.gitserver:3178 gitserver-1.gitserver:3178 ... gitserver-${n-1}:3178
```

For each file in the output of step 1, change the value of `SRC_GIT_SERVERS` as stated above.

## Lightstep Tracing

Lightstep is a closed-source distributed tracing and performance monitoring tool created by some of the authors of Dapper. Every Sourcegraph deployment supports Lightstep, and it can be configured via the following environment variables (with example values):

```yaml
env:
  # https://about.sourcegraph.com/docs/config/site/#lightstepproject-string
  - name: LIGHTSTEP_PROJECT
    value: my_project

  # https://about.sourcegraph.com/docs/config/site/#lightstepaccesstoken-string
  - name: LIGHTSTEP_ACCESS_TOKEN
    value: M3WKBuqsCnRYz1c

  # If false, any logs from spans will be omitted from the spans sent to Lightstep.
  - name: LIGHTSTEP_INCLUDE_SENSITIVE
    value: true
```

To enable this, you must first purchase Lightstep and create a project corresponding to the Sourcegraph instance. Then, add the above environment to each deployment.

## Custom Redis Cache and Store

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

## Using SSD Caches to Boost Performance

See [ssd/README.md](../configure/ssd/README.md).

## Assigning Resource-Hungry Pods to Larger Nodes

If you have a heterogeneous cluster where you need to ensure certain more resource-hungry pods (e.g., `indexedSearch`), you can [refer to the Kubernetes documentation to see how to specify node constraints (such as `nodeSelector`, etc.)](https://kubernetes.io/docs/concepts/configuration/assign-pod-node).

## Site Configuration ConfigMap

Many services need to reference the site configuration. The configuration is stored inside a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#add-configmap-data-to-a-volume), which is mounted inside every deployment that needs it.

Whenever you update the configuration, you'll also need to update the deployments that reference it so that your changes will be visible. One way of accomplishing this is to change the name of the config map every time that you make changes.

The following script (provided for your convenience):

- changes the name of the config map by appending the current date and time
- updates all references to the site configuration to the newly named config map

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

## Configuring SSL

If you intend to make your Sourcegraph instance accessible on the Internet or another untrusted network, you should use TLS so that all traffic will be served over HTTPS. You can configure Sourcegraph to use TLS by providing the `TLS_CERT` and `TLS_KEY` environment variables variables to the `sourcegraph-frontend` deployment.

One way of doing this is to create a secret object (see the official documentation)[https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables] that contains your TLS credentials:

`tls.Secret.yaml`

```yaml
apiVersion: v1
data:
  cert: "-----BEGIN CERTIFICATE-----\nMIIFdTCCBF2gAWiB..."
  key: "-----BEGIN RSA PRIVATE KEY-----\nMII..."
kind: Secret
metadata:
  name: tls
type: Opaque
```

and refer to it in your `sourcegraph-frontend` deployment when adding the `TLS_CERT` and `TLS_KEY` evironment variables:

`sourcegraph-frontend.Deployment.yaml`

```yaml
env:
  - name: TLS_CERT
    valueFrom:
      secretKeyRef:
        key: cert
        name: tls
  - name: TLS_KEY
    valueFrom:
      secretKeyRef:
        key: cert
        name: tls
```

## Gitserver SSH

`gitserver` can be configured to clone repos with a SSH key. It will use the SSH credentials located at `/root/.ssh`, if present.

One way to add SSH credentials is to:

1. Create a secrets object (see the official documentation)[https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables] that contains your SSH credentials

`gitserver-ssh.Secret.yaml`:

```yaml
apiVersion: v1
data:
  id_rsa: "-----BEGIN RSA PRIVATE KEY-----\nMII..."
  known_hosts: "github.com,192.30.255.113 ssh-rsa AAAA..."
kind: Secret
metadata:
  name: gitserver-ssh
type: Opaque
```

2. Refer to the secret inside your `gitserver` deployment by adding a `volume` and `volumeMount`:

`base/gitserver/gitserver.StatefulSet.yaml`:

```yaml
spec:

  ...

  containers:

    ...

    volumeMounts:
        - mountPath: /root/.ssh
          name: ssh
  ...

  volumes:
    - name: ssh
      secret:
        defaultMode: 384
        secretName: gitserver-ssh
```

## Language Servers

> Code intelligence is a paid upgrade on top of the Data Center deployment option. After following these instructions to confirm it works, buy code intelligence.

Code intelligence provides advanced code navigation and cross-references for your code on Sourcegraph.

After setting up the base Sourcegraph deployment, refer to the following docs for each language for instructions about how to deploy / configure each language server:

- [Go](../configure/xlang/go/README.md)
- [Java](../configure/xlang/java/README.md)
- [PHP](../configure/xlang/php/README.md)
- [Python](../configure/xlang/python/README.md)
- [Javascript / Typescript](../configure/xlang/typescript/README.md)
