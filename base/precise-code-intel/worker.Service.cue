package kube

service: "precise-code-intel-worker": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "6060"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "precise-code-intel-worker"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "precise-code-intel-worker"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       3188
			targetPort: "http"
		}, {
			name:       "debug"
			port:       6060
			targetPort: "debug"
		}]
		selector: app: "precise-code-intel-worker"
		type: "ClusterIP"
	}
}
