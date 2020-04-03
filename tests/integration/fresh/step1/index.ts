import * as os from 'os'
import * as path from 'path'

import * as fg from 'fast-glob'
import * as k8s from '@pulumi/kubernetes'

import { k8sProvider } from './cluster'
import { deploySourcegraphRoot, gcpUsername, generatedBase } from './config'

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

const globOptions = {
    ignore: ['**/kustomization.yaml'],
}

const baseFiles = fg(`${generatedBase}/**/*.yaml`, globOptions)

const baseDeployment = baseFiles.then(
    files =>
        new k8s.yaml.ConfigGroup(
            'base',
            {
                files,
            },
            {
                providers: { kubernetes: k8sProvider },
                dependsOn: [clusterAdmin, storageClass],
            }
        )
)

const ingressNginxFiles = fg(
    `${path.posix.join(deploySourcegraphRoot, 'configure', 'ingress-nginx')}/**/*.yaml`,
    globOptions
)

const ingressNginx = ingressNginxFiles.then(
    files =>
        new k8s.yaml.ConfigGroup(
            'ingress-nginx',
            {
                files,
            },
            { providers: { kubernetes: k8sProvider }, dependsOn: clusterAdmin }
        )
)

export const ingressIP = ingressNginx.then(ingress =>
    ingress
        .getResource('v1/Service', 'ingress-nginx', 'ingress-nginx')
        .apply(svc => svc.status)
        .apply(status => status.loadBalancer.ingress.map(i => i.ip))
        .apply(ips => (ips.length === 1 ? ips[0] : undefined))
)

export * from './cluster'
