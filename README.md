# Sourcegraph on Kubernetes

[![sourcegraph: search](https://img.shields.io/badge/sourcegraph-search-brightgreen.svg)](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph) [![master build status](https://badge.buildkite.com/018ed23ed79d7297e7dd109b745597c58d875323fb06e81786.svg?branch=master)](https://buildkite.com/sourcegraph/deploy-sourcegraph)

> 🚨 IMPORTANT: When upgrading Sourcegraph, please check [upgrading docs](https://docs.sourcegraph.com/admin/updates/kubernetes) to check if any manual migrations are necessary.
>
> The `master` branch tracks development. Use the branch of this repository corresponding to the
> version of Sourcegraph you wish to deploy, e.g. `git checkout 3.19`.

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
- [Scaling](https://docs.sourcegraph.com/admin/install/kubernetes/scale)- general advice on scaling services
- [Resource estimator](https://docs.sourcegraph.com/admin/install) - specific resource values for your instance
- [Troubleshooting](https://docs.sourcegraph.com/admin/install/kubernetes/troubleshoot)
- [Enterprise Getting Started Guide](https://docs.sourcegraph.com/adopt/enterprise_getting_started_guide#kubernetes-admin) and [Admin guide](https://docs.sourcegraph.com/admin) - useful guides for Sourcegraph admins
  - [Metrics](https://docs.sourcegraph.com/admin/observability/metrics) - guidance of metrics that can be used for monitoring Sourcegraph

## Is Kubernetes the right deployment type for me?

Please see [our docs](https://docs.sourcegraph.com/admin/install) for comparisons of deployment types and our resource estimator.

## Contributing

We've made our deployment configurations open source to better serve our customers' needs. If there is anything we can do to make deploying Sourcegraph easier just [open an issue (in sourcegraph/sourcegraph)](https://github.com/sourcegraph/sourcegraph/issues/new?assignees=&labels=deploy-sourcegraph&template=deploy-sourcegraph.md&title=%5Bdeploy-sourcegraph%5D) or a pull request and we will respond promptly!

## Questions & Issues

[Open an issue (in sourcegraph/sourcegraph)](https://github.com/sourcegraph/sourcegraph/issues/new?assignees=&labels=deploy-sourcegraph&template=deploy-sourcegraph.md&title=%5Bdeploy-sourcegraph%5D) or contact us (support@sourcegraph.com), we are happy to help!
