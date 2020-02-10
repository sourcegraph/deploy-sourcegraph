package base

persistentVolumeClaim: prometheus: {
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "200Gi"
		storageClassName: "sourcegraph"
	}
}
