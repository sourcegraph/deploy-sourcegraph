package base

deployLabel:    "sourcegraph"
nameSpaceValue: "ns-sourcegraph"

service: [ID=_]: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name: ID
		labels: {
			app:    *ID | string
			deploy: deployLabel
		}
		namespace: nameSpaceValue
		annotations: {
			"prometheus.io/port":            *"6060" | string
			"sourcegraph.prometheus/scrape": "true"
		}
	}
	spec: {
		// Any port has the following properties.
		ports: [...{
			port:     int
			protocol: *"TCP" | "UDP" // from the Kubernetes definition
			name:     string | *"client"
		}]
		selector: metadata.labels // we want those to be the same
		type:     "ClusterIP"
	}
}

deployment: [ID=_]: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name: ID
		labels: deploy: deployLabel
		namespace: nameSpaceValue
	}
	spec: {
		// 1 is the default, but we allow any number
		replicas: *1 | int
		template: {
			metadata: labels: {
				app: *ID | string
			}
			// we always have one namesake container
			spec: containers: [{name: *ID | string}, ...]
		}
	}
}

statefulSet: [ID=_]: {
	apiVersion: "apps/v1"
	kind:       "StatefulSet"
	metadata: {
		name: ID
		labels: deploy: deployLabel
		namespace: nameSpaceValue
	}
	spec: {
		replicas:             *1 | int
		revisionHistoryLimit: 10
		selector: matchLabels: app: ID
		serviceName: ID
		template: {
			metadata: labels: {
				app:   ID
				group: "backend"
				type:  ID
			}
			spec: containers: [{name: *ID | string}, ...]
		}
	}
}

// TODO(uwedeportivo): tie service account name in deployment to declared service account

serviceAccount: [ID=_]: {
	apiVersion: "v1"
	imagePullSecrets: [{
		name: "docker-registry"
	}]
	kind: "ServiceAccount"
	metadata: {
		labels: {
			category: "rbac"
			deploy:   deployLabel
		}
		name:      ID
		namespace: nameSpaceValue
	}
}

persistentVolumeClaim: [ID=_]: {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {
		name: ID
		labels: deploy: deployLabel
		namespace: nameSpaceValue
	}
}

ingress: [ID=_]: {
	apiVersion: "extensions/v1beta1"
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
			app:    ID
			deploy: deployLabel
		}
		name:      ID
		namespace: nameSpaceValue
	}
}

roleBinding: [ID=_]: {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		labels: {
			category: "rbac"
			deploy:   deployLabel
		}
		name:      ID
		namespace: nameSpaceValue
	}
	roleRef: {
		apiGroup: ""
		kind:     "ClusterRole"
		name:     "view"
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      ID
		namespace: nameSpaceValue
	}]
}

configMap: [ID=_]: {
	apiVersion: "v1"

	kind: "ConfigMap"
	metadata: {
		name: ID
		labels: deploy: deployLabel
		namespace: nameSpaceValue
	}
}
