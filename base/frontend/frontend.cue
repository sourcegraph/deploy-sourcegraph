package kube

deployment: "sourcegraph-frontend": {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		annotations: description:                "Serves the frontend of Sourcegraph via HTTP(S)."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "sourcegraph-frontend"
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "sourcegraph-frontend"
		strategy: {
			rollingUpdate: {
				maxSurge:       2
				maxUnavailable: 0
			}
			type: "RollingUpdate"
		}
		template: {
			metadata: labels: {
				app:    "sourcegraph-frontend"
				deploy: "sourcegraph"
			}
			spec: {
				containers: [{
					args: [
						"serve",
					]
					env: [{
						name:  "PGDATABASE"
						value: "sg"
					}, {
						name:  "PGHOST"
						value: "pgsql"
					}, {
						name:  "PGPORT"
						value: "5432"
					}, {
						name:  "PGSSLMODE"
						value: "disable"
					}, {
						name:  "PGUSER"
						value: "sg"
					}, {
						name:  "SRC_GIT_SERVERS"
						value: "gitserver-0.gitserver:3178"
					}, {
						// POD_NAME is used by CACHE_DIR
						name: "POD_NAME"
						valueFrom: fieldRef: fieldPath: "metadata.name"
					}, {
						// CACHE_DIR stores larger items we cache. Majority of it is zip
						// archives of repositories at a commit.
						name:  "CACHE_DIR"
						value: "/mnt/cache/$(POD_NAME)"
					}, {
						name:  "GRAFANA_SERVER_URL"
						value: "http://grafana:30070"
					}, {
						name:  "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL"
						value: "http://precise-code-intel-bundle-manager:3187"
					}, {
						name:  "PROMETHEUS_URL"
						value: "http://prometheus:30090"
					}]
					image:                    "index.docker.io/sourcegraph/frontend:3.16.0@sha256:055560401f9c06f0d56fdad9b9233a99770c573a48bd84d27b16609ac1c9658d"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						initialDelaySeconds: 300
						timeoutSeconds:      5
					}
					readinessProbe: {
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						periodSeconds:  5
						timeoutSeconds: 5
					}
					name: "frontend"
					ports: [{
						containerPort: 3080
						name:          "http"
					}, {
						containerPort: 3090
						name:          "http-internal"
					}]
					resources: {
						limits: {
							cpu:    *"2" | string | int
							memory: *"4G" | string | int
						}
						requests: {
							cpu:    *"2" | string | int
							memory: *"2G" | string | int
						}
					}
					volumeMounts: [{
						mountPath: "/mnt/cache"
						name:      "cache-ssd"
					}]
				}, {
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
				serviceAccountName: "sourcegraph-frontend"
				volumes: [{
					emptyDir: {}
					name: "cache-ssd"
				}]
			}
		}
	}
}

ingress: "sourcegraph-frontend": {
	apiVersion: "networking.k8s.io/v1beta1"
	kind:       "Ingress"
	metadata: {
		annotations: {
			"kubernetes.io/ingress.class": "nginx"
			// We can upload large files (extensions)
			"nginx.ingress.kubernetes.io/proxy-body-size": "150m"
		}
		// See
		// https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
		// for more nginx annotations.
		labels: {
			app:                             "sourcegraph-frontend"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "sourcegraph-frontend"
	}
	spec: {
		// See the customization guide (../../../docs/configure.md) for information
		// about configuring TLS
		// tls:
		// - hosts:
		//   - sourcegraph.example.com
		//   secretName: sourcegraph-tls
		rules: [{
			http: paths: [{
				path: "/"
				backend: {
					serviceName: "sourcegraph-frontend"
					servicePort: 30080
				}
			}]
		}]
	}
}

role: "sourcegraph-frontend": {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: {
		labels: {
			category:                        "rbac"
			"sourcegraph-resource-requires": "cluster-admin"
		}
		name: "sourcegraph-frontend"
	}
	rules: [{
		apiGroups: [
			"",
		]
		resources:
		// necessary for resolving k8s+http://fooservice URLs (see for example searcher URL)
		[
			"endpoints",
			"services",
		]
		// necessary to populate Site Admin/Instrumentation page (/-/debug) in the cluster deployment
		verbs: [
			"get",
			"list",
			"watch",
		]
	}]
}

roleBinding: "sourcegraph-frontend": {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		labels: {
			category:                        "rbac"
			"sourcegraph-resource-requires": "cluster-admin"
		}
		name: "sourcegraph-frontend"
	}
	roleRef: {
		apiGroup: ""
		kind:     "Role"
		name:     "sourcegraph-frontend"
	}
	subjects: [{
		kind: "ServiceAccount"
		name: "sourcegraph-frontend"
	}]
}

service: "sourcegraph-frontend": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "6060"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "sourcegraph-frontend"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "sourcegraph-frontend"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       30080
			targetPort: "http"
		}]
		selector: app: "sourcegraph-frontend"
		type: "ClusterIP"
	}
}

serviceAccount: "sourcegraph-frontend": {
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
		name: "sourcegraph-frontend"
	}
}
