package kube

persistentVolumeClaim: "bundle-manager": {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "bundle-manager"
	}
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "200Gi"
		storageClassName: "sourcegraph"
	}
}
