package kube

service: gitserver: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			description: "Headless service that provides a stable network identity for the gitserver stateful set."

			"prometheus.io/port":            "6060"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			"sourcegraph-resource-requires": "no-cluster-admin"
			type:                            "gitserver"
			app:                             "gitserver"
		}
		name: "gitserver"
	}
	spec: {
		clusterIP: "None"
		ports: [{
			name:       "unused"
			port:       10811
			targetPort: 10811
		}]
		selector: {
			type: "gitserver"
			app:  "gitserver"
		}
		type: "ClusterIP"
	}
}



statefulSet: gitserver: {
	apiVersion: "apps/v1"
	kind:       "StatefulSet"
	metadata: {
		annotations: description:                "Stores clones of repositories to perform Git operations."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "gitserver"
	}
	spec: {
		revisionHistoryLimit: 10
		selector: matchLabels: app: "gitserver"
		serviceName: "gitserver"
		template: {
			metadata: labels: {
				app:    "gitserver"
				group:  "backend"
				type:   "gitserver"
				deploy: "sourcegraph"
			}
			spec: {
				containers: [{
					args: [
						"run",
					]
					env: []
					image:                    "index.docker.io/sourcegraph/gitserver:3.16.0@sha256:31987e80f7137fe635add74f24d60872db8702d4fb07b5e00dcd4877ab9bcb21"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						initialDelaySeconds: 5
						tcpSocket: port: "rpc"
						timeoutSeconds: 5
					}
					name: "gitserver"
					ports: [{
						containerPort: 3178
						name:          "rpc"
					}]
					resources: {
						limits: {
							cpu:    *"4" | string | int
							memory: *"8G" | string | int
						}
						requests: {
							cpu:    *"4" | string | int
							memory: *"8G" | string | int
						}
					}
					volumeMounts: [{
						mountPath: "/data/repos"
						name:      "repos"
					}]
				}, {
					// See the customization guide (../../../docs/configure.md) for information
					// about configuring gitserver to use an SSH key
					// - mountPath: /root/.ssh
					//   name: ssh
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
					name: "repos"
				}]
			}
		}
		// See the customization guide (../../../docs/configure.md) for information
		// about configuring gitserver to use an SSH key
		// - name: ssh
		//   secret:
		//     defaultMode: 384
		//     secretName: gitserver-ssh
		updateStrategy: {
			type: "RollingUpdate"
		}
		volumeClaimTemplates: [{
			metadata: name: "repos"
			spec: {
				accessModes: [
					"ReadWriteOnce",
				]
				resources: requests: {
					// The size of disk used to mirror your git repositories.
					// If you change this, also change indexed-search's disk size.
					storage: "200Gi"
				}
				storageClassName: "sourcegraph"
			}
		}]
	}
}
