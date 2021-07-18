import * as k8s from "@kubernetes/client-node";
import { Transform, nodePort, setResources, Cluster, storageClass, ingressNginx, serviceNginx, sshCloning, setReplicas, setNodeSelector, setAffinity, setRedis, setPostgres } from './common'

export const transformations: Transform[] = [
    // transformDeployments(d => d.metadata?.name === 'sourcegraph-frontend', d => {
    //     d.metadata!.name += '-foobar2'
    // })

    setResources(['zoekt-webserver'], { limits: { cpu: '1' } }),
    setReplicas(['gitserver'], 3),
    setNodeSelector(['gitserver'], { disktype: 'ssd' }),
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

    setRedis('my-redis:6379', 'my-redis:6379'),
    setPostgres({
        PGHOST: 'mypghost',
    }),


    storageClass('minikube', (sc: k8s.V1StorageClass) => {
        // possible customizations here
    }),

    // ingressNginx(
    //     {
    //         certFile: 'path/to/certificate.crt',
    //         keyFile: 'path/to/private/key.key',
    //         hostname: 'sourcegraph.example.com',
    //     }
    // ),
    // serviceNginx('path/to/certificate.crt', 'path/to/private/key.key'),
    // nodePort(),

    // sshCloning('~/.ssh/id_rsa', '~/.ssh/known_hosts')

    // TODO
    // - NetworkPolicy and NetworkPolicy with Namespaced Overlay Example
    // - [x] TLS
    // - [x] Repository cloning
    // - [x] Replica count
    // - [x] Storage class (GCP, AWS, Azure, other)
    // - [x] NodeSelector (resource-hungry pods to larger nodes)
    // - [x] Custom Redis
    // - [x] Custom Postgres
    // - Overlays
    //   - Minikube
    //   - Non-privileged
    //   - Namespaced
    //   - Non-root
    // - Add license key


]
