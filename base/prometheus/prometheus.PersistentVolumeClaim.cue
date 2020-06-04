package kube

persistentVolumeClaim: prometheus: {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "prometheus"
	}
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "200Gi"
		storageClassName: "sourcegraph"
	}
}
