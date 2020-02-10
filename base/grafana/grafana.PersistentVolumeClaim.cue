package base

persistentVolumeClaim: grafana: {
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "200Gi"
		storageClassName: "sourcegraph"
	}
}
