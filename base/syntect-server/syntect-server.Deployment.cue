package base

deployment: "syntect-server": {
	metadata: {
		annotations: description: "Backend for syntax highlighting operations."
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
			spec: containers: [{
				env:                      null
				image:                    "index.docker.io/sourcegraph/syntect_server:2b5a3fb@sha256:ef5529cafdc68d5a21edea472ee8ad966878b173044aa5c3db93bc3d84765b1f"
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
				ports: [{
					containerPort: 9238
					name:          "http"
				}]
				readinessProbe: tcpSocket: port: "http"
				resources: {
					limits: {
						cpu:    "4"
						memory: "6G"
					}
					requests: {
						cpu:    "250m"
						memory: "2G"
					}
				}
			}]
		}
	}
}
