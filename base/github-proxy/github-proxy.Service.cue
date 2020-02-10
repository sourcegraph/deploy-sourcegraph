package base

service: "github-proxy": {
	spec: {
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http"
		}]
	}
}
