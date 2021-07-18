import * as k8s from "@kubernetes/client-node";
import { Transform, nodePort, setResources, Cluster, storageClass, ingressNginx, serviceNginx, sshCloning, setReplicas } from './common'

export const transformations: Transform[] = [
    // transformDeployments(d => d.metadata?.name === 'sourcegraph-frontend', d => {
    //     d.metadata!.name += '-foobar2'
    // })

    setResources(['zoekt-webserver'], { limits: { cpu: '1' } }),
    setReplicas(['gitserver'], 3),

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
    // - NodeSelector (resource-hungry pods to larger nodes)
    // - Aux directory to add other k8s objects to manifest
    // - Custom Redis
    // - Custom Postgres
    // - Install cluster-wide, without RBAC
    // - Add license key
    // - Overlays
    //   - Minikube
    //   - Non-privileged
    //   - Namespaced
    //   - Non-root


]
