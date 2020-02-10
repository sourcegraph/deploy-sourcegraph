package base

service: backend: {
	metadata: {
		annotations: description: "Dummy service that prevents backend pods from being scheduled on the same node if possible."

		labels: {
			group: "backend"
		}
	}
	spec: {
		clusterIP: "None"
		ports: [{
			name:       "unused"
			port:       10811
			targetPort: 10811
		}]
	}
}
