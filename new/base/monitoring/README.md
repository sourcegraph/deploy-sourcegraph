# Monitoring Stacks of Sourcegraph

A Kubernetes cluster with role-based access control (RBAC) enabled is required for the monitoring services to work in your deployment.

The monitoring stacks include the following services:

- cadvisor
- grafana
- node-exporter
- prometheus

To deploye otel-collector to trace data, please use the [otel-collector component](new/components/otel-collector).
