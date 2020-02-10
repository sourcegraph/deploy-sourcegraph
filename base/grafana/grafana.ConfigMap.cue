package base

import yaml656e63 "encoding/yaml"

configMap: grafana: {
	data: {
		"prometheus.yml": yaml656e63.Marshal(_cue_prometheus_yml)
		_cue_prometheus_yml = {
			apiVersion: 1

			datasources: [{
				name:      "Prometheus"
				type:      "prometheus"
				access:    "proxy"
				url:       "http://prometheus:30090"
				isDefault: true
				editable:  false
			}]
		}
	}
}
