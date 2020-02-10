package base

service: "redis-cache": {
	metadata: {
		annotations: {
			"prometheus.io/port": "9121"
		}
	}
	spec: {
		ports: [{
			name:       "redis"
			port:       6379
			targetPort: "redis"
		}]
	}
}
