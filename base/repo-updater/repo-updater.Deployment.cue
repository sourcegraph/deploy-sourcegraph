package kube

deployment: "repo-updater": {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		annotations: description: "Handles repository metadata (not Git data) lookups and updates from external code hosts and other similar services."

		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "repo-updater"
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "repo-updater"
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
				app:    "repo-updater"
			}
			spec: {
				containers: [{
					image: "index.docker.io/sourcegraph/repo-updater:3.16.0@sha256:4ed82310dc1d435041748660a377a59c1dc530317d61bc4b080a0c1ef6ce4cb9"
					env: []
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "repo-updater"
					ports: [{
						containerPort: 3182
						name:          "http"
					}, {
						containerPort: 6060
						name:          "debug"
					}]
					resources: {
						limits: {
							cpu:    *"100m" | string | int
							memory: *"500Mi" | string | int
						}
						requests: {
							cpu:    *"100m" | string | int
							memory: *"500Mi" | string | int
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
