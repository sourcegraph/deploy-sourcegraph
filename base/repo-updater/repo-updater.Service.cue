package base

service: "repo-updater": {
	spec: {
		ports: [{
			name:       "http"
			port:       3182
			targetPort: "http"
		}]
	}
}
