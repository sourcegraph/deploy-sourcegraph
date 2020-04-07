This kustomization deletes resource declarations and storage classnames to enable runnning Sourcegraph on minikube.

Starting Sourcegraph:

```shell script
minikube start
cd overlays/minikube
kubectl create namespace ns-sourcegraph
kubectl -n ns-sourcegraph apply -l deploy=sourcegraph -k .
kubectl -n ns-sourcegraph expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --port=3080 --target-port=3080
minikube service list
``` 

Tearing it down:

```shell script
kubectl delete namespaces ns-sourcegraph
minikube stop
``` 
