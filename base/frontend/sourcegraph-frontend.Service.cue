package base

service: "sourcegraph-frontend": {
	spec: {
		ports: [{
			name:       "http"
			port:       30080
			targetPort: "http"
		}]
	}
}
