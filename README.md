> Note to existing customers: if you are migrating from the old version of Data Center (configured
> using `sourcegraph-server-gen`), see [docs/migrate.md](docs/migrate.md).

# Sourcegraph Data Center (beta)

Sourcegraph Data Center is for organizations that need highly scalable and available code search and
code intelligence. This repository contains documentation for creating, updating, and maintaining a
Sourcegraph Data Center cluster.

For product and [pricing](https://about.sourcegraph.com/pricing/) information,
visit [about.sourcegraph.com](https://about.sourcegraph.com)
or [contact us](https://about.sourcegraph.com/contact/sales) for more information. If you're just
starting out, we recommend installing [Sourcegraph](https://about.sourcegraph.com/docs) on a single
node first. Migrating to Data Center is easy when you're ready.

* [Installation](docs/install.md)
* [Updating](docs/update.md)
* [Scaling](/docs/scale.md)
* [Troubleshooting](/docs/troubleshoot.md)
* [Admin guide](/docs/admin-guide.md) - useful guide for Sourcegraph admins
  * [Prometheus metrics](/docs/prom-metrics.md) - list of all Prometheus metrics that can be used for
    application performance monitoring


## Contributing

We've made this Helm chart open source to better serve our customers' needs. If there is a
configuration point or Kubernetes option you would like to add, we would love to incorporate
it. Pull requests and issues are reviewed and responded to quickly.
