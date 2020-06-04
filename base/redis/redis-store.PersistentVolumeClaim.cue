package kube

persistentVolumeClaim: "redis-store": {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "redis-store"
	}
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "100Gi"
		storageClassName: "sourcegraph"
	}
}
