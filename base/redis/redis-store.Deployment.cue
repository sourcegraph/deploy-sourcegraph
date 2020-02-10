package base

deployment: "redis-store": {
	metadata: {
		annotations: description: "Redis for storing semi-persistent data like user sessions."
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "redis-store"
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
					image:                    "index.docker.io/sourcegraph/redis-store:20-01-30_c903717e@sha256:e8467a8279832207559bdfbc4a89b68916ecd5b44ab5cf7620c995461c005168"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						initialDelaySeconds: 30
						tcpSocket: port: "redis"
					}
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
							cpu:    "1"
							memory: "6Gi"
						}
						requests: {
							cpu:    "1"
							memory: "6Gi"
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
							cpu:    "10m"
							memory: "100Mi"
						}
						requests: {
							cpu:    "10m"
							memory: "100Mi"
						}
					}
				}]
				securityContext: fsGroup: 100
				volumes: [{
					name: "redis-data"
					persistentVolumeClaim: claimName: "redis-store"
				}]
			}
		}
	}
}
