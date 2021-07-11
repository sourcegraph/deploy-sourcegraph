import * as k8s from "@kubernetes/client-node";
import * as _ from 'lodash'
import { fstat, readdirSync, readFile, readFileSync } from "fs";
import * as fs from "fs";
import * as YAML from 'yaml';
import * as path from "path";
import { PersistentVolume } from "@pulumi/kubernetes/core/v1";
import * as mkdirp from 'mkdirp'
import * as request from 'request'
import { reject } from "lodash";
import { resolve } from "dns";

export interface Cluster {
    Deployments: [string, k8s.V1Deployment][]
    PersistentVolumeClaims: [string, k8s.V1PersistentVolumeClaim][]
    PersistentVolumes: [string, k8s.V1PersistentVolume][]
    Services: [string, k8s.V1Service][]
    ClusterRoles: [string, k8s.V1ClusterRole][]
    ClusterRoleBindings: [string, k8s.V1ClusterRoleBinding][]
    ConfigMaps: [string, k8s.V1ConfigMap][]
    DaemonSets: [string, k8s.V1DaemonSet][]
    Ingresss: [string, k8s.V1Ingress][]
    PodSecurityPolicys: [string, k8s.V1beta1PodSecurityPolicy][]
    Roles: [string, k8s.V1Role][]
    RoleBindings: [string, k8s.V1RoleBinding][]
    ServiceAccounts: [string, k8s.V1ServiceAccount][]
    StatefulSets: [string, k8s.V1StatefulSet][]
    StorageClasses: [string, k8s.V1StorageClass][]
    RawFiles: [string, string][]
    Unrecognized: string[]
}

export type Transform = (c: Cluster) => Promise<void>

// Returns a thing that transforms all deployments that match a particular criteria
export const transformDeployments = (selector: (d: k8s.V1Deployment) => boolean, transform: (d: k8s.V1Deployment) => void): Transform => {
    return ((c: Cluster) => {
        c.Deployments.filter(([, d]) => selector(d)).forEach(([, d]) => transform(d))
        return Promise.resolve()
    })
}

export const setResources = (containerNames: string[], resources: k8s.V1ResourceRequirements): Transform => (c: Cluster) => {
    const updateContainer = (c: k8s.V1Container) => {
        c.resources || (c.resources = {})
        _.merge(c.resources, resources)
    }
    const containers = [
        ..._.flatten(c.Deployments.map(([, d]) => d.spec?.template.spec?.containers)),
        ..._.flatten(c.StatefulSets.map(([, d]) => d.spec?.template.spec?.containers))
    ]
    containers
        .filter((c?: k8s.V1Container) => c && _.includes(containerNames, c.name))
        .forEach(c => c && updateContainer(c))
    return Promise.resolve()
}

export const storageClass = (base: 'gcp' | 'aws' | 'azure' | 'generic', customizeStorageClass?: (sc: k8s.V1StorageClass) => void): Transform => (c: Cluster) => {
    const obj = YAML.parse(readFileSync(path.join('custom', `${base}.StorageClass.yaml`)).toString())
    if (customizeStorageClass) {
        customizeStorageClass(obj)
    }
    c.StorageClasses.push(['sourcegraph.StorageClass.yaml', obj])
    return Promise.resolve()
}

export const ingressNginx = (): Transform => async (c: Cluster) => {
    const body = await new Promise<any>(resolve => request('https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/cloud/deploy.yaml', (err, res, body) => {
        resolve(body)
    }))

    // Add `deploy: sourcegraph` label
    const docs = YAML.parseAllDocuments(body)
    for (const doc of docs) {
        doc.setIn(['metadata', 'labels', 'deploy'], 'sourcegraph')
    }

    c.RawFiles.push(['ingress-nginx.yaml', docs.map(doc => doc.toString()).join('\n')])
}

export const serviceNginx = (tlsCertFile: string, tlsKeyFile: string): Transform => async (c: Cluster) => {
    const s = readFileSync(path.join('custom', 'nginx-svc', 'nginx.ConfigMap.yaml')).toString()
    const y = YAML.parse(s) as k8s.V1ConfigMap
    const tlsCert = readFileSync(tlsCertFile).toString()
    const tlsKey = readFileSync(tlsKeyFile).toString()
    y.data!['tls.crt'] =  tlsCert
    y.data!['tls.key'] = tlsKey
    c.ConfigMaps.push(['nginx.ConfigMap.yaml', y])
    c.Deployments.push([
        'nginx.Deployment.yaml',
        YAML.parse(readFileSync(path.join('custom', 'nginx-svc', 'nginx.Deployment.yaml')).toString())
    ])
    c.Services.push([
        'nginx.Service.yaml',
        YAML.parse(readFileSync(path.join('custom', 'nginx-svc', 'nginx.Service.yaml')).toString())
    ])
}
