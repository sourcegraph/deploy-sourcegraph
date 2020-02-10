package base

persistentVolumeClaim: "redis-cache": {
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "100Gi"
		storageClassName: "sourcegraph"
	}
}
