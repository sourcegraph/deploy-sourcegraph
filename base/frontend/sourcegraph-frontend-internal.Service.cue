package base

service: "sourcegraph-frontend-internal": {
	metadata: {
		labels: {
			app: "sourcegraph-frontend"
		}
	}
	spec: {
		ports: [{
			name:       "http-internal"
			port:       80
			targetPort: "http-internal"
		}]
	}
}
