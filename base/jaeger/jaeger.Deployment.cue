package kube

deployment: jaeger: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name: "jaeger"
		labels: {
			"sourcegraph-resource-requires": "no-cluster-admin"
			app:                             "jaeger"
			"app.kubernetes.io/name":        "jaeger"
			"app.kubernetes.io/component":   "all-in-one"
		}
	}
	spec: {
		selector: matchLabels: {
			app:                           "jaeger"
			"app.kubernetes.io/name":      "jaeger"
			"app.kubernetes.io/component": "all-in-one"
		}
		strategy: type: "Recreate"
		template: {
			metadata: {
				labels: {
					app:                           "jaeger"
					deploy:                        "sourcegraph"
					"app.kubernetes.io/name":      "jaeger"
					"app.kubernetes.io/component": "all-in-one"
				}
				annotations: {
					"prometheus.io/scrape": "true"
					"prometheus.io/port":   "16686"
				}
			}
			spec: {
				containers: [{
					image: "index.docker.io/sourcegraph/jaeger-all-in-one:3.16.0@sha256:5dc2e970804028fc945abffc6c961d755df3b1d7b0b6f6516e9f67cb218ed249"
					name:  "jaeger"
					args: ["--memory.max-traces=20000"]
					ports: [{
						containerPort: 5775
						protocol:      "UDP"
					}, {
						containerPort: 6831
						protocol:      "UDP"
					}, {
						containerPort: 6832
						protocol:      "UDP"
					}, {
						containerPort: 5778
						protocol:      "TCP"
					}, {
						containerPort: 16686
						protocol:      "TCP"
					}, {
						containerPort: 14250
						protocol:      "TCP"
					}]
					readinessProbe: {
						httpGet: {
							path: "/"
							port: 14269
						}
						initialDelaySeconds: 5
					}
					resources: {
						limits: {
							cpu:    *"1" | string | int
							memory: *"1G" | string | int
						}
						requests: {
							cpu:    *"500m" | string | int
							memory: *"500M" | string | int
						}
					}
				}]
				securityContext: runAsUser: 0
			}
		}
	}
}
