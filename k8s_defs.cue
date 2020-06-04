package kube

import (
	"k8s.io/api/core/v1"
	apps_v1 "k8s.io/api/apps/v1"
	networking_v1beta1 "k8s.io/api/networking/v1beta1"
	rbac_v1 "k8s.io/api/rbac/v1"
)

service: [string]:               v1.#Service
deployment: [string]:            apps_v1.#Deployment
daemonSet: [string]:             apps_v1.#DaemonSet
statefulSet: [string]:           apps_v1.#StatefulSet
configMap: [string]:             v1.#ConfigMap
persistentVolume: [string]:      v1.#PersistentVolume
persistentVolumeClaim: [string]: v1.#PersistentVolumeClaim
serviceAccount: [string]:        v1.#ServiceAccount
ingress: [string]:               networking_v1beta1.#Ingress
role: [string]:                  rbac_v1.#Role
roleBinding: [string]:           rbac_v1.#RoleBinding
