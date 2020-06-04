package kube

service: "indexed-search": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			description: "Headless service that provides a stable network identity for the indexed-search stateful set."

			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "indexed-search"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "indexed-search"
	}
	spec: {
		clusterIP: "None"
		ports: [{
			port: 6070
		}]
		selector: app: "indexed-search"
		type: "ClusterIP"
	}
}

statefulSet: "indexed-search": {
	apiVersion: "apps/v1"
	kind:       "StatefulSet"
	metadata: {
		annotations: description:                "Backend for indexed text search operations."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "indexed-search"
	}
	spec: {
		revisionHistoryLimit: 10
		selector: matchLabels: app: "indexed-search"
		serviceName: "indexed-search"
		template: {
			metadata: labels: {
				app:    "indexed-search"
				deploy: "sourcegraph"
			}
			spec: {
				containers: [{
					env: []
					image:                    "index.docker.io/sourcegraph/indexed-searcher:3.16.0@sha256:d8b0fa59f7825acc51ef3cfe9d625019555dceb3272d44b52e396cc7748eaa06"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "zoekt-webserver"
					ports: [{
						containerPort: 6070
						name:          "http"
					}]
					readinessProbe: {
						failureThreshold: 1
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						periodSeconds: 1
					}
					resources: {
						limits: {
							cpu:    *"2" | string | int
							memory: *"4G" | string | int
						}
						requests: {
							cpu:    *"500m" | string | int
							memory: *"2G" | string | int
						}
					}
					volumeMounts: [{
						mountPath: "/data"
						name:      "data"
					}]
				}, {
					env: []
					image:                    "index.docker.io/sourcegraph/search-indexer:3.16.0@sha256:fa1eaf045fbd2cab1cd2666046718e47d43012efbe07ad68beda0ac778f62875"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "zoekt-indexserver"
					ports: [{
						containerPort: 6072
						name:          "index-http"
					}]
					resources: {
						// zoekt-indexserver is CPU bound. The more CPU you allocate to it, the
						// lower lag between a new commit and it being indexed for search.
						limits: {
							cpu:    *"8" | string | int
							memory: *"8G" | string | int
						}
						requests: {
							cpu:    *"4" | string | int
							memory: *"4G" | string | int
						}
					}
					volumeMounts: [{
						mountPath: "/data"
						name:      "data"
					}]
				}]
				securityContext: runAsUser: 0
				volumes: [{
					name: "data"
				}]
			}
		}
		updateStrategy: type: "RollingUpdate"
		volumeClaimTemplates: [{
			metadata: {
				labels: deploy: "sourcegraph"
				name: "data"
			}
			spec: {
				accessModes: [
					"ReadWriteOnce",
				]
				resources: requests: {
					// The size of disk to used for search indexes.
					// This should typically be gitserver disk size multipled by the number of gitserver shards.
					storage: "200Gi"
				}
				storageClassName: "sourcegraph"
			}
		}]
	}
}
