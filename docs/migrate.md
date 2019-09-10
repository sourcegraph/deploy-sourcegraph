# Migrations

This document records manual migrations that are necessary to apply when upgrading to certain
Sourcegraph versions. All manual migrations between the version you are upgrading from and the
version you are upgrading to should be applied (unless otherwise noted).

## 3.8

If you're deploying Sourcegraph into a non-default namespace, refer to ["Use non-default namespace" in docs/configure.md](configure.md#use-non-default-namespace) for further configuration instructions.

## 3.7.1 (downgrading)

**If you upgrade to v3.7.1 and intend to downgrade back to v3.6 for any reason, please note that reindexing must occur and in the meantime search will effectively be unindexed and performance will suffer substantially.**

**Instead of downgrading**, we suggest turning off indexed symbol search if you suffer issues: set `search.index.symbols.enabled` to `false` in your site configuration, then wait for reindexing to finish (approximately 6,000 repositories will be indexed per hour, you can check the status at e.g. https://sourcegraph.example.com/site-admin/repositories?filter=needs-index).

If you must downgrade, prepare a window when you can do this with acceptable downtime. Expect roughly 1 hour per 6,000 repositories. Upon downgrade from v3.7.x to v3.6.x:

1. Reindexing will begin generating index files in the format used by v3.6.
2. The v3.7 index files will remain on disk (in the indexed-search pod / zoekt data directory). You may run out of disk space if you do not have enough spare space, so we advise manually deleting the new format files immediately before / after downgrading:

```sh
# Grab a shell:
$ kubectl exec -it indexed-search --container zoekt-webserver -- /bin/sh

# Confirm how many index files in the new format will be deleted:
$ ls /data/*_v16*.zoekt | wc -l
12793

# Delete the new format index files:
$ sudo rm -rf /data/*_v16*.zoekt
```

Proceed with the downgrade to v3.6, then wait for reindexing to finish.

## 3.0

🚨 If you have not migrated off of helm yet, please refer to [docs/helm.migrate.md](helm.migrate.md) before reading the following notes for migrating to Sourcegraph 3.0.

🚨 Please upgrade your Sourcegraph instance to 2.13.x before reading the following notes for migrating to Sourcegraph 3.0.

### Configuration

In Sourcegraph 3.0 all site configuration has been moved out of the `config-file.ConfigMap.yaml` and into the PostgreSQL database. We have an automatic migration if you use version 3.2 or before. Please do not upgrade directly from 2.x to 3.3 or higher.

After running 3.0, you should visit the configuration page (`/site-admin/configuration`) and [the management console](https://docs.sourcegraph.com/admin/management_console) and ensure that your configuration is as expected. In some rare cases, automatic migration may not be able to properly carry over some settings and you may need to reconfigure them.

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

### Postgres 11.1

Sourcegraph 3.0 ships with Postgres 11.1. The upgrade procedure is mostly automatic. Please read [this page](https://docs.sourcegraph.com/admin/postgres) for detailed information.

## 2.12

Beginning in version 2.12.0, Sourcegraph's Kubernetes deployment [requires an Enterprise license key](https://about.sourcegraph.com/pricing). Follow the steps in [docs/configure.md](docs/configure.md#add-a-license-key).

