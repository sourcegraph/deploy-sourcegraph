package kube

service: "redis-store": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "9121"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "redis-store"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "redis-store"
	}
	spec: {
		ports: [{
			name:       "redis"
			port:       6379
			targetPort: "redis"
		}]
		selector: app: "redis-store"
		type: "ClusterIP"
	}
}
