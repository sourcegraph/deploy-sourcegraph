> 🚨 If you are updating from a 2.10.x or previous deployment, follow the migration steps in [docs/migrate.md](docs/migrate.md).

> 🚨 If you are updating from a 2.11.x or previous deployment, you will need to add an Enterprise license key. Follow the steps in [docs/configure.md](docs/configure.md#add-a-license-key).

# Sourcegraph Data Center
[![sourcegraph: search](https://img.shields.io/badge/sourcegraph-search-brightgreen.svg)](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph)

Sourcegraph Data Center is for organizations that need highly scalable and available code search and
code intelligence. This repository contains documentation for creating, updating, and maintaining a
Sourcegraph Data Center cluster using Kubernetes.

For product and [pricing](https://about.sourcegraph.com/pricing/) information,
visit [about.sourcegraph.com](https://about.sourcegraph.com)
or [contact us](https://about.sourcegraph.com/contact/sales) for more information. If you're just
starting out, we recommend installing [Sourcegraph](https://about.sourcegraph.com/docs) on a single
node first. Migrating to Data Center is easy when you're ready.

- [Installing](docs/install.md)
- [Configuring](docs/configure.md)
- [Updating](docs/update.md)
- [Scaling](docs/scale.md)
- [Troubleshooting](docs/troubleshoot.md)
- [Admin guide](docs/admin-guide.md) - useful guide for Sourcegraph admins
  - [Prometheus metrics](docs/prom-metrics.md) - list of all Prometheus metrics that can be used for
    application performance monitoring

## Kubernetes alternatives

We recommend using Kubernetes for deploying Sourcegraph (see above for installation instructions). However, we understand not everyone can use Kubernetes or may prefer their own container infrastructure. If this is the case, check out our [pure-Docker deployment reference](https://github.com/sourcegraph/deploy-sourcegraph-docker).

## Contributing

We've made our deployment configurations open source to better serve our customers' needs. If there is anything we can do to make deploying Sourcegraph easier just open an issue [(with the deploy-sourcegraph label in sourcegraph/sourcegraph)](https://github.com/sourcegraph/sourcegraph/issues/new?assignees=&labels=deploy-sourcegraph&template=deploy-sourcegraph.md&title=%5Bdeploy-sourcegraph%5D) or a pull request and we will respond promptly!
