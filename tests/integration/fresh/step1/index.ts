import * as os from 'os'
import * as path from 'path'

import * as k8s from '@pulumi/kubernetes'
import * as fs from 'fs-extra'

import { k8sProvider, clusterName, kubeconfig } from './cluster'
import { deploySourcegraphRoot, gcpUsername } from './config'


async function linkYAML(): Promise<string> {
    const localYAMLPath = path.join('.', 'kubernetes')

    await fs.symlink(deploySourcegraphRoot, localYAMLPath)

    return localYAMLPath
}

async function main() {
    const deploySourcegraphYAML = await linkYAML()
    console.log(deploySourcegraphYAML)
    fs.readdirSync(deploySourcegraphYAML).forEach(file => {
        console.log(file);
     });

    const clusterAdmin = new k8s.rbac.v1.ClusterRoleBinding(
        'cluster-admin-role-binding',
        {
            metadata: { name: `${os.userInfo().username}-cluster-admin-role-binding` },

            roleRef: {
                apiGroup: 'rbac.authorization.k8s.io',
                kind: 'ClusterRole',
                name: 'cluster-admin',
            },

            subjects: [
                {
                    apiGroup: 'rbac.authorization.k8s.io',
                    kind: 'User',
                    name: gcpUsername,
                },
            ],
        },
        { provider: k8sProvider }
    )

    const storageClass = new k8s.storage.v1.StorageClass(
        'sourcegraph-storage-class',
        {
            metadata: {
                name: 'sourcegraph',

                labels: {
                    deploy: 'sourcegraph',
                },
            },
            provisioner: 'kubernetes.io/gce-pd',

            parameters: {
                type: 'pd-ssd',
            },
        },
        { provider: k8sProvider }
    )

    const baseDeployment = new k8s.yaml.ConfigGroup(
        'base',
        {
            files: `${path.posix.join(deploySourcegraphYAML, 'base')}/**/*.yaml`,
        },
        {
            providers: { kubernetes: k8sProvider },
            dependsOn: [clusterAdmin, storageClass],
        }
    )

    const ingressNginx = new k8s.yaml.ConfigGroup(
        'ingress-nginx',
        {
            files: `${path.posix.join(deploySourcegraphYAML, 'configure', 'ingress-nginx')}/**/*.yaml`,
        },
        { providers: { kubernetes: k8sProvider }, dependsOn: clusterAdmin }
    )

    const ingressIP = ingressNginx
        .getResource('v1/Service', 'ingress-nginx', 'ingress-nginx')
        .apply(svc => svc.status)
        .apply(status => status.loadBalancer.ingress.map(i => i.ip))
        .apply(ips => (ips.length === 1 ? ips[0] : undefined))

    return {
        ingressIP,
        clusterName,
        kubeconfig,
    }
}
