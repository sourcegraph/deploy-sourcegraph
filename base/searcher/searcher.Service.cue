package kube

service: searcher: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "6060"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "searcher"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "searcher"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       3181
			targetPort: "http"
		}, {
			name:       "debug"
			port:       6060
			targetPort: "debug"
		}]
		selector: app: "searcher"
		type: "ClusterIP"
	}
}
