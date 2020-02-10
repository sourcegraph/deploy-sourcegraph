package base

deployment: grafana: {
	metadata: {
		annotations: description: "Metrics/monitoring dashboards and alerts."
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "grafana"
		strategy: {
			rollingUpdate: {
				maxSurge:       1
				maxUnavailable: 1
			}
			type: "RollingUpdate"
		}
		template: {
			spec: {
				containers: [{
					image:                    "index.docker.io/sourcegraph/grafana:10.0.10@sha256:a6f9816346c3e38478f4b855eeee199fc91a4f69311f5dd57760bf74c3234715"
					terminationMessagePolicy: "FallbackToLogsOnError"
					ports: [{
						containerPort: 3370
						name:          "http"
					}]
					volumeMounts: [{
						mountPath: "/var/lib/grafana"
						name:      "data"
					}, {
						mountPath: "/sg_config_grafana/provisioning/datasources"
						name:      "config"
					}]
					resources: {
						limits: {
							cpu:    "100m"
							memory: "100Mi"
						}
						requests: {
							cpu:    "100m"
							memory: "100Mi"
						}
					}
				}]
				serviceAccountName: "grafana"
				securityContext: fsGroup: 472
				volumes: [{
					name: "data"
					persistentVolumeClaim: claimName: "grafana"
				}, {
					configMap: {
						defaultMode: 0o777
						name:        "grafana"
					}
					name: "config"
				}]
			}
		}
	}
}
