import * as k8s from "@kubernetes/client-node";
import { V1RoleRef } from "@kubernetes/client-node";
import { concat, merge, values } from "lodash";
import _ = require("lodash");
import {
  Transform,
  setResources,
  Cluster,
  platform,
  ingress,
  sshCloning,
  setReplicas,
  setNodeSelector,
  setAffinity,
  redis,
  postgres,
  nonRoot,
  unsafeArbitraryTransformations,
  deepPartial,
  setNamespace,
  setMetadata,
  setDeployment,
  setVolume,
  setEnvVars,
  setStatefulSet,
  setVolumeClaimTemplate,
  setMetadata2,
  setIngress,
  setDeployment2,
} from "./common";

export const transformations: Transform[] = [
  platform("gcp", (storageClass: k8s.V1StorageClass) => {
    // Make optional customizations to the storage class here
  }),
  ingress({ ingressType: 'NodePort'}),

  setNamespace(/.*/, 'sourcegraph'),

  setResources(['timescaledb'], {
    limits: { cpu: '4' },
    requests: { cpu: '1' },
  }),
  setVolume('codeinsights-db', 'timescaledb-conf', { configMap: { defaultMode: 0o777 } }),
  setVolume('codeintel-db', 'pgsql-conf', { configMap: { defaultMode: 511 }}),
  setVolume('pgsql', 'pgsql-conf', { configMap: { defaultMode: 511 }}),
  setVolume('prometheus', 'config', { configMap: { defaultMode: 511 }}),
  setReplicas(['searcher'], 1),
  setResources(['searcher'], { limits: { memory: '4G' }, requests: { memory: '1G' }}),
  setEnvVars('frontend', [ 
    {
      name: 'SRC_GIT_SERVERS',
      value: 'gitserver-0.gitserver:3178 gitserver-1.gitserver:3178',
    },
  ]),
  setResources(['symbols'], {
    limits: {
      cpu: '4',
      'ephemeral-storage': '10G',
      memory: '4G',
    },
    requests: {
      cpu: '1',
      memory: '1G',
    },
  }),
  setReplicas(['gitserver'], 2),
  setEnvVars('gitserver', [
    {
      name: 'SRC_ENABLE_GC_AUTO',
      value: 'false',
    },
  ]),
  setResources(['gitserver'], {
    limits: { cpu: '8' },
    requests: { memory: '4G' },
  }),
  setVolumeClaimTemplate('gitserver', 'repos', {
    spec: {
      storageClassName: 'sourcegraph-storage-class',
      resources: {
        requests: {
          storage: '1Ti'
        }
      }
    }
  }),

  setVolume('grafana', 'config', { configMap: { defaultMode: 511 } }),
  setVolumeClaimTemplate('grafana', 'grafana-data', {
    spec: {
      resources: {
        requests: {
          storage: '10Gi',
        }
      },
      storageClassName: 'sourcegraph-storage-class'
    }    
  }),

  setReplicas(['indexed-search'], 2),
  setResources(['zoekt-webserver'], {
    requests: { cpu: '1', memory: '16G' },
    limits: { memory: '16G' },
  }),
  setResources(['zoekt-indexserver'], {
    requests: { memory: '8G' },
    limits: { cpu: '4', memory: '16G' },
  }),
  setVolumeClaimTemplate('indexed-search', 'data', {
    spec: {
      storageClassName: 'sourcegraph-storage-class',
      resources: { requests: { storage: '100Gi' } },
    },
  }, v => {
    if (v.metadata) {
      delete v.metadata.labels
    }
  }),

  setMetadata2('sourcegraph-frontend', 'Ingress', {
    annotations: {
     'nginx.ingress.kubernetes.io/affinity': 'cookie',
     'nginx.ingress.kubernetes.io/affinity-mode': 'persistent',
    },
  }),

  setIngress('sourcegraph-frontend', {
    spec: {
      rules: [
        {
          host: 'sourcegraph.canaveral-beta.us-west-2.aws',
          http: {
            paths: [
              {
                pathType: 'ImplementationSpecific'
              }
            ]
          }
        },
      ],
      tls: [
        {
          hosts: ['sourcegraph.canaveral-beta.us-west-2.aws'],
          secretName: 'sourcegraph-tls',
        }
      ]
    }
  }),

  setMetadata2('codeinsights-db-conf', 'ConfigMap', {
    labels: {
      deploy: 'sourcegraph-db',
    }
  }),

  setDeployment2('codeinsights-db', {
    metadata: { labels: { deploy: 'sourcegraph-db' } },
    spec: { template: { metadata: { labels: { deploy: 'sourcegraph-db'} } } },
  }),
  setDeployment2('codeintel-db', {
    metadata: { labels: { deploy: 'sourcegraph-db' } },
    spec: { template: { metadata: { labels: { deploy: 'sourcegraph-db'} } } },
  }),
  setDeployment2('pgsql', {
    metadata: { labels: { deploy: 'sourcegraph-db' } },
    spec: { template: { metadata: { labels: { deploy: 'sourcegraph-db'} } } },
  }),
]