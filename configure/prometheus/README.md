# Prometheus

[Prometheus](https://prometheus.io/) is an open-source application monitoring system and time series database. It is commonly used to track key performance metrics over time, such as the following:

- QPS
- Application requests by URL route name
- HTTP response latency
- HTTP error codes
- Time since last search index update

<img src="./images/prometheus.png" />

## Steps

1. Edit `extra.rules` in [prometheus.ConfigMap.yaml](prometheus.ConfigMap.yaml) to define custom [Prometheus recording rules](https://prometheus.io/docs/practices/rules/).

   Here are some example rules:

   ```
   # This is a comment
   myCustomMetric1 = rate(src_http_request_duration_seconds_bucket{job=~"sourcegraph-.*"}[5m])
   myCustomMetric2 = sum by (route, ns, le)(task:src_http_request_duration_seconds_bucket:rate5m)
   ```

1. Optional: [Enable Alertmanager](alertmanager/README.md).

1. Append the `kubectl apply` command for the Prometheus resources to your cluster.

   ```bash
   echo kubectl apply --prune -l deploy=prometheus -f configure/prometheus --recursive >> kubectl-apply-all.sh
   ```

1. Apply your changes to Prometheus to the cluster.

   ```bash
   ./kubectl-apply-all.sh
   ```

## Making Prometheus accessible

### Port-forwarding

Use `kubectl port-forward` to grant direct access to the Prometheus UI. This is the simplest way to
access Prometheus data, but requires access to the cluster via `kubectl`.

1.  Forward port 9090:
    ```bash
    kubectl port-forward $(kubectl get pods -l app=prometheus -o jsonpath="{.items[0].metadata.name}") 9090
    ```
1.  Navigate to `http://localhost:9090`.

### Kubernetes service

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
ingress rules allow will have _complete access_ to the Prometheus UI. Be careful that the ingress
rules restrict incoming traffic to trusted sources.

If a stable IP is required, provision a static IP and an external load balancer in lieu of adding
ingress rules. On most infrastructure providers, the steps are roughly the following:

- Provision the static IP.
- Create an external load balancer. (On AWS, use an "Application Load Balancer".)
- Connect the internal/backend half of the load balancer to the set of nodes in the Kubernetes
  cluster. (On AWS, create a "target group" that contains the instances in the cluster. On Google
  Cloud, define a "target pool".)
- Connect the external/frontend half of the load balancer to the static IP. (On AWS, create a
  "listener rule". On Google Cloud, create a "forwarding rule".)

### Exposing the Prometheus API endpoint

Some customers may want to make the Prometheus API endpoint accessible to other services like the
following:

- An analytics visualization tool like Grafana
- An metrics ingestion pipeline

To expose the Prometheus API to such a service, follow the steps to expose Prometheus via Kubernetes
service with an external load balancer. Ensure that the load balancer permits incoming traffic from
the other service. The [Prometheus API](https://prometheus.io/docs/prometheus/latest/querying/api/)
is reachable under the path `/api/v1`.

## Defining alerts

The following alerts are recommended and included by default when Prometheus is enabled:

- `PodsMissing`: Alerts when pods are missing.
- `NoPodsRunning`: Alerts when no pods are running for a service.
- `ProdPageLoadLatency`: Alerts when the page load latency is too high.
- `GoroutineLeak`: Alerts when a service has excessive running goroutines.
- `FSINodesRemainingLow`: Alerts when a node's remaining FS inodes are low.
- `DiskSpaceLow`: Alerts when a node has less than 10% available disk space.
- `DiskSpaceLowCritical`: Alerts when a node has less than 5% available disk space.
- `SearcherErrorRatioTooHigh`: Alerts when the search service has more than 10% of requests failing.

You can view these alerts and their definitions in the Prometheus UI under the "Alerts" tab
(http://localhost:9090/alerts if you're using `kubectl port-forward` to expose the Prometheus UI).

Refer to the [Prometheus alerting rules docs](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) for the alert definition syntax. To see the definition of the default alerts, open the Prometheus "Alerts" tab and click on the rule of interest. These can be useful starting points for defining new alerting rules.

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

## Metrics

See the [Prometheus metrics page](prom-metrics.md) for a full list of available
Prometheus metrics.

## Sample queries

Sourcegraph Data Center's Prometheus includes by default many useful metrics for tracking
application performance. The following are some commonly used queries that you can try out in the
UI:

- Average (5-minute) HTTP requests per second: `job:src_http_request_count:rate5m`
- Average (5-minute) HTTP requests per second, bucketed by request duration:
  `route:src_http_request_duration_seconds_bucket:rate5m`
- CPU utilization by container: `max by (container_name)(task:container_cpu_usage_seconds_total:sum{container_name=~"$name"})`
- Memory utilization by container: `max by (container_name)(container_memory_rss{container_name=~"$name"}) / 1024 / 1024 / 1024`
