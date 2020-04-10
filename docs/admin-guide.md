# Admin guide

This guide is intended for system administrators and operations engineers who are responsible for
maintaining a Sourcegraph Kubernetes cluster. Each section covers a topic or tool that may be
helpful in managing the cluster.

## Debugging

The following commands are useful to gain visibility into cluster status.

<div class="table">
<table>

<tr>
  <td>List all pods running</td>
  <td><code>kubectl get pods -o=wide</code></td>
</tr>

<tr>
  <td>Describe pod state, including reasons why a pod is not successfully running.</td>
  <td><code>kubectl describe pod $POD_NAME</code></td>
</tr>

<tr>
  <td>Tail logs</td>
  <td><code>kubectl logs -f $POD_NAME</code></td>
</tr>

<tr>
  <td>SSH into a running pod container.</td>
  <td><code>kubectl exec -it $POD_NAME -- sh</code></td>
</tr>

<tr>
  <td>Get a PostgreSQL client on the prod database.</td>
  <td><code>kubectl exec -it $(kubectl get pods -l app=pgsql -o jsonpath="{.items[0].metadata.name}") -- psql -U sg</code></td>
</tr>

</table>
</div>

---

## Prometheus

[Prometheus](https://prometheus.io/) is an open-source application monitoring system and time series database. It is
commonly used to track key performance metrics over time, such as the following:

- QPS
- Application requests by URL route name
- HTTP response latency
- HTTP error codes
- Time since last search index update

<img src="./images/prometheus.png" />

Follow the [steps to deploy Prometheus](../configure/prometheus/README.md).

After updating the cluster, the running Prometheus pod will be visible in the list printed by
`kubectl get pods`. Once this is enabled, Prometheus will begin recording performance metrics across
all services running in Sourcegraph.

## Distributed tracing

Distributed tracing tools are useful when debugging performance issues such as high query latency. Sourcegraph uses the
[OpenTracing standard](http://opentracing.io/) and can be made to work with any tracing tool that satisfies that
standard. Currently, two tracing tools are supported by Sourcegraph configuration:

- [Lightstep](../configure/configure.md#configure-lightstep-tracing)
- [Jaeger](../configure/jaeger/README.md)

## Snapshots

The `sourcegraph-server-gen` command supports creating and restoring snapshots of the database,
which can be useful for backups and syncing database state from one cluster to another:

- On macOS:
  ```
  curl -O https://storage.googleapis.com/sourcegraph-assets/sourcegraph-server-gen/darwin_amd64/sourcegraph-server-gen
  chmod +x ./sourcegraph-server-gen
  ```
- On Linux:
  ```bash
  curl -O https://storage.googleapis.com/sourcegraph-assets/sourcegraph-server-gen/linux_amd64/sourcegraph-server-gen
  chmod +x ./sourcegraph-server-gen
  ```

Run `sourcegraph-server-gen snapshot --help` for more information.
