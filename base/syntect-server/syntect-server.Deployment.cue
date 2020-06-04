package kube

deployment: "syntect-server": {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		annotations: description:                "Backend for syntax highlighting operations."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "syntect-server"
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "syntect-server"
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
				app:    "syntect-server"
			}
			spec: {
				containers: [{
					env: []
					image:                    "index.docker.io/sourcegraph/syntax-highlighter:3.16.0@sha256:aa93514b7bc3aaf7a4e9c92e5ff52ee5052db6fb101255a69f054e5b8cdb46ff"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						httpGet: {
							path:   "/health"
							port:   "http"
							scheme: "HTTP"
						}
						initialDelaySeconds: 5
						timeoutSeconds:      5
					}
					name: "syntect-server"
					ports: [{
						containerPort: 9238
						name:          "http"
					}]
					readinessProbe: tcpSocket: port: "http"
					resources: {
						limits: {
							cpu:    *"4" | string | int
							memory: *"6G" | string | int
						}
						requests: {
							cpu:    *"250m" | string | int
							memory: *"2G" | string | int
						}
					}
				}]
				securityContext: runAsUser: 0
			}
		}
	}
}
