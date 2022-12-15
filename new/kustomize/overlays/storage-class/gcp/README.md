# Storageclass Overlay for Google Cloud Platform (GCP)

## Prerequisite

- Kubernetes 1.19 or higher
- Please read and follow the [official documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver) for enabling the persistent disk CSI driver on a [new](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver#enabling_the_on_a_new_cluster) or [existing](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver#enabling_the_on_an_existing_cluster) cluster.

## Overview

Sourcegraph by default requires a storage class for all persisent volumes claims. By default this storage class is called sourcegraph. This storage class must be configured before applying the base configuration to your cluster. 

Deploying Sourcegraph using this overlay will:

- Create base/sourcegraph.StorageClass.yaml with the appropriate configuration for GCP
- The sourcegraph StorageClass will retain any persistent volumes created in the event of an accidental deletion of a persistent volume claim.
- The sourcegraph StorageClass also allows the persistent volumes to expand their storage capacity by increasing the size of the related persistent volume claim.

This cannot be changed once the storage class has been created. Persistent volumes not created with the reclaimPolicy set to Retain can be patched with the following command:

```bash
kubectl patch pv <your-pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```