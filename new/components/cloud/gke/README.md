# Configuration for deploying to Google Kubernetes Engine (GKE)

This directory includes components to configure:

- a [BackendConfig](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-configuration#create_backendconfig) CRD. This is necessary to instruct the GCP load balancer on how to perform health checks on our deployment.
- Ingress to use [Container-native load balancing](https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing) to expose Sourcegraph publicly on a domain of your choosing and
- Storage Class to use [Compute Engine persistent disk](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver).
