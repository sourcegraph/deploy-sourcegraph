# Updating

To update to a new version of Sourcegraph Data Center, do the following:

1. Check the diff the update will apply to your Kubernetes cluster:
   ```bash
   helm diff upgrade -f values.yaml sourcegraph https://github.com/sourcegraph/datacenter/archive/$VERSION.tar.gz | less -R
   ```
   You can find a list of all version releases here: https://github.com/sourcegraph/deploy-sourcegraph/releases.
1. Apply the update:
   ```bash
   helm upgrade -f values.yaml sourcegraph https://github.com/sourcegraph/datacenter/archive/$VERSION.tar.gz
   ```
1. Check the health of the cluster after upgrade:
   ```bash
   kubectl get pods
   ```

### Rollback

```
helm history sourcegraph
helm rollback sourcegraph [REVISION]
```
