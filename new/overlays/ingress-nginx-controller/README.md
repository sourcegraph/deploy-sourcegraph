# Ingress-NGINX Controller

[ingress-nginx](https://github.com/kubernetes/ingress-nginx) provide specialized routing for all of the publicly available instances on this cluster.

## How to use

### Remote Build

This overlay is for creating resources to deploy a `ingress-nginx-controller` along side with Sourcegraph. It utilizes the remote build function to get the resources from the official [ingress-nginx-controller repository](https://github.com/kubernetes/ingress-nginx).

See a list of available deployments at https://github.com/kubernetes/ingress-nginx/tree/controller-v1.5.1/deploy/static/provider

### Local Build

If you would like to build it using local resources:

1. copy the deploy.yaml file from [one of the provider directories within the official ingress-nginx repository](https://github.com/kubernetes/ingress-nginx/tree/controller-v1.5.1/deploy/static/provider)
2. create a copy of our [ingress-nginx-controller for cloud component](../components/network/ingress-nginx-controller/cloud)
3. replace the [deploy.yaml](../components/network/ingress-nginx-controller/cloud.yaml) with the deploy.yaml file you've copied from step 1
4. Add it as a component in your overlay kustomiziation.yaml file

#### Components

Our [ingress-nginx-controller for cloud component](../components/network/ingress-nginx-controller/cloud) is for creating the resources to deploy the[ v1.5.1 ingress-nginx controller for generic cloud provider](https://github.com/kubernetes/ingress-nginx/tree/controller-v1.5.1/deploy/static/provider/cloud).

### Build

Run the following command to see the manifests built with this overlay:

```bash
kustomize build new/overlays/ingress-nginx-controller > new/generated-cluster.yaml
```
