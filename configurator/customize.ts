import * as k8s from "@kubernetes/client-node";
import { Transform, setResources, Cluster, platform, ingress, sshCloning, setReplicas, setNodeSelector, setAffinity, setRedis, setPostgres, nonRoot } from './common'

export const transformations: Transform[] = [
    platform('gcp', (sc: k8s.V1StorageClass) => {
        // possible customizations here
    }),

    // Use a Nginx Ingress controller (https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
    // to expose Sourcegraph to end-user traffic. This is the recommended method of ingress.
    //
    ingress({
        ingressType: 'NginxIngressController',
        tls: {
            certFile: '[REPLACE]path/to/certificate.crt',
            keyFile: '[REPLACE]path/to/key.key',
            hostname: '[REPLACE]sourcegraph.example.com',
        },
    }),

    // Use a Nginx NodePort Service (https://kubernetes.io/docs/concepts/services-networking/service/#nodeport)
    // to expose Sourcegraph to end-user traffic.
    //
    // ingress({
    //     ingressType: 'NginxNodePortService',
    //     tls: {
    //         certFile: '',
    //         keyFile: '',
    //     },
    // }),

    // Make the sourcegraph-frontend Service a NodePort Service.
    // Using this ingress method, you will have to expose the designated port on the
    // nodes to end-user traffic in your cloud provider configuration.
    //
    // ingress({ ingressType: 'NodePort'}),




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

    // setRedis('my-redis:6379', 'my-redis:6379'),
    // setPostgres({
    //     PGHOST: 'mypghost',
    // }),


    // sshCloning('~/.ssh/id_rsa', '~/.ssh/known_hosts')

    // nonRoot(),

    // transformDeployments(d => d.metadata?.name === 'sourcegraph-frontend', d => {
    //     d.metadata!.name += '-foobar2'
    // })

]
