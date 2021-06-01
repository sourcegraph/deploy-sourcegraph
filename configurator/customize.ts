import { transformDeployments, Cluster } from './common'

export const transformations: ((c: Cluster) => void)[] = [    
    transformDeployments(d => d.metadata?.name === 'sourcegraph-frontend', d => {
        d.metadata!.name += '-foobar'
    })
]
