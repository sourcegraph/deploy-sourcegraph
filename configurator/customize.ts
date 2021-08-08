import * as k8s from "@kubernetes/client-node";
import { Transform, setResources, Cluster, platform, ingress, sshCloning, setReplicas, setNodeSelector, setAffinity, setRedis, setPostgres, nonRoot } from './common'

export const transformations: Transform[] = [
    // [ ] Specify the cloud provider that hosts the Kubernetes cluster and make any modifications to
    //     the storage class used for persistent storage
    platform('gcp', (sc: k8s.V1StorageClass) => {
        // Make modifications to the storage class here
    }),

    // [ ] Select an ingress mechanism
    //
    // (a) Use a Nginx Ingress controller (https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
    //     to expose Sourcegraph to end-user traffic. This is the recommended method of ingress.
    //
    ingress({
        ingressType: 'NginxIngressController',
        tls: {
            certFile: '[REPLACE]path/to/certificate.crt',
            keyFile: '[REPLACE]path/to/key.key',
            hostname: '[REPLACE]sourcegraph.example.com',
        },
    }),
    //
    // (b) Use a Nginx NodePort Service (https://kubernetes.io/docs/concepts/services-networking/service/#nodeport)
    //     to expose Sourcegraph to end-user traffic.
    //
    // ingress({
    //     ingressType: 'NginxNodePortService',
    //     tls: {
    //         certFile: '',
    //         keyFile: '',
    //     },
    // }),
    //
    // (c) Make the sourcegraph-frontend Service a NodePort Service.
    //     Using this ingress method, you will have to expose the designated port on the
    //     nodes to end-user traffic in your cloud provider configuration.
    //
    // ingress({ ingressType: 'NodePort'}),


    // setRedis('my-redis:6379', 'my-redis:6379'),
    // setPostgres({
    //     PGHOST: 'mypghost',
    // }),


    // ==============================================================================================
    // The above instructions should be good enough to cover most Sourcegraph instances
    // but some organizations have special needs. See below for examples of how to further customize
    // the Kubernetes cluster manifest


    // setResources(['zoekt-webserver'], { limits: { cpu: '1' } }),
    // setReplicas(['gitserver'], 3),
    // setNodeSelector(['gitserver'], { disktype: 'ssd' }),
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


    // sshCloning('~/.ssh/id_rsa', '~/.ssh/known_hosts')

    // nonRoot(),

    // transformDeployments(d => d.metadata?.name === 'sourcegraph-frontend', d => {
    //     d.metadata!.name += '-foobar2'
    // })

]
