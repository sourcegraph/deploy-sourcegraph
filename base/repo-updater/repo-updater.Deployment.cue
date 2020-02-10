package base

deployment: "repo-updater": {
	metadata: {
		annotations: description: "Handles repository metadata (not Git data) lookups and updates from external code hosts and other similar services."
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
			spec: containers: [{
				image:                    "index.docker.io/sourcegraph/repo-updater:3.12.6@sha256:8ce2e60370a24c8301eb4ab04edf97737f7cf45fc0d8a8a8f3b02c22f382e719"
				env:                      null
				terminationMessagePolicy: "FallbackToLogsOnError"
				ports: [{
					containerPort: 3182
					name:          "http"
				}, {
					containerPort: 6060
					name:          "debug"
				}]
				resources: {
					limits: {
						cpu:    "100m"
						memory: "500Mi"
					}
					requests: {
						cpu:    "100m"
						memory: "500Mi"
					}
				}
			}]
		}
	}
}
