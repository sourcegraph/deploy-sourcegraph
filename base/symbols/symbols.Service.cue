package kube

service: symbols: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "6060"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "symbols"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "symbols"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       3184
			targetPort: "http"
		}, {
			name:       "debug"
			port:       6060
			targetPort: "debug"
		}]
		selector: app: "symbols"
		type: "ClusterIP"
	}
}
