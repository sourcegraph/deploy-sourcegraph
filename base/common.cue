package kube

#default_replicas: {
	spec: {
		replicas: *1 | int
		...
	}
	...
}

#commonLabels: {
	metadata: {
		labels: {
			deploy:                          "sourcegraph"
			"sourcegraph-resource-requires": "no-cluster-admin" | "cluster-admin"
			...
		}
		...
	}
	...
}

#common_image: {
	spec: {
		template: {
			spec: {
				containers: [
					...{
						image: 
						...
					}
				]
				...
			}
			...
		}
		...
	}
	...
}

service: [string]:               #commonLabels
deployment: [string]:            #default_replicas & #commonLabels
daemonSet: [string]:             #default_replicas & #commonLabels
statefulSet: [string]:           #default_replicas & #commonLabels
configMap: [string]:             #commonLabels
persistentVolume: [string]:      #commonLabels
persistentVolumeClaim: [string]: #commonLabels
serviceAccount: [string]:        #commonLabels
ingress: [string]:               #commonLabels
role: [string]:                  #commonLabels
roleBinding: [string]:           #commonLabels
