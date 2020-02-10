package base

service: grafana: {
	spec: {
		ports: [{
			name:       "http"
			port:       30070
			targetPort: "http"
		}]
	}
}
