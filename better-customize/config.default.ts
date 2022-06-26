import * as k8s from "@kubernetes/client-node";
import {
  platform,
  ingress,
  Config,
  defaultFilenameMapper,
  overlay,
} from "./common";

export const configuration = async (): Promise<Config> => ({
  sourceDirectory: '../base',
  outputDirectory: '../rendered',
  filenameMapper: defaultFilenameMapper,
  transformations: [
    //// [ ] Required step 1/2: Specify the cloud provider that hosts the Kubernetes cluster and make any modifications to
    //// the storage class used for persistent storage
    platform("gcp", (storageClass: k8s.V1StorageClass) => {
      // Make optional customizations to the storage class here
    }),
    
    //// [ ] Required step 2/2: Select an ingress mechanism
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
    
    // ===============================================================================
    //
    //
    //             Optional customizations below
    //
    //
    // ===============================================================================
    
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

    //// Enable cloning via SSH (instead of HTTPS)
    //
    // sshCloning('~/.ssh/id_rsa', '~/.ssh/known_hosts')
    
    //// Run containers as non-root user
    //
    // nonRoot(),

    //// Update resource allocation, replica counts, etc. by applying overlays
    //// to cluster objects
    //
    // overlay('sourcegraph-frontend', {
    //   ingress: {
    //     metadata: {
    //       annotations: {
    //         'nginx.ingress.kubernetes.io/affinity': 'cookie',
    //         'nginx.ingress.kubernetes.io/affinity-mode': 'persistent',
    //       }
    //     },
    //   },
    //   deployment: {
    //     spec: {
    //       replicas: 10,
    //       template: {
    //         spec: {
    //           containers: [
    //             {
    //               name: 'frontend',
    //               resources: { requests: { cpu: '5', memory: '10G' }, limits: { cpu: '10', memory: '20G' }},
    //             }
    //           ]
    //         }
    //       }
    //     }
    //   }
    // }),

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
  ],
})