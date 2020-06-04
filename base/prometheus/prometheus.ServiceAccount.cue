package kube

serviceAccount: prometheus: {
	apiVersion: "v1"
	imagePullSecrets: [{
		name: "docker-registry"
	}]
	kind: "ServiceAccount"
	metadata: {
		labels: {
			category:                        "rbac"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "prometheus"
	}
}
