package base

persistentVolumeClaim: pgsql: {
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "200Gi"
		storageClassName: "sourcegraph"
	}
}
