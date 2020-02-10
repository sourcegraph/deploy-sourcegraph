package base

ingress: "sourcegraph-frontend": {
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
