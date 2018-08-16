# Common Customizations

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

  # TODO: Is there any documenation for this?
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

## SSD Cache

Many parts of Sourcegraph's infrastructure benefit from using SSDs for caches. This is especially important for search / language server performance. By default, disk caches will use the Kubernetes `hostPath` and will be the same IO speed as the underlying node's disk. Even if the node's default disk is a SSD, however, it is likely network-mounted rather than local.

The deployments that refer to the `cache-ssd` volume are capable of using SSDs to boost their performance. Some cloud providers optionally mount local SSDs. If you mount local SSDs on your nodes, you can change the `cache-ssd` volume from:

```yaml
 volumes:
    ...

    - emptyDir: {}
    name: cache-ssd
```

to:

```yaml
 volumes:
    ...

    - hostPath:
        path: ${SSD_MOUNT_PATH}/pod-tmp
    name: cache-ssd
```

Replace `${SSD_MOUNT_PATH}` with the absolute directory path on the node where the local SSD is mounted.

For example, on Google Cloud Platform, add Local SSDs to the nodes running the searcher pods. Then change the following fields in your deployment :

```yaml
 volumes:
    ...

    - hostPath:
        path: /mnt/disks/ssd0/pod-tmp
    name: cache-ssd
```

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

# e.g. 2018-08-15T23:42:08Z
CONFIG_DATE=$(date -u +"%Y-%m-%dT%H-%M-%SZ")

# update all references to the site config's ConfigMap
# from: 'config-file.*' , to:' config-file-$CONFIG_DATE'
find . -name "*yaml" -exec sed -i.sedibak -e "s/name: config-file.*/name: config-file-$CONFIG_DATE/g" {} +

# delete sed's backup files
find . -name "*.sedibak" -delete
```

## Configuring SSL

If you intend to make your Sourcegraph instance accessible on the Internet or another untrusted network, you should use TLS so that all traffic will be served over HTTPS.

You can configure TLS by adding the following environment variables to the `sourcegraph-frontend` deployment:

```yaml
env:
  - name: TLS_CERT
    value: "-----BEGIN CERTIFICATE-----\nMIIFdTCCBF2gAWiB..."

  - name: TLS_KEY
    value: "-----BEGIN RSA PRIVATE KEY-----\nMII..."
```

You can also refer to the [official Kubernetes documentation about secrets](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables), which let you avoid specifying the TLS certificate and key verbatim.
