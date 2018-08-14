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

Lightstep is a closed-source distributed tracing and performance monitoring tool created by some of the authors of Dapper. Every Sourcegraph deployment supports Lightstep, and it can be configured via the following environment variables:

```bash
"LIGHTSTEP_PROJECT"
"LIGHTSTEP_ACCESS_TOKEN"
"LIGHTSTEP_INCLUDE_SENSITIVE"
```

To enable, you must first purchase Lightstep and create a project corresponding to the Sourcegraph instance. Then, add the above environment to each deployment.

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

For example, on Google Cloud Platform, add Local SSDs to the nodes running the searcher pods. Then add the following to your site config:

```yaml
 volumes:
    ...

    - hostPath:
        path: /mnt/disks/ssd0/pod-tmp
    name: cache-ssd
```
