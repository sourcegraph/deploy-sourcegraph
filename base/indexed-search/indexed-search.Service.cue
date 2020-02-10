package base

service: "indexed-search": {
	metadata: {
		annotations: {
			description: "Headless service that provides a stable network identity for the indexed-search stateful set."
		}
	}
	spec: {
		clusterIP: "None"
		ports: [{
			port: 6070
		}]
	}
}
