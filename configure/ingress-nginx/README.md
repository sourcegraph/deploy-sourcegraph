# Ingress-NGINX

[ingress-nginx](https://github.com/kubernetes/ingress-nginx) provide specialized routing for all of the publically available instances on this cluster.

## Installing / Updating

_These instructions were written with the `0.21.0` release of ingress-nginx https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.21.0_.

_See the installation guide found at https://github.com/kubernetes/ingress-nginx/blob/nginx-0.21.0/docs/deploy/index.md#installation-guide_

1. Run the following `curl` commands to download the generic Kubernetes manifests for ingress-nginx:

   ```shell
   curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.21.0/deploy/mandatory.yaml
   curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.21.0/deploy/provider/cloud-generic.yaml
   ```

   _Note: If you are using AWS, you require a different manifest to `cloud-generic.yaml`. See the ingress-nginx installation guide._

1. Run the following commands:

   ```shell
   kubectl apply -f mandatory.yaml # this should be deployed first so that the namespace is created
   kubectl apply -f cloud-generic.yaml
   ```
