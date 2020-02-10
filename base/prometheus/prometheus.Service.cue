package base

service: prometheus: {
	spec: {
		ports: [{
			name:       "http"
			port:       30090
			targetPort: "http"
		}]
	}
}
