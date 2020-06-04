package kube

deployment: "query-runner": {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		annotations: description:                "Saved search query runner / notification service."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "query-runner"
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "query-runner"
		strategy: {
			rollingUpdate: {
				maxSurge:       1
				maxUnavailable: 0
			}
			type: "RollingUpdate"
		}
		template: {
			metadata: labels: {
				deploy: "sourcegraph"
				app:    "query-runner"
			}
			spec: {
				containers: [{
					env: []
					image:                    "index.docker.io/sourcegraph/query-runner:3.16.0@sha256:8db48c533125318a4981ecd1dc8177ba533e2830c79efd50480e301513bb072d"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "query-runner"
					ports: [{
						containerPort: 3183
						name:          "http"
					}]
					resources: {
						limits: {
							cpu:    *"1" | string | int
							memory: *"1G" | string | int
						}
						requests: {
							cpu:    *"500m" | string | int
							memory: *"1G" | string | int
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
