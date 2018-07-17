persistent volume claim Storage class
Migration
noGoGetDomains -> NO_GO_GET_DOMAINS xlang-go

// https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user nick@sourcegraph.com

Customize gitserver replicas

- Ask for number of gitserver replicas
- Copy each gitserver-1._.yaml into gitserver-i._.yaml

Default storage class

- Prompt for name of storage class to use
- Replace/add to all PersistentVolumeClaims
