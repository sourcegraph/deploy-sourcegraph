package kube

deployment: searcher: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		annotations: description:                "Backend for text search operations."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "searcher"
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "searcher"
		strategy: {
			rollingUpdate: {
				maxSurge:       1
				maxUnavailable: 1
			}
			type: "RollingUpdate"
		}
		template: {
			metadata: labels: {
				deploy: "sourcegraph"
				app:    "searcher"
			}
			spec: {
				containers: [{
					env: [{
						name:  "SEARCHER_CACHE_SIZE_MB"
						value: "100000"
					}, {
						name: "POD_NAME"
						valueFrom: fieldRef: fieldPath: "metadata.name"
					}, {
						name:  "CACHE_DIR"
						value: "/mnt/cache/$(POD_NAME)"
					}]
					image:                    "index.docker.io/sourcegraph/searcher:3.16.0@sha256:7dc22bb28e2681d4d0a0f3f3116e62bcde305c6b554db6dce4087fbfc99c5276"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "searcher"
					ports: [{
						containerPort: 3181
						name:          "http"
					}, {
						containerPort: 6060
						name:          "debug"
					}]
					readinessProbe: {
						failureThreshold: 1
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						periodSeconds: 1
					}
					resources: {
						limits: {
							cpu:    *"2" | string | int
							memory: *"2G" | string | int
						}
						requests: {
							cpu:    *"500m" | string | int
							memory: *"500M" | string | int
						}
					}
					volumeMounts: [{
						mountPath: "/mnt/cache"
						name:      "cache-ssd"
					}]
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
				volumes: [{
					emptyDir: {}
					name: "cache-ssd"
				}]
			}
		}
	}
}
