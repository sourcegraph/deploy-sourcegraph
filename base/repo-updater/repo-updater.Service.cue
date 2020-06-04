package kube

service: "repo-updater": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "6060"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "repo-updater"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "repo-updater"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       3182
			targetPort: "http"
		}]
		selector: app: "repo-updater"
		type: "ClusterIP"
	}
}
