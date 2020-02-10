package base

service: symbols: {
	spec: {
		ports: [{
			name:       "http"
			port:       3184
			targetPort: "http"
		}, {
			name:       "debug"
			port:       6060
			targetPort: "debug"
		}]
	}
}
