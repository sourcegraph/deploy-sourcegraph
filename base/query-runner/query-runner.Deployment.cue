package base

deployment: "query-runner": {
	metadata: {
		annotations: description: "Saved search query runner / notification service."
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
			spec: containers: [{
				env:                      null
				image:                    "index.docker.io/sourcegraph/query-runner:3.12.6@sha256:727a669220b7d6a7069a1874b573846608dff1c082a01d0fa8fcd21cf6fdff01"
				terminationMessagePolicy: "FallbackToLogsOnError"
				ports: [{
					containerPort: 3183
					name:          "http"
				}]
				resources: {
					limits: {
						cpu:    "1"
						memory: "1G"
					}
					requests: {
						cpu:    "500m"
						memory: "1G"
					}
				}
			}]
		}
	}
}
