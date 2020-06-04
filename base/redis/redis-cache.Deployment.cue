package kube

deployment: "redis-cache": {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		annotations: description:                "Redis for storing short-lived caches."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "redis-cache"
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "redis-cache"
		strategy: type: "Recreate"
		template: {
			metadata: labels: {
				deploy: "sourcegraph"
				app:    "redis-cache"
			}
			spec: {
				containers: [{
					env: []
					image:                    "index.docker.io/sourcegraph/redis-cache:3.16.0@sha256:7820219195ab3e8fdae5875cd690fed1b2a01fd1063bd94210c0e9d529c38e56"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						initialDelaySeconds: 30
						tcpSocket: port: "redis"
					}
					name: "redis-cache"
					ports: [{
						containerPort: 6379
						name:          "redis"
					}]
					readinessProbe: {
						initialDelaySeconds: 5
						tcpSocket: port: "redis"
					}
					resources: {
						limits: {
							cpu:    *"1" | string | int
							memory: *"6Gi" | string | int
						}
						requests: {
							cpu:    *"1" | string | int
							memory: *"6Gi" | string | int
						}
					}
					volumeMounts: [{
						mountPath: "/redis-data"
						name:      "redis-data"
					}]
				}, {
					image:                    "index.docker.io/sourcegraph/redis_exporter:18-02-07_bb60087_v0.15.0@sha256:282d59b2692cca68da128a4e28d368ced3d17945cd1d273d3ee7ba719d77b753"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "redis-exporter"
					ports: [{
						containerPort: 9121
						name:          "redisexp"
					}]
					resources: {
						limits: {
							cpu:    *"10m" | string | int
							memory: *"100Mi" | string | int
						}
						requests: {
							cpu:    *"10m" | string | int
							memory: *"100Mi" | string | int
						}
					}
				}]
				securityContext: runAsUser: 0
				volumes: [{
					name: "redis-data"
					persistentVolumeClaim: claimName: "redis-cache"
				}]
			}
		}
	}
}
