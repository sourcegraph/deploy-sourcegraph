import * as os from 'os'
import * as path from 'path'

import * as k8s from '@pulumi/kubernetes'

import { k8sProvider } from './cluster'
import { deploySourcegraphRoot, gcpUsername } from './config'
import * as fs from "fs";

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

const getAllButKustomizeYAMLFiles = dir =>
    fs.readdirSync(dir).reduce((files, file) => {
        if (file == 'kustomization.yaml') {
            return files;
        }
        const ext = file.substr(file.lastIndexOf('.') + 1);
        const name = path.join(dir, file);
        const isDirectory = fs.statSync(name).isDirectory();
        if (!isDirectory && ext != 'yaml') {
            return files;
        }
        return isDirectory ? [...files, ...getAllButKustomizeYAMLFiles(name)] : [...files, name];
    }, []);

const baseDeployment = new k8s.yaml.ConfigGroup(
    'base',
    {
        files: getAllButKustomizeYAMLFiles(path.posix.join(deploySourcegraphRoot, 'base')),
    },
    {
        providers: { kubernetes: k8sProvider },
        dependsOn: [clusterAdmin, storageClass],
    }
)

const ingressNginx = new k8s.yaml.ConfigGroup(
    'ingress-nginx',
    {
        files: `${path.posix.join(deploySourcegraphRoot, 'configure', 'ingress-nginx')}/**/*.yaml`,
    },
    { providers: { kubernetes: k8sProvider }, dependsOn: clusterAdmin }
)

export const ingressIP = ingressNginx
    .getResource('v1/Service', 'ingress-nginx', 'ingress-nginx')
    .apply(svc => svc.status)
    .apply(status => status.loadBalancer.ingress.map(i => i.ip))
    .apply(ips => (ips.length === 1 ? ips[0] : undefined))

export * from './cluster'
