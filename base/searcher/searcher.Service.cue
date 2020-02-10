package base

service: searcher: {
	spec: {
		ports: [{
			name:       "http"
			port:       3181
			targetPort: "http"
		}, {
			name:       "debug"
			port:       6060
			targetPort: "debug"
		}]
	}
}
