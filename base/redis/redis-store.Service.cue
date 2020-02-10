package base

service: "redis-store": {
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
