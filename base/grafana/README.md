# Grafana

[Grafana](https://https://grafana.com/) is an open-source analytics dashboard application.

A Grafana instance is part of the default Sourcegraph cluster installation.

## Namespaces

If you are deploying Sourcegraph to a non-default namespace, you'll have to change the namespace specified in
[grafana.ClusterRoleBinding.yaml](grafana.ClusterRoleBinding.yaml) to the one that you created.
