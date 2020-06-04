package kube

import yaml656e63 "encoding/yaml"

configMap: grafana: {
	apiVersion: "v1"
	data: {
		"prometheus.yml": yaml656e63.Marshal(_cue_prometheus_yml)
		let _cue_prometheus_yml = {
			apiVersion: 1

			datasources: [{
				name:      "Prometheus"
				type:      "prometheus"
				access:    "proxy"
				url:       "http://prometheus:30090"
				isDefault: true
				editable:  false
			}]
		}
	}

	kind: "ConfigMap"
	metadata: {
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "grafana"
	}
}

service: grafana: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		labels: {
			app:                             "grafana"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "grafana"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       30070
			targetPort: "http"
		}]
		selector: app: "grafana"
		type: "ClusterIP"
	}
}

serviceAccount: grafana: {
	apiVersion: "v1"
	imagePullSecrets: [{
		name: "docker-registry"
	}]
	kind: "ServiceAccount"
	metadata: {
		labels: {
			category:                        "rbac"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "grafana"
	}
}

statefulSet: grafana: {
	apiVersion: "apps/v1"
	kind:       "StatefulSet"
	metadata: {
		annotations: description:                "Metrics/monitoring dashboards and alerts."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "grafana"
	}
	spec: {
		revisionHistoryLimit: 10
		selector: matchLabels: app: "grafana"
		serviceName: "grafana"
		updateStrategy: type: "RollingUpdate"
		template: {
			metadata: labels: {
				app:    "grafana"
				deploy: "sourcegraph"
			}
			spec: {
				containers: [{
					image:                    "index.docker.io/sourcegraph/grafana:3.16.0@sha256:771dd20ea85af7ba188022078f6937f035cab48f312929b8056831b0418b8cfe"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "grafana"
					ports: [{
						containerPort: 3370
						name:          "http"
					}]
					volumeMounts: [{
						mountPath: "/var/lib/grafana"
						name:      "grafana-data"
					}, {
						mountPath: "/sg_config_grafana/provisioning/datasources"
						name:      "config"
					}]
					// Grafana is relied upon to send alerts to site admins when something is wrong with
					// Sourcegraph, thus its memory requests and limits are the same to guarantee it has enough
					// memory to perform its job reliably and prevent conflicts with other pods on the same
					// host node.
					resources: {
						limits: {
							cpu:    *"1" | string | int
							memory: *"512Mi" | string | int
						}
						requests: {
							cpu:    *"100m" | string | int
							memory: *"512Mi" | string | int
						}
					}
				}]
				serviceAccountName: "grafana"
				securityContext: runAsUser: 0
				volumes: [{
					name: "config"
					configMap: {
						defaultMode: 0o777
						name:        "grafana"
					}
				}]
			}
		}
		volumeClaimTemplates: [{
			metadata: name: "grafana-data"
			spec: {
				accessModes: ["ReadWriteOnce"]
				resources: requests: storage: "2Gi"
				storageClassName: "sourcegraph"
			}
		}]
	}
}
