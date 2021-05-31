import * as k8s from "@kubernetes/client-node";
import { fstat, readdirSync, readFile, readFileSync } from "fs";
import * as fs from "fs";
import * as YAML from 'yaml';
import * as path from "path";
import { PersistentVolume } from "@pulumi/kubernetes/core/v1";
import * as mkdirp from 'mkdirp' // TODO: START HERE

(function() {
    const sourceDir = '../base'
    const outDir = 'rendered'
    
    interface Cluster {
        Deployments: [string, k8s.V1Deployment][]
        PersistentVolumeClaims: [string, k8s.V1PersistentVolumeClaim][]
        PersistentVolumes: [string, k8s.V1PersistentVolume][]
        Services: [string, k8s.V1Service][]
        ClusterRoles: [string, k8s.V1ClusterRole][]
        ClusterRoleBindings: [string, k8s.V1ClusterRoleBinding][]
        ConfigMaps: [string, k8s.V1ConfigMap][]
        DaemonSets: [string, k8s.V1DaemonSet][]
        Ingresss: [string, k8s.V1Ingress][]
        PodSecurityPolicys: [string, k8s.V1beta1PodSecurityPolicy][],
        Roles: [string, k8s.V1Role][]
        RoleBindings: [string, k8s.V1RoleBinding][]
        ServiceAccounts: [string, k8s.V1ServiceAccount][]
        StatefulSets: [string, k8s.V1StatefulSet][]
        Unrecognized: string[]
    }
    
    const cluster: Cluster = {
        Deployments: [],
        PersistentVolumeClaims: [],
        PersistentVolumes: [],
        Services: [],
        ClusterRoles: [],
        ClusterRoleBindings: [],
        ConfigMaps: [],
        DaemonSets: [],
        Ingresss: [],
        PodSecurityPolicys: [],
        Roles: [],
        RoleBindings: [],
        ServiceAccounts: [],
        StatefulSets: [],
        Unrecognized: [],
    }
    
    function readCluster(root: string) {
        const contents = readdirSync(root, {withFileTypes: true})
        for (const entry of contents) {
            if (entry.isFile()) {
                if (entry.name.endsWith('.yaml')) {
                    const k8sType = path.extname(entry.name.substring(0, entry.name.length - '.yaml'.length))
                    switch (k8sType) {
                        case '.Deployment':
                            cluster.Deployments.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.PersistentVolumeClaim':
                            cluster.PersistentVolumeClaims.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.PersistentVolume':
                            cluster.PersistentVolumes.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.Service':
                        case '.IndexerService':
                            cluster.Services.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.ClusterRole':
                            cluster.ClusterRoles.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.ClusterRoleBinding':
                            cluster.ClusterRoleBindings.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.ConfigMap':
                            cluster.ConfigMaps.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.DaemonSet':
                            cluster.DaemonSets.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.Ingress':
                            cluster.Ingresss.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.PodSecurityPolicy':
                            cluster.PodSecurityPolicys.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.Role':
                            cluster.Roles.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.RoleBinding':
                            cluster.RoleBindings.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.ServiceAccount':
                            cluster.ServiceAccounts.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        case '.StatefulSet':
                            cluster.StatefulSets.push([path.join(root, entry.name), YAML.parse(readFileSync(path.join(root, entry.name)).toString())])
                            break
                        default:
                            cluster.Unrecognized.push(entry.name)
                    }
                }
            } else if (entry.isDirectory()) {
                readCluster(path.join(root, entry.name))
            } else {
                console.error("Ignoring unrecognized file type, name: ", entry.name)
            }
        }    
    }
    
    readCluster(sourceDir)

    // Returns a thing that transforms all deployments that match a particular criteria
    const transformDeployments = (selector: (d: k8s.V1Deployment) => boolean, transform: (d: k8s.V1Deployment) => void): ((c: Cluster) => void) => {
        return ((c: Cluster) => {
            c.Deployments.filter(([, d]) => selector(d)).forEach(([, d]) => transform(d))
        })
    }
    
    const transformations: ((c: Cluster) => void)[] = [    
        transformDeployments(d => d.metadata?.name === 'sourcegraph-frontend', d => {
            d.metadata!.name += '-foobar'
        })
    ]
    
    transformations.forEach(t => t(cluster))
    

    function writeCluster(c: Cluster) {
        const fileContents = []
        fileContents.push(
            ...c.Deployments,
            ...c.PersistentVolumeClaims,
            ...c.PersistentVolumes,
            ...c.Services,
            ...c.ClusterRoles,
            ...c.ClusterRoleBindings,
            ...c.ConfigMaps,
            ...c.DaemonSets,
            ...c.Ingresss,
            ...c.PodSecurityPolicys,
            ...c.Roles,
            ...c.RoleBindings,
            ...c.ServiceAccounts,
            ...c.StatefulSets,    
        )
        fileContents.forEach(c => {

            fs.writeFileSync(path.join(outDir, c[0] + '.yaml'), YAML.stringify(c))
        })
    }

    writeCluster(cluster)
    
})()
