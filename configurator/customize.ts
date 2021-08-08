import * as k8s from "@kubernetes/client-node";
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
} from "./common";

export const transformations: Transform[] = [
  //// [ ] Specify the cloud provider that hosts the Kubernetes cluster and make any modifications to
  //// the storage class used for persistent storage
  platform("gcp", (sc: k8s.V1StorageClass) => {
    // Make modifications to the storage class here
  }),

  //// [ ] Select an ingress mechanism
  ////
  //// (a) Use a Nginx Ingress controller (https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
  //// to expose Sourcegraph to end-user traffic. This is the recommended method of ingress.
  //
  // ingress({
  //     ingressType: 'NginxIngressController',
  //     tls: {
  //         certFile: '[[REPLACE]]path/to/certificate.crt',
  //         keyFile: '[[REPLACE]]path/to/key.key',
  //         hostname: '[[REPLACE]]sourcegraph.example.com',
  //     },
  // }),
  //
  //// (b) Use a Nginx NodePort Service (https://kubernetes.io/docs/concepts/services-networking/service/#nodeport)
  //// to expose Sourcegraph to end-user traffic.
  //
  // ingress({
  //     ingressType: 'NginxNodePortService',
  //     tls: {
  //         certFile: '',
  //         keyFile: '',
  //     },
  // }),
  //
  //// (c) Make the sourcegraph-frontend Service a NodePort Service.
  //// Using this ingress method, you will have to expose the designated port on the
  //// nodes to end-user traffic in your cloud provider configuration.
  //
  // ingress({ ingressType: 'NodePort'}),

  // ==============================================================================================
  // Optional customizations below
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
];
