package base

statefulSet: gitserver: {
	metadata: {
		annotations: description: "Stores clones of repositories to perform Git operations."
	}
	spec: {
		template: {
			spec: {
				containers: [{
					image:                    "index.docker.io/sourcegraph/gitserver:3.12.6@sha256:18b0a11395b442a27f34252e095aec9644156a499a64d2591ae275e98945998e"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						initialDelaySeconds: 5
						tcpSocket: port: "rpc"
						timeoutSeconds: 5
					}
					ports: [{
						containerPort: 3178
						name:          "rpc"
					}]
					resources: {
						limits: {
							cpu:    "4"
							memory: "8G"
						}
						requests: {
							cpu:    "4"
							memory: "8G"
						}
					}
					volumeMounts: [{
						mountPath: "/data/repos"
						name:      "repos"
					}]
				}]
				securityContext: fsGroup: 100
				// See the customization guide (../../../docs/configure.md) for information
				// about configuring gitserver to use an SSH key
				// - mountPath: /root/.ssh
				//   name: ssh
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
		updateStrategy: type: "RollingUpdate"
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
