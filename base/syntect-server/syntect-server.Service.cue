package base

service: "syntect-server": {
	spec: {
		ports: [{
			name:       "http"
			port:       9238
			targetPort: "http"
		}]
	}
}
