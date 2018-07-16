persistent volume claim Storage class
Migration
noGoGetDomains -> NO_GO_GET_DOMAINS xlang-go

// https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user nick@sourcegraph.com

Config file name

- generate content hash of config.json data stored in config-file.ConfigMap.yaml
- replace references of config-file to config-file-asdf

```
- configMap:
    defaultMode: 464
    name: config-file
    name: sg-config
```

Customize gitserver replicas

- Ask for number of gitserver replicas
- Copy each gitserver-1._.yaml into gitserver-i._.yaml

Default storage class

- Prompt for name of storage class to use
- Replace/add to all PersistentVolumeClaims
