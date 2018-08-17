# Installation

> **Note:** Sourcegraph sends performance and usage data to Sourcegraph to help us make our product
> better for you. The data sent does NOT include any source code or file data (including URLs that
> might implicitly contain this information). You can view traces and disable telemetry in the site
> admin area on the server.

## Requirements

- [Kubernetes](https://kubernetes.io/) v1.8.7 or later
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) v1.10.0 or later
  - At the time of writing, `gcloud` bundles `kubectl` 1.9.7, so you will want to install `kubectl` separately.
- Access to server infrastructure on which you can create a Kubernetes cluster (see
  [resource allocation guidelines](scale.md)).

## Install

1. [Provision a Kubernetes cluster](k8s.md) on the infrastructure of your choice.
2. Make sure you have configured `kubectl` to [access your cluster](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/).
3. Deploy Sourcegraph to your Kubernetes cluster:

   ```bash
   git clone https://github.com/sourcegraph/deploy-sourcegraph
   cd deploy-sourcegraph
   git checkout $VERSION # Choose which version you want to deploy
   kubectl apply --prune -l deploy=sourcegraph -f base --recursive
   ```

4. Wait for the deployment to complete.
5. Verify the deployment:

   - Setup port forwarding to the frontend
     ```
     kubectl port-forward svc/sourcegraph-frontend 30080
     ```
   - Open http://localhost:30080 in your browser and you will see a setup page.

You have Sourcegraph up and running!

There are probably
See the [Customization docs](cusomization.md).

### Updating

Updating your cluster to the latest version of Sourcegraph is easy:

```
git clone https://github.com/sourcegraph/deploy-sourcegraph
cd deploy-sourcegraph
kubectl apply --prune -l deploy=sourcegraph -f base --recursive
```

### Troubleshooting

See the [Troubleshooting docs](troubleshoot.md).
