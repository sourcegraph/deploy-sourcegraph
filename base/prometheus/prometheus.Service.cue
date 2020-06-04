package kube

service: prometheus: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		labels: {
			app:                             "prometheus"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "prometheus"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       30090
			targetPort: "http"
		}]
		selector: app: "prometheus"
		type: "ClusterIP"
	}
}
