package base

service: pgsql: {
	metadata: {
		annotations: {
			"prometheus.io/port": "9187"
		}
	}
	spec: {
		ports: [{
			name:       "pgsql"
			port:       5432
			targetPort: "pgsql"
		}]
	}
}
