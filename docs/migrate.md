# Migrations

This document records manual migrations that are necessary to apply when upgrading to certain
Sourcegraph versions. All manual migrations between the version you are upgrading from and the
version you are upgrading to should be applied (unless otherwise noted).

## 3.1

The type of the `sourcegraph-frontend` service (`sourcegraph-frontend.Service.yaml`) has changed
from `NodePort` to `ClusterIP`. Directly applying this change [will
fail](https://github.com/kubernetes/kubernetes/issues/42282). Instead, you must delete the old
service and then create the new one (this will result in a few seconds of downtime):

```
kubectl delete svc sourcegraph-frontend
kubectl apply -f base/frontend/sourcegraph-frontend.Service.yaml

```
