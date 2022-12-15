# Storageclass Overlay for Amazon Web Services (AWS)

## Prerequisite

- Kubernetes 1.19 or higher
- Follow the [official instructions](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) to deploy the Amazon Elastic Block Store (Amazon EBS) Container Storage Interface (CSI) driver

## Overview

Sourcegraph by default requires a storage class for all persisent volumes claims. By default this storage class is called sourcegraph. This storage class must be configured before applying the base configuration to your cluster. 

Deploying Sourcegraph using this overlay will:

- Create base/sourcegraph.StorageClass.yaml with the appropriate configuration for AWS
- The sourcegraph StorageClass will retain any persistent volumes created in the event of an accidental deletion of a persistent volume claim.
- The sourcegraph StorageClass also allows the persistent volumes to expand their storage capacity by increasing the size of the related persistent volume claim.

This cannot be changed once the storage class has been created. Persistent volumes not created with the reclaimPolicy set to Retain can be patched with the following command:

```bash
kubectl patch pv <your-pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```