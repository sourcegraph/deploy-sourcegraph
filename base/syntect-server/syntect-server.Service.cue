package kube

service: "syntect-server": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		labels: {
			app:                             "syntect-server"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "syntect-server"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       9238
			targetPort: "http"
		}]
		selector: app: "syntect-server"
		type: "ClusterIP"
	}
}
