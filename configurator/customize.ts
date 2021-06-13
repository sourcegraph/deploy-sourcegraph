import { transformDeployments, setResources, Cluster, storageClass } from './common'

export const transformations: ((c: Cluster) => void)[] = [    
    // transformDeployments(d => d.metadata?.name === 'sourcegraph-frontend', d => {
    //     d.metadata!.name += '-foobar2'
    // })

    setResources(['zoekt-webserver'], { limits: { cpu: '1' }}),

    storageClass('gcp'),

    // TODO
    // - Network Ingress
    // - TLS
    // - Customize site configuration
    // - Repository cloning
    // - Replica count
    // - Storage class (GCP, AWS, Azure, other)
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
