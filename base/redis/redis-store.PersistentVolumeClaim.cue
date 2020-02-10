package base

persistentVolumeClaim: "redis-store": {
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "100Gi"
		storageClassName: "sourcegraph"
	}
}
