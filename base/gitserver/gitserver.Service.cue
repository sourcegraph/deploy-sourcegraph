package base

service: gitserver: {
	metadata: {
		annotations: {
			description: "Headless service that provides a stable network identity for the gitserver stateful set."
		}
		labels: {
			type: "gitserver"
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
