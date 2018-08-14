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
