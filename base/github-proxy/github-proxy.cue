package kube

deployment: "github-proxy": {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		annotations: description:                "Rate-limiting proxy for the GitHub API."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "github-proxy"
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "github-proxy"
		strategy: {
			rollingUpdate: {
				maxSurge:       1
				maxUnavailable: 0
			}
			type: "RollingUpdate"
		}
		template: {
			metadata: labels: {
				app:    "github-proxy"
				deploy: "sourcegraph"
			}
			spec: {
				containers: [{
					env: []
					image:                    "index.docker.io/sourcegraph/github-proxy:3.16.0@sha256:95bedbc3cd61cdbab1d413cdd44d3de7ae9c99261ab4bd6065520433c515a955"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "github-proxy"
					ports: [{
						containerPort: 3180
						name:          "http"
					}]
					resources: {
						limits: {
							cpu:    *"1" | string | int
							memory: *"1G" | string | int
						}
						requests: {
							cpu:    *"100m" | string | int
							memory: *"250M" | string | int
						}
					}
				}, {
					image: "index.docker.io/sourcegraph/jaeger-agent:3.16.0@sha256:ad1fc2f6b69ba3622f872bb105ef07dec5e5a539d30e733b006e88445dbe61e1"
					name:  "jaeger-agent"
					env: [{
						name: "POD_NAME"
						valueFrom: fieldRef: {
							apiVersion: "v1"
							fieldPath:  "metadata.name"
						}
					}]
					ports: [{
						containerPort: 5775
						protocol:      "UDP"
					}, {
						containerPort: 5778
						protocol:      "TCP"
					}, {
						containerPort: 6831
						protocol:      "UDP"
					}, {
						containerPort: 6832
						protocol:      "UDP"
					}]
					resources: {
						limits: {
							cpu:    *"1" | string | int
							memory: *"500M" | string | int
						}
						requests: {
							cpu:    *"100m" | string | int
							memory: *"100M" | string | int
						}
					}
					args: [
						"--reporter.grpc.host-port=jaeger-collector:14250",
						"--reporter.type=grpc",
					]
				}]
				securityContext: runAsUser: 0
			}
		}
	}
}


service: "github-proxy": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "6060"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "github-proxy"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "github-proxy"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http"
		}]
		selector: app: "github-proxy"
		type: "ClusterIP"
	}
}
