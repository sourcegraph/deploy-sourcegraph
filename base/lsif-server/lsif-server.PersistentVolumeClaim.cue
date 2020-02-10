package base

persistentVolumeClaim: "lsif-server": {
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "200Gi"
		storageClassName: "sourcegraph"
	}
}
