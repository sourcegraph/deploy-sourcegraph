# Sourcegraph Kubernetes Base Cluster

The `sourcegraph` directory contains manifests for all services for the Sourcegraph main stacks.

The `monitoring` directory contains manifests for all Sourcegraph monitoring services.

## RBAC

Sourcegraph communicates with the Kubernetes API for service discovery. It also has some janitor DaemonSets that clean up temporary cache data. To do that we need to create RBAC resources.

A Kubernetes cluster with role-based access control (RBAC) enabled is **required** for the `monitoring services` to work properly in your deployment.

If using cluster roles and cluster rolebinding RBAC is not an option, you can deploy Sourcegraph without the monitoring stacks (exclude the monitoring component) as they will not work in your cluster.

## Deploy Sourcegraph

See the [Sourcegraph Kustomize docs](https://docs.sourcegraph.com/admin/deploy/kubernetes/kustomize) for the latested instructions.
