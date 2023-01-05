# Replicas Overlay

An overlay to update replica numbers.

## Example output

In this example, you can see the replica count for `sourcegraph-frontend` has been updated to 0, and 2 for `gitserver`:

```yaml
# .output/apps_v1_deployment_sourcegraph-frontend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    description: Serves the frontend of Sourcegraph via HTTP(S).
    kubectl.kubernetes.io/default-container: frontend
  labels:
    app.kubernetes.io/component: frontend
    deploy: sourcegraph
    sourcegraph-resource-requires: no-cluster-admin
  name: sourcegraph-frontend
  namespace: ns-sourcegraph
spec:
  minReadySeconds: 10
  replicas: 0
```

```yaml
# .output/apps_v1_statefulset_gitserver.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  annotations:
    description: Stores clones of repositories to perform Git operations.
    kubectl.kubernetes.io/default-container: gitserver
  labels:
    app.kubernetes.io/component: gitserver
    deploy: sourcegraph
    sourcegraph-resource-requires: no-cluster-admin
  name: gitserver
  namespace: ns-sourcegraph
spec:
  replicas: 2
```