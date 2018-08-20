# Installing Sourcegraph

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

## Steps

1. [Provision a Kubernetes cluster](k8s.md) on the infrastructure of your choice.
2. Make sure you have configured `kubectl` to [access your cluster](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/).
3. Deploy the desired version of Sourcegraph to your Kubernetes cluster:

   ```bash
   git clone https://github.com/sourcegraph/deploy-sourcegraph
   cd deploy-sourcegraph
   git checkout $VERSION # Choose which version you want to deploy
   kubectl apply --prune -l deploy=sourcegraph -f base --recursive
   ```

4. Monitor the status of the deployment.

   ```bash
   watch kubectl get pods -o wide
   ```

5. Once the deployment completes, verify Sourcegraph works:

   - Setup port forwarding to the frontend
     ```
     kubectl port-forward svc/sourcegraph-frontend 30080
     ```
   - Open http://localhost:30080 in your browser and you will see a setup page.

6. [Configure your deployment](configure.md).

You have Sourcegraph up and running!

### Troubleshooting

See the [Troubleshooting docs](troubleshoot.md).
