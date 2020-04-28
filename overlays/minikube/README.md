This kustomization deletes resource declarations and storage classnames to enable runnning Sourcegraph on minikube.

Starting Sourcegraph:

To use it, execute the following command from the root directory of this repository:

```shell script
./overlay-generate-cluster.sh minikube generated-cluster
```

After executing the script you can apply the generated manifests from the `generated-cluster` directory:

```shell script
minikube start
cd overlays/minikube
kubectl create namespace ns-sourcegraph
<<<<<<< HEAD
kubectl -n ns-sourcegraph apply -l deploy=sourcegraph -k .
kubectl -n ns-sourcegraph expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph
=======
kubectl -n ns-sourcegraph apply --prune -l deploy=sourcegraph -f generated-cluster --recursive
kubectl -n ns-sourcegraph expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --port=3080 --target-port=3080
>>>>>>> 809b224b... back to root user (#656)
minikube service list
``` 

Tearing it down:

```shell script
kubectl delete namespaces ns-sourcegraph
minikube stop
``` 
