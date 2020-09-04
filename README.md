> 🚨  IMPORTANT: When upgrading Sourcegraph, please check [upgrading docs](https://docs.sourcegraph.com/admin/updates/kubernetes) to check if any manual migrations are necessary.

> `master` branch tracks development. Use the revision of this repository corresponding to the
> version of Sourcegraph you wish to deploy. E.g., `git checkout v3.10.4`.

# Sourcegraph on Kubernetes
[![sourcegraph: search](https://img.shields.io/badge/sourcegraph-search-brightgreen.svg)](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph)

Deploying Sourcegraph into a Kubernetes cluster is for organizations that need highly scalable and
available code search and code intelligence. This repository contains documentation for creating,
updating, and maintaining a Sourcegraph cluster.

For product and [pricing](https://about.sourcegraph.com/pricing/) information, visit
[about.sourcegraph.com](https://about.sourcegraph.com) or [contact
us](https://about.sourcegraph.com/contact/sales) for more information. If you're just starting out,
we recommend running Sourcegraph as a [single Docker
container](https://docs.sourcegraph.com/#quickstart-guide) or using [Docker
Compose](https://docs.sourcegraph.com/admin/install/docker-compose). Migrating to Sourcegraph on
Kubernetes is easy later.

- [Installing](https://docs.sourcegraph.com/admin/install/kubernetes)
- [Configuring](https://docs.sourcegraph.com/admin/install/kubernetes/configure)
- [Updating](https://docs.sourcegraph.com/admin/updates/kubernetes)
- [Scaling](https://docs.sourcegraph.com/admin/install/kubernetes/scale)
- [Troubleshooting](https://docs.sourcegraph.com/admin/install/kubernetes/troubleshoot)
- [Admin guide](https://docs.sourcegraph.com/admin) - useful guide for Sourcegraph admins
  - [Metrics](https://docs.sourcegraph.com/admin/observability/metrics) - guidance of metrics that can be used for monitoring Sourcegraph

## Kubernetes alternatives

We recommend using Kubernetes for deploying Sourcegraph (see above for installation instructions). However, we understand not everyone can use Kubernetes or may prefer their own container infrastructure. If this is the case, check out our [pure-Docker deployment reference](https://github.com/sourcegraph/deploy-sourcegraph-docker).

## Contributing

We've made our deployment configurations open source to better serve our customers' needs. If there is anything we can do to make deploying Sourcegraph easier just [open an issue (in sourcegraph/sourcegraph)](https://github.com/sourcegraph/sourcegraph/issues/new?assignees=&labels=deploy-sourcegraph&template=deploy-sourcegraph.md&title=%5Bdeploy-sourcegraph%5D) or a pull request and we will respond promptly!

## Questions & Issues

[Open an issue (in sourcegraph/sourcegraph)](https://github.com/sourcegraph/sourcegraph/issues/new?assignees=&labels=deploy-sourcegraph&template=deploy-sourcegraph.md&title=%5Bdeploy-sourcegraph%5D) or contact us (support@sourcegraph.com), we are happy to help!
