package kube

service: "sourcegraph-frontend-internal": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		labels: {
			app:                             "sourcegraph-frontend"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "sourcegraph-frontend-internal"
	}
	spec: {
		ports: [{
			name:       "http-internal"
			port:       80
			targetPort: "http-internal"
		}]
		selector: app: "sourcegraph-frontend"
		type: "ClusterIP"
	}
}
