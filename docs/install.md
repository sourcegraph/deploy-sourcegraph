# Installing Sourcegraph

> **Note:** Sourcegraph sends performance and usage data to Sourcegraph to help us make our product
> better for you. The data sent does NOT include any source code or file data (including URLs that
> might implicitly contain this information). You can view traces and disable telemetry in the site
> admin area on the server.

## Requirements

- [Kubernetes](https://kubernetes.io/) v1.8.7 or later
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) v1.9.7 or later
- Access to server infrastructure on which you can create a Kubernetes cluster (see
  [resource allocation guidelines](scale.md)).

## Steps

1. [Provision a Kubernetes cluster](k8s.md) on the infrastructure of your choice.
2. Make sure you have configured `kubectl` to [access your cluster](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/).

   - If you are using GCP, you'll need to give your user the ability to create roles in Kubernetes [(see GCP's documentation)](https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control#prerequisites_for_using_role-based_access_control):

     ```bash
     kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $USER_EMAIL_ADDRESS
     ```

3. Deploy the desired version of Sourcegraph to your Kubernetes cluster:

   ```bash
   wget https://github.com/sourcegraph/deploy-sourcegraph/archive/${VERSION}.zip # Choose which version you want to deploy from https://github.com/sourcegraph/deploy-sourcegraph/releases
   unzip ${VERSION}.zip
   cd deploy-sourcegraph-${VERSION}
   kubectl apply --prune -l deploy=sourcegraph -f base --recursive
   ```

4. Monitor the status of the deployment.

   ```bash
   watch kubectl get pods -o wide
   ```

5. Once the deployment completes, verify Sourcegraph works:

   - Setup port forwarding to the frontend

     ```bash
     POD=$(kubectl get pod -l app=sourcegraph-frontend -o template --template="{{(index .items 0).metadata.name}}")
     kubectl port-forward $POD 30080:3080
     ```

     kubectl 1.10.0 or later:

     ```
     kubectl port-forward svc/sourcegraph-frontend 30080
     ```

   - Open http://localhost:30080 in your browser and you will see a setup page.

6. [Configure your deployment](configure.md).

You have Sourcegraph up and running!

### Troubleshooting

See the [Troubleshooting docs](troubleshoot.md).
