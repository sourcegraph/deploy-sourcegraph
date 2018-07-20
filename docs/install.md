# Installation

## Requirements

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), v1.8.6 or later
- [Python 3](https://www.python.org/getit/) if you wish to run our provided configuration scripts.
- Access to server infrastructure on which you can create a Kubernetes cluster (see
  [resource allocation guidelines](scale.md)).

## Install

> **Note:** Sourcegraph sends performance and usage data to Sourcegraph to help us make our product
> better for you. The data sent does NOT include any source code or file data (including URLs that
> might implicitly contain this information). You can view traces and disable telemetry in the site
> admin area on the server.

Sourcegraph Data Center is deployed using Kubernetes. Before proceeding with these
instructions, [provision a Kubernetes](k8s.md) cluster on the infrastructure of your choice. Make
sure you have [configured `kubectl` to access your cluster](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/).

1.  The easiest way to start is to deploy our base yaml. No configuration required!

    ```
    git clone https://github.com/sourcegraph/deploy-sourcegraph.git
    cd deploy-sourcegraph
    kubectl apply --prune -l deploy=sourcegraph -f base --recursive
    ```

1.  When the deployment completes, you need to make the main web server accessible over the network to external users. To
    do so, connect port 30080 (or the value of `httpNodePort` in the site config) on the nodes in the cluster to the
    Internet. The easiest way to do this is to add a network rule that allows ingress traffic to port 30080 on at least
    one node
    (see
    [AWS Security Group rules](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html),
    [Google Cloud Platform Firewall rules](https://cloud.google.com/compute/docs/vpc/using-firewalls)).
    Sourcegraph should then be accessible at `$EXTERNAL_ADDR:30080`, where `$EXTERNAL_ADDR` is the
    address of _any_ node in the cluster. For production environments, we recommend using
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

- Refer to the [examples](../examples) directory for an example of a cluster config with code
  intelligence enabled.
- See the [language-specific docs](https://about.sourcegraph.com/docs/code-intelligence) for
  configuring specific languages.
- [Contact us](mailto:support@sourcegraph.com) with questions or problems relating to code
  intelligence.

### Additional configuration

You can set additional fields in `values.yaml` to configure your Sourcegraph instance. The `values.yaml` file is split into two top-level fields:

- `site` defines Sourcegraph site configuration. For the full list of options, see "[Sourcegraph site configuration options](https://about.sourcegraph.com/docs/config/site)".
- `cluster` defines settings specific to the configuration of the Kubernetes cluster, like replica counts and CPU/memory
  allocation. Refer to [`../values.yaml`](../values.yaml) in this repository to see which `cluster` fields can be overridden.

The default configuration is defined in this repository's [top-level `values.yaml`](../values.yaml).

For common site configuration tasks, see:

- "[Add repositories](https://about.sourcegraph.com/docs/config/repositories)"
- "[User authentication](https://about.sourcegraph.com/docs/config/authentication)" (passwords, SAML, OpenID Connect, HTTP proxy auth, etc.)
- "[Use a custom domain](https://about.sourcegraph.com/docs/config/custom-domain)"
- "[Using TLS/SSL](https://about.sourcegraph.com/docs/config/tlsssl)"
- "[Monitoring and tracing](https://about.sourcegraph.com/docs/config/monitoring-and-tracing)"

After updating configuration, follow the [update instructions](./update.md) to apply the changes to
your Sourcegraph Data Center instance.

### Troubleshooting

See the [Troubleshooting page](troubleshoot.md).

### Install without RBAC

Sourcegraph Data Center communicates with the Kubernetes API for service discovery. It also has some janitor DaemonSets
that clean up temporary cache data. To do that we need to create RBAC resources.

If using RBAC is not an option, then you will not want to apply `*.Role.yaml` and `*.RoleBinding.yaml` files.

### Storage class

Sourcegraph relies on the default storage class of your cluster.

If you wish to use a different storage class, you can run `./configure/storage-class-name.sh` to configure the yaml with the name.

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
