package base

service: "query-runner": {
	spec: {
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http"
		}]
	}
}
