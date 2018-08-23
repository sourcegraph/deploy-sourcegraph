# Prometheus

[Prometheus](https://prometheus.io/) is a metrics and alerting system.

1. Edit `extra.rules` in [prometheus.ConfigMap.yaml](prometheus.ConfigMap.yaml) to contain any additional rules that you want.
2. Optional: [Enable Alertmanager](alertmanager/README.md).
3. Apply the Prometheus resources to your cluster.

   ```bash
   kubectl apply --prune -l deploy=prometheus -f configure/prometheus --recursive
   ```
