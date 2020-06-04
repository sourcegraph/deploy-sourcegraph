package kube

persistentVolumeClaim: "redis-cache": {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "redis-cache"
	}
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "100Gi"
		storageClassName: "sourcegraph"
	}
}
