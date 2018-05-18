# Admin guide

This guide is intended for system administrators and operations engineers who are responsible for maintaining a
Sourcegraph Data Center installation. Each section covers a topic or tool that may be helpful in managing a Data Center
cluster.

---

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

*   QPS
*   Application requests by URL route name
*   HTTP response latency
*   HTTP error codes
*   Time since last search index update

<img src="./images/prometheus.png" />

Sourcegraph Data Center includes an optional Prometheus instance. To turn on Prometheus, add the
following snippet to `values.yaml`:

```yaml
site: {
  "prometheus": {}
}
```

After updating the cluster, the running Prometheus pod will be visible in the list printed by
`kubectl get pods`. Once this is enabled, Prometheus will begin recording performance metrics across
all services running in Sourcegraph Data Center.

---

### Making Prometheus accessible

#### Port-forwarding

Use `kubectl port-forward` to grant direct access to the Prometheus UI. This is the simplest way to
access Prometheus data, but requires access to the cluster via `kubectl`.

1.  Run `kubectl port-forward $(kubectl get pods -l app=prometheus -o jsonpath="{.items[0].metadata.name}") 9090`.
1.  Navigate to `http://localhost:9090`.

#### Kubernetes service

Create a YAML file defining
a
[Kubernetes service](https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service) that
exposes the Prometheus deployment.

We recommend using a NodePort service with the following configuration:

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: prometheus
  name: prometheus-node-port
  namespace: default
spec:
  externalTrafficPolicy: Cluster
  ports:
  - name: http
    nodePort: 30010
    port: 30010
    protocol: TCP
    targetPort: http
  selector:
    app: prometheus
  type: NodePort
```

(Note: some cloud infrastructure providers support the "LoadBalancer" service type, which
automatically provisions an external load balancer for the service. We recommend against this type
of service for Prometheus, because almost certainly you do NOT want to expose Prometheus to public
Internet traffic.)

After creating the Prometheus service, add the appropriate network ingress rules in your
infrastructure provider to allow trusted incoming traffic to access port 30010 on nodes in the
Kubernetes cluster. SECURITY NOTE: Prometheus is unauthenticated, so whatever incoming traffic the
ingress rules allow will have _complete access_ to the Prometheus UI.  Be careful that the ingress
rules restrict incoming traffic to trusted sources.

If a stable IP is required, provision a static IP and an external load balancer in lieu of adding
ingress rules. On most infrastructure providers, the steps are roughly the following:

*   Provision the static IP.
*   Create an external load balancer. (On AWS, use an "Application Load Balancer".)
*   Connect the internal/backend half of the load balancer to the set of nodes in the Kubernetes
    cluster. (On AWS, create a "target group" that contains the instances in the cluster. On Google
    Cloud, define a "target pool".)
*   Connect the external/frontend half of the load balancer to the static IP. (On AWS, create a
    "listener rule". On Google Cloud, create a "forwarding rule".)

#### Exposing the Prometheus API endpoint

Some customers may want to make the Prometheus API endpoint accessible to other services like the
following:

*   An analytics visualization tool like Grafana
*   An metrics ingestion pipeline

To expose the Prometheus API to such a service, follow the steps to expose Prometheus via Kubernetes
service with an external load balancer. Ensure that the load balancer permits incoming traffic from
the other service. The [Prometheus API](https://prometheus.io/docs/prometheus/latest/querying/api/)
is reachable under the path `/api/v1`.

---

### Metrics

See the [Prometheus metrics page](metrics.md) for a full list of available
Prometheus metrics.

---

### Sample queries

Sourcegraph Data Center's Prometheus includes by default many useful metrics for tracking
application performance. The following are some commonly used queries that you can try out in the
UI:

*   Average (5-minute) HTTP requests per second: `job:src_http_request_count:rate5m`
*   Average (5-minute) HTTP requests per second, bucketed by request duration:
    `route:src_http_request_duration_seconds_bucket:rate5m`
*   CPU utilization by container: `max by (container_name)(task:container_cpu_usage_seconds_total:sum{container_name=~"$name"})`
*   Memory utilization by container: `max by (container_name)(container_memory_rss{container_name=~"$name"}) / 1024 / 1024 / 1024`

---

### Custom recording rules

Admins can define custom [Prometheus recording rules](https://prometheus.io/docs/practices/rules/)
via the `customPrometheusRules` configuration field.

Add a file named `custom.rules` to the same directory that contains `config.json`. Define your
recording rules in this file. Here's an example:

```
# This is a comment
myCustomMetric1 = rate(src_http_request_duration_seconds_bucket{job=~"sourcegraph-.*"}[5m])
myCustomMetric2 = sum by (route, ns, le)(task:src_http_request_duration_seconds_bucket:rate5m)
```

Add the following flag when running the `helm upgrade ...` command:

```
--set site.customPrometheusRules="$(cat custom.rules)"
```

---

### Alerting

There are two parts to creating actionable alerts:

1.  Define the alerts in Prometheus.
2.  Configure [Prometheus Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) to forward alerts to external
    services like PagerDuty, OpsGenie, Slack, or email.

#### Defining alerts

The following alerts are recommended and included by default when Prometheus is enabled:

*   `PodsMissing`: Alerts when pods are missing.
*   `NoPodsRunning`: Alerts when no pods are running for a service.
*   `ProdPageLoadLatency`: Alerts when the page load latency is too high.
*   `GoroutineLeak`: Alerts when a service has excessive running goroutines.
*   `FSINodesRemainingLow`: Alerts when a node's remaining FS inodes are low.
*   `DiskSpaceLow`: Alerts when a node has less than 10% available disk space.
*   `DiskSpaceLowCritical`: Alerts when a node has less than 5% available disk space.
*   `SearcherErrorRatioTooHigh`: Alerts when the search service has more than 10% of requests failing.

You can view these alerts and their definitions in the Prometheus UI under the "Alerts" tab
(http://localhost:9090/alerts if you're using `kubectl port-forward` to expose the Prometheus UI).

To define additional alerting rules, add them to a file named `custom.rules`. (If you've already created such a file for
custom recording rules, add the alerting rules to the end of the existing file.) Then ensure your `helm update ...`
command contains the following flag:

```
--set site.customPrometheusRules="$(cat custom.rules)"
```

Refer to the
[Prometheus alerting rules docs](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) for the
alert definition syntax. To see the definition of the default alerts, open the Prometheus "Alerts" tab and click on the
rule of interest. These can be useful starting points for defining new alerting rules.

Here is an example alerting rule that fires on high page load latency (specifically when the p90 latency exceeds 20
seconds):

```
ALERT ProdPageLoadLatency
  IF histogram_quantile(0.9, sum(rate(src_http_request_duration_seconds_bucket{job="sourcegraph-frontend",route!="xlang",route!="lsp"}[10m])) by (le)) > 20
  LABELS { severity="page" }
  ANNOTATIONS {
    summary = "High page load latency",
    description = "Page load latency > 20s (90th percentile over all routes; current value: {{$value}}s)",
    help = "Alerts when the page load latency is too high.",
  }
```

The default set of alerts can be disabled with the following config:

```json
  "prometheus": {
    "noDefaultAlerts": true
  }
```

#### Alertmanager

Enable [Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) to send alerts to external services like
PagerDuty, OpsGenie, Slack, or email. To enable, do the following:

1. Add the following to `values.yaml`:
   ```yaml
   site: {
     "useAlertManager": true,
   }
   ```
1. Create a file in the same directory called `alertmanager.yaml`. To determine the contents of this
   file, refer to
   the
   [Alertmanager configuration documentation](https://prometheus.io/docs/alerting/configuration/).
1. Include the following flag when running `helm update ...`:
   ```
   --set site.alertmanagerConfig="$(cat alertmanager.yaml)"
   ```


---

## Distributed tracing

Distributed tracing tools are useful when debugging performance issues such as high query latency. Sourcegraph uses the
[OpenTracing standard](http://opentracing.io/) and can be made to work with any tracing tool that satisfies that
standard. Currently, two tracing tools are supported by Sourcegraph configuration:

*   [Lightstep](https://lightstep.com/)
*   [Jaeger](http://jaegertracing.io/)

---

### Jaeger

Jaeger is an open-source distributed tracing system created by Uber that was inspired by Dapper and OpenZipkin. When
enabled, Sourcegraph Data Center will run a Jaeger instance inside the Kubernetes cluster.

To enable, add the following to `config.json`:

```json
  "useJaeger": true,
```

After applying the config change, some additional manual setup is required to initialize the Jaeger Cassandra DB:

*   Clone https://github.com/jaegertracing/jaeger.
*   Install [cqlsh](http://cassandra.apache.org/doc/latest/tools/cqlsh.html).
*   Run `kubectl port-forward $(kubectl get pods -l app=jaeger-cassandra -o jsonpath='{.items[0].metadata.name}') 9042`
*   In the root directory of the jaeger repositiory, run `env MODE=test sh ./plugin/storage/cassandra/schema/create.sh | cqlsh`

To access the Jaeger UI, run `kubectl port-forward $(kubectl get pods -l app=jaeger-query -o jsonpath='{.items[0].metadata.name}') 16686` and then navigate to http://localhost:16686.

---

### Lightstep

Lightstep is a closed-source distributed tracing and performance monitoring tool created by some of the authors of
Dapper.

To enable, you must first purchase Lightstep and create a project corresponding to the Sourcegraph instance. Then add
the following to `config.json`:

```
  "lightstepAccessToken": "${LIGHTSTEP_TOKEN}"
  "lightstepProject": "${LIGHTSTEP_PROJECT}"
```

## Snapshots

The `sourcegraph-server-gen` command supports creating and restoring snapshots of the database,
which can be useful for backups and syncing database state from one cluster to another:

*   On macOS:
    ```
    curl -O https://storage.googleapis.com/sourcegraph-assets/sourcegraph-server-gen/darwin_amd64/sourcegraph-server-gen
    chmod +x ./sourcegraph-server-gen
    ```
*   On Linux:
    ```bash
    curl -O https://storage.googleapis.com/sourcegraph-assets/sourcegraph-server-gen/linux_amd64/sourcegraph-server-gen
    chmod +x ./sourcegraph-server-gen
    ```

Run `sourcegraph-server-gen snapshot --help` for more information.
