This kustomization deletes resource declarations and storage classnames to enable runnning Sourcegraph on minikube.

## Prerequisite

- [minikube](https://minikube.sigs.k8s.io/docs/start/)

## Configuration

The Sourcegraph minikube instance requires ~100Gi of free disk space by default (10Gi for each persistentvolumeclaim, 47Gi for all statefulsets etc).

If you wish to lower the disk space requirement, you may adjust the storage values for the PersistentVolumeClaim, gitserver StatefulSet, and indexed-search StatefulSet in the `kustomization.yaml` file accordingly.

## Starting Sourcegraph

To use it, execute the following command from the root directory of this repository:

```shell script
./overlay-generate-cluster.sh minikube generated-cluster
```

After executing the script you can apply the generated manifests from the `generated-cluster` directory:

```shell script
minikube start
kubectl create namespace ns-sourcegraph
kubectl -n ns-sourcegraph apply --prune -l deploy=sourcegraph -f generated-cluster --recursive
kubectl -n ns-sourcegraph expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --port=3080 --target-port=3080
minikube service list
``` 

## Tearing it down

```shell script
kubectl delete namespaces ns-sourcegraph
minikube stop
``` 
