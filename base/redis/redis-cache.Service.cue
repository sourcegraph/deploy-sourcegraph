package kube

service: "redis-cache": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "9121"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "redis-cache"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "redis-cache"
	}
	spec: {
		ports: [{
			name:       "redis"
			port:       6379
			targetPort: "redis"
		}]
		selector: app: "redis-cache"
		type: "ClusterIP"
	}
}
