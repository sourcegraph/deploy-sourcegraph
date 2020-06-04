package kube

objects: [ for v in #objectSets for x in v {x}]

#objectSets: [
	service,
	deployment,
	statefulSet,
	daemonSet,
	configMap,
	persistentVolume,
	persistentVolumeClaim,
	serviceAccount,
	ingress,
	role,
	roleBinding,
]
