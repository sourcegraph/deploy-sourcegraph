package base

service: replacer: {
	spec: {
		ports: [{
			name:       "http"
			port:       3185
			targetPort: "http"
		}, {
			name:       "debug"
			port:       6060
			targetPort: "debug"
		}]
	}
}
