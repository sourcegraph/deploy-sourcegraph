# Migrations

This document records manual migrations that are necessary to apply when upgrading to certain
Sourcegraph versions. All manual migrations between the version you are upgrading from and the
version you are upgrading to should be applied (unless otherwise noted).

## 3.0

🚨 If you have not migrated off of helm yet, please refer to [docs/helm.migrate.md](helm.migrate.md) before reading the following notes for migrating to Sourcegraph 3.0.

🚨 Please upgrade your Sourcegraph instance to 2.13.x before reading the following notes for migrating to Sourcegraph 3.0.

### `sourcegraph-frontend` service type 

The type of the `sourcegraph-frontend` service ([base/frontend/sourcegraph-frontend.Service.yaml](../base/frontend/sourcegraph-frontend.Service.yaml)) has changed
from `NodePort` to `ClusterIP`. Directly applying this change [will
fail](https://github.com/kubernetes/kubernetes/issues/42282). Instead, you must delete the old
service and then create the new one (this will result in a few seconds of downtime):

```shell
kubectl delete svc sourcegraph-frontend
kubectl apply -f base/frontend/sourcegraph-frontend.Service.yaml
```

### Language server deployment

Sourcegraph 3.0 removed lsp-proxy and automatic language server deployment in favor of [Sourcegraph extensions](https://docs.sourcegraph.com/extensions). As a consequence, Sourcegraph 3.0 does not automatically run or manage language servers. If you had code intelligence enabled in 2.x, you will need to follow the instructions for each language extension and deploy them individually. Read the [code intelligence documentation](https://docs.sourcegraph.com/user/code_intelligence).

### HTTPS / TLS

Sourcegraph 3.0 removed HTTPS / TLS features from Sourcegraph in favor of relying on [Kubernetes Ingress Resources](https://kubernetes.io/docs/concepts/services-networking/ingress/). As a consequence, Sourcegraph 3.0 does not expose TLS as the NodePort 30433. Instead you need to ensure you have setup and configured either an ingress controller (recommended) or an explicit NGINX service. See [ingress controller documentation](configure.md#ingress-controller-recommended), [NGINX service documentation](configure.md#nginx-service), and [configure TLS/SSL documentation](configure.md#configure-tlsssl).

If you previously configured `TLS_KEY` and `TLS_CERT` environment variables, you can remove them from [base/frontend/sourcegraph-frontend.Deployment.yaml](../base/frontend/sourcegraph-frontend.Deployment.yaml)

## 2.12

Beginning in version 2.12.0, Sourcegraph's Kubernetes deployment [requires an Enterprise license key](https://about.sourcegraph.com/pricing). Follow the steps in [docs/configure.md](docs/configure.md#add-a-license-key).

## Postgres 11.1

Sourcegraph 3.0 ships with Postgres 11.1. The upgrade procedure is mostly automatic. Please read [this page](https://docs.sourcegraph.com/admin/postgres) for detailed information.
