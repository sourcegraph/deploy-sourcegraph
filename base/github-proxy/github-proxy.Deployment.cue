package base

deployment: "github-proxy": {
	metadata: {
		annotations: description: "Rate-limiting proxy for the GitHub API."
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
			spec: containers: [{
				env:                      null
				image:                    "index.docker.io/sourcegraph/github-proxy:3.12.6@sha256:ad8e41de62add8d9877fed409c29640a943cce5165a2ba81207f787ad5c21af8"
				terminationMessagePolicy: "FallbackToLogsOnError"
				ports: [{
					containerPort: 3180
					name:          "http"
				}]
				resources: {
					limits: {
						cpu:    "1"
						memory: "1G"
					}
					requests: {
						cpu:    "100m"
						memory: "250M"
					}
				}
			}]
		}
	}
}
