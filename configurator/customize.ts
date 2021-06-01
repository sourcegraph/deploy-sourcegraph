import { transformDeployments, setResources, Cluster } from './common'

export const transformations: ((c: Cluster) => void)[] = [    
    // transformDeployments(d => d.metadata?.name === 'sourcegraph-frontend', d => {
    //     d.metadata!.name += '-foobar2'
    // })

    setResources(['zoekt-webserver'], { limits: { cpu: '1' }})
]
