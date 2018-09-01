# Alertmanager

[Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) handles alerts sent by client applications such as the Prometheus server. It takes care of deduplicating, grouping, and routing them to the correct receiver integration such as email, PagerDuty, or OpsGenie. It also takes care of silencing and inhibition of alerts.

1. Update `data."config.yml"` in [alertmanager.ConfigMap.yaml](alertmanager.ConfigMap.yaml) with your Alertmanager configuration.
2. Update [alertmanager.Deployment.yaml](alertmanager.Deployment.yaml) with the URL to your Alertmanager instance.

   ```bash
   ALERT_MANAGER_URL="https://alertmanager.example.com" # update this url
   AD=configure/prometheus/alertmanager/alertmanager.Deployment.yaml
   cat $AD | yj | jq "(.spec.template.spec.containers[] | select(.name == \"alertmanager\") | .args) |= (. + [\"--web.external-url=$ALERT_MANAGER_URL\"] | unique)" | jy -o $AD
   ```

3. Update [../prometheus.Deployment.yaml](prometheus.Deployment.yaml) with the URL to your Alertmanager instance.

   ```bash
   ALERT_MANAGER_URL="https://alertmanager.example.com" # update this url
   PD=configure/prometheus/prometheus.Deployment.yaml
   cat $PD | yj | jq "(.spec.template.spec.containers[] | select(.name == \"prometheus\") | .args) |= (. + [\"--web.external-url=$ALERT_MANAGER_URL\"] | unique)" | jy -o $PD
   ```

4. Apply the Alertmanager resources to your cluster.

   ```bash
   kubectl apply --prune -l deploy=alertmanager -f configure/prometheus/alertmanager --recursive
   ```

5. Apply the Prometheus resources to your cluster.

   ```bash
   kubectl apply --prune -l deploy=prometheus -f configure/prometheus --recursive
   ```
