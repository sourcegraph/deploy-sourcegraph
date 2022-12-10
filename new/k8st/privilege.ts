import * as k8s from "@kubernetes/client-node";
import * as _ from "lodash";
import { readFileSync } from "fs";
import * as YAML from "yaml";
import * as path from "path";
import * as request from "request";
import { flatten } from "lodash";
import { V1ConfigMap, V1Deployment, V1Ingress, V1ObjectMeta, V1PersistentVolumeClaim, V1Service, V1StatefulSet } from "@kubernetes/client-node";
import { Cluster, includeSupplemental, MustConfig, overlay, removeComponent, Transform } from "./common";

type NonRootAdjustments = {
    [name: string]: {
      runAsUser?: number;
      runAsGroup?: number;
      containers?: {
        [containerName: string]: NonRootContainerAdjustment
      },
      initContainers?: {
        [containerName: string]: NonRootContainerAdjustment
      },
    };
  };
  
  type NonRootContainerAdjustment = {
    runAsUser?: number;
    runAsGroup?: number;
    allowPrivilegeEscalation?: boolean;
  }
  
  export const nonRoot = (): Transform => async (c: Cluster, config?: MustConfig) => {
    const defaultContainerSecurityContext = {
        allowPrivilegeEscalation: false,
        runAsUser: 100,
        runAsGroup: 101,
    };
    const runAsUserAndGroup: NonRootAdjustments = {
      "codeinsights-db": {
        runAsUser: 70,
        initContainers: {
          'correct-data-dir-permissions': {
            runAsUser: 70,
            runAsGroup: 70,
          },
        },
        containers: {
          codeinsights: {
            runAsGroup: 70,
            runAsUser: 70,
          },
        },
      },
      "codeintel-db": {
        runAsUser: 999,
        initContainers: {
          'correct-data-dir-permissions': {
            runAsGroup: 999,
            runAsUser: 999,
          },
        },
        containers: {
          pgsql: {
            runAsGroup: 999,
            runAsUser: 999,
          }
        }
      },
      "sourcegraph-frontend": {},
      "github-proxy": {},
      "gitserver": {},
      grafana: {
        containers: {
          grafana: {
            runAsUser: 472,
            runAsGroup: 472,
          },
        },
      },
      "indexed-search": {},
      "minio": {},
      "otel-agent": {},
      "otel-collector": {}, // TODO: otel-collector DaemonSet
      pgsql: {
        initContainers: {
          'correct-data-dir-permissions': {
            runAsGroup: 999,
            runAsUser: 999,
          },
        },
        containers: {
          pgsql: {
            runAsGroup: 999,
            runAsUser: 999,
          }
        },
        runAsUser: 999,
      },
      prometheus: { // rolebinding and configmap
        containers: {
          prometheus: {
            runAsGroup: 100,
            runAsUser: 100,
          }
        }
      },
      "redis-cache": {
        runAsUser: 999,
        runAsGroup: 1000,
      },
      "redis-store": {
        runAsUser: 999,
        runAsGroup: 1000,
      },
      "repo-updater": {},
      "searcher": {},
      "symbols": {},
      "syntect-server": {},
      "worker": {},
    };
    const update = (object: k8s.V1Deployment | k8s.V1StatefulSet | k8s.V1DaemonSet) => {
      if (!object.metadata?.name) {
        return;
      }
      const adjustment = runAsUserAndGroup[object.metadata.name]
      if (!adjustment) {
        return
      }
      _.merge(object, {
        spec: {
          template: {
            spec: {
              securityContext: _.omitBy(_.omit(adjustment, 'containers', 'initContainers'), _.isUndefined),
            },
          },
        },
      })
      const adjustContainers = (containers?: k8s.V1Container[], containerAdjustments?: { [containerName: string]: NonRootContainerAdjustment}) => {
        if (!containers) {
          if (containerAdjustments) {
            console.error(`encountered container adjustments for non-existent containers: ${containerAdjustments}`)
          }
          return
        }
        for (const container of containers) {
          const containerSecurityContext = containerAdjustments && containerAdjustments[container.name]
          container.securityContext = _.merge({}, container.securityContext, defaultContainerSecurityContext, containerSecurityContext)
        }
      }
      adjustContainers(object.spec?.template.spec?.containers, adjustment.containers)
      adjustContainers(object.spec?.template.spec?.initContainers, adjustment.initContainers)
    };
    c.Deployments.forEach(([, d]) => update(d));
    c.StatefulSets.forEach(([, ss]) => update(ss));
    c.DaemonSets.forEach(([, ds]) => update(ds));
  
    c.ClusterRoleBindings = []
    c.ClusterRoles = []
    

    overlay('prometheus', { configMap: {
        data: {
            'prometheus.yml': getPrometheusYml(),
        },
    }})(c)

    removeComponent('*', 'RoleBinding')(c)
    removeComponent('*', 'Role')(c)
    removeComponent('cadvisor', 'ServiceAccount')(c)
    removeComponent('worker-executors', 'Service')(c) // TODO: why??

    includeSupplemental("./supplemental/prometheus/prometheus-nonprivileged.RoleBinding.yaml")(c, config)
    includeSupplemental("./supplemental/frontend/sourcegraph-frontend-nonprivileged.RoleBinding.yaml")(c, config)

    return Promise.resolve();
  };
  
  export const nonPrivileged = (): Transform => async (c: Cluster, config?: MustConfig) => {
    await nonRoot()(c, config); // implies non-root for now
    return Promise.resolve();
  };

  const getPrometheusYml = () => {
    return YAML.parse(`
prometheus.yml: |
    global:
      scrape_interval:     30s
      evaluation_interval: 30s

    alerting:
      alertmanagers:
        # Bundled Alertmanager, started by prom-wrapper
        - static_configs:
            - targets: ['127.0.0.1:9093']
          path_prefix: /alertmanager

    rule_files:
      - '*_rules.yml'
      - "/sg_config_prometheus/*_rules.yml"
      - "/sg_prometheus_add_ons/*_rules.yml"

    scrape_configs:
    - job_name: 'kubernetes-service-endpoints'

      kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names:
           - ns-sourcegraph

      relabel_configs:
      - source_labels: [__meta_kubernetes_service_annotation_sourcegraph_prometheus_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
        action: replace
        target_label: __scheme__
        regex: (https?)
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
        action: replace
        target_label: __address__
        regex: (.+)(?::\\d+);(\\d+)
        replacement: $1:$2
      - action: labelmap
        regex: __meta_kubernetes_service_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        # Sourcegraph specific customization. We want a more convenient to type label.
        # target_label: kubernetes_namespace
        target_label: ns
      - source_labels: [__meta_kubernetes_service_name]
        action: replace
        target_label: kubernetes_name
      # Sourcegraph specific customization. We want a nicer name for job
      - source_labels: [app]
        action: replace
        target_label: job
      # Sourcegraph specific customization. We want a nicer name for instance
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: instance
    `)['prometheus.yml']
  }
