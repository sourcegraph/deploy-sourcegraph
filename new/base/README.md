# Sourcegraph Kubernetes Base Cluster

The `sourcegraph` directory contains manifests for all services for the Sourcegraph main stacks.

The `monitoring` directory contains manifests for all Sourcegraph monitoring services.

## RBAC

Sourcegraph communicates with the Kubernetes API for service discovery. It also has some janitor DaemonSets that clean up temporary cache data. To do that we need to create RBAC resources.

A Kubernetes cluster with role-based access control (RBAC) enabled is **required** for the `monitoring services` to work in your deployment.

If using cluster roles and cluster rolebinding RBAC is not an option, you can skip the monitoring stacks as they will not work in your cluster.

## Deploy Sourcegraph

Read our docs on deploying Sourcegraph using Kustomize for the latest detailed instructions.

## Deploy Sourcegraph with all services

> IMPORTANT: **A Kubernetes cluster with role-based access control (RBAC) enabled is required.**

To deploy Sourcegraph with all services, including the main app and the monitoring stacks, you can list the base resources (../../base) under the `resources` field in the `kustomization.yaml` file for your deployment:

```yaml
# example kustomization.yaml file
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: sourcegraph-full-app
resources:
  # Sourcegraph full app
  - ../../base
```

### Deploy Sourcegraph without the monitoring stacks

If using cluster roles and cluster rolebinding RBAC is not an option, you can skip deploying the monitoring stacks as they will not work in your cluster.

To deploy Sourcegraph without the monitoring stacks, you can list the `main sourcegraph stacks` (../../base/sourcegraph) under the `resources` field in the `kustomization.yaml` file for your deployment:

```yaml
# example kustomization.yaml file
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: sourcegraph-main-only
resources:
  # Sourcegraph Main Stacks
  - ../../base/sourcegraph
```

### Add the monitoring stacks as a component

> IMPORTANT: **A Kubernetes cluster with role-based access control (RBAC) enabled is required.**

If you want to add the monitoring stacks to your current monitoring-less deployment, you can add the `monitoring stacks` (../../components/monitoring) under the `components` field in the `kustomization.yaml` file for your deployment:

```yaml
# example kustomization.yaml file
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: sourcegraph-add-monitoring
resources:
  # Sourcegraph Main Stacks
  - ../../base/sourcegraph
components:
  # Add monitoring components here
  - ../../components/monitoring
```
