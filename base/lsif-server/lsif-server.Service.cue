package base

service: "lsif-server": {
	spec: {
		ports: [{
			name:       "server"
			port:       3186
			targetPort: "server"
		}, {
			name:       "worker"
			port:       3187
			targetPort: "worker"
		}]
	}
}
