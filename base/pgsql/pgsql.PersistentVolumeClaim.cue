package kube

persistentVolumeClaim: pgsql: {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "pgsql"
	}
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "200Gi"
		storageClassName: "sourcegraph"
	}
}
