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
  //// [ ] Specify the cloud provider that hosts the Kubernetes cluster and make any modifications to
  //// the storage class used for persistent storage
  platform("gcp", (storageClass: k8s.V1StorageClass) => {
    // Make optional customizations to the storage class here
  }),

  //// [ ] Select an ingress mechanism
  ////
  //// (a) Make the sourcegraph-frontend Service a NodePort Service.
  //// Using this ingress method, you will have to expose the designated port on the
  //// nodes to end-user traffic in your cloud provider configuration.
  //// This is the easiest way to get up and running, but Sourcegraph will not have TLS enabled,
  //// this is recommended only for testing or proofs of concept.
  //
  ingress({ ingressType: 'NodePort'}),
  //
  //
  //// (b) Use a Nginx Ingress controller (https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
  //// to expose Sourcegraph to end-user traffic. This is the recommended method of ingress for production.
  //
  // ingress({
  //   ingressType: "NginxIngressController",
  //   tls: {
  //     certFile: "[[REPLACE]]path/to/certificate.crt",
  //     keyFile:  "[[REPLACE]]path/to/key.key",
  //     hostname: "[[REPLACE]]sourcegraph.example.com",
  //   },
  // }),
  //
  //
  //// (c) Use a Nginx NodePort Service (https://kubernetes.io/docs/concepts/services-networking/service/#nodeport)
  //// to expose Sourcegraph to end-user traffic.
  //
  // ingress({
  //     ingressType: 'NginxNodePortService',
  //     tls: {
  //         certFile: "[[REPLACE]]path/to/certificate.crt",
  //         keyFile:  "[[REPLACE]]path/to/key.key",
  //     },
  // }),

  // ==============================================================================================
  //
  //
  //
  //
  //
  //             Optional customizations below
  //
  //
  //
  //
  //
  // ==============================================================================================

  //// Use an external Redis (like Redis Enterprise Cloud or Amazon ElastiCache).
  //// This removes Redis from the manifest.
  //
  // redis('my-redis:6379', 'my-redis:6379'),

  //// Use an external Postgres (like Amazon RDS or Google Cloud SQL)
  //// The removes Postgres from the manifest.
  //
  // postgres({
  //     PGHOST: 'mypghost',
  //     PGPORT: '5432',
  //     PGUSER: 'postgres',
  //     PGPASSWORD: '',
  //     PGDATABASE: 'postgres',
  //     PGSSLMODE: 'disable',
  // }),

  //// Adjust the resource allocation for specific services
  //
  // setResources(['zoekt-webserver'], { limits: { cpu: '1' } }),

  //// Adjust the replica count for specific services
  //
  // setReplicas(['gitserver'], 3),

  //// Set a nodeSelector field (https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) for certain services
  //
  // setNodeSelector(['gitserver'], { disktype: 'ssd' }),

  //// Set affinity (https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)
  //// for certain services
  //
  // setAffinity(['gitserver'], {
  //     nodeAffinity: {
  //         requiredDuringSchedulingIgnoredDuringExecution: {
  //             nodeSelectorTerms: [
  //                 {
  //                     matchExpressions: [{ key: 'scheduler-profile', operator: 'In', values: ['foo']}]
  //                 }
  //             ]
  //         }
  //     }
  // }),

  //// Enable cloning via SSH (instead of HTTPS)
  //
  // sshCloning('~/.ssh/id_rsa', '~/.ssh/known_hosts')

  //// Run containers as non-root user
  //
  // nonRoot(),

  //// Add a suffix to the name of every Deployment.
  //
  // transformDeployments(d => d.metadata?.name === 'sourcegraph-frontend', d => {
  //     d.metadata!.name += '-my-suffix'
  // })

  //// Make arbitrary changes to the manifest.
  //// Note: this voids the warranty. Please contact Sourcegraph support if you find the need to 
  //// use this mechanism.
  //
  // unsafeArbitraryTransformations((c: Cluster) => {
  //   c.Services.forEach(([, s]) => {
  //     if (s.metadata) {
  //       s.metadata.name = s.metadata.name && s.metadata.name + '-suffix'
  //     }
  //   })
  // })

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