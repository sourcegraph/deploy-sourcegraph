import * as k8s from "@kubernetes/client-node";
import { fstat, readdirSync, readFile, readFileSync } from "fs";
import * as fs from "fs";
import * as YAML from 'yaml';
import * as path from "path";
import { PersistentVolume } from "@pulumi/kubernetes/core/v1";

(function() {
    const sourceDir = '../base'
    const outDir = 'rendered'
    
    interface Cluster {
        Deployments: k8s.V1Deployment[]
        PersistentVolumeClaims: k8s.V1PersistentVolumeClaim[]
        PersistentVolumes: k8s.V1PersistentVolume[]
        Services: k8s.V1Service[]
        ClusterRoles: k8s.V1ClusterRole[]
        ClusterRoleBindings: k8s.V1ClusterRoleBinding[]
        ConfigMaps: k8s.V1ConfigMap[]
        DaemonSets: k8s.V1DaemonSet[]
        Ingresss: k8s.V1Ingress[]
        PodSecurityPolicys: k8s.V1beta1PodSecurityPolicy[],
        Roles: k8s.V1Role[]
        RoleBindings: k8s.V1RoleBinding[]
        ServiceAccounts: k8s.V1ServiceAccount[]
        StatefulSets: k8s.V1StatefulSet[]
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
                    console.log(k8sType)
                    switch (k8sType) {
                        case '.Deployment':
                            cluster.Deployments.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.PersistentVolumeClaim':
                            cluster.PersistentVolumeClaims.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.PersistentVolume':
                            cluster.PersistentVolumes.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.Service':
                        case '.IndexerService':
                            cluster.Services.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.ClusterRole':
                            cluster.ClusterRoles.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.ClusterRoleBinding':
                            cluster.ClusterRoleBindings.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.ConfigMap':
                            cluster.ConfigMaps.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.DaemonSet':
                            cluster.DaemonSets.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.Ingress':
                            cluster.Ingresss.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.PodSecurityPolicy':
                            cluster.PodSecurityPolicys.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.Role':
                            cluster.Roles.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.RoleBinding':
                            cluster.RoleBindings.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.ServiceAccount':
                            cluster.ServiceAccounts.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
                            break
                        case '.StatefulSet':
                            cluster.StatefulSets.push(YAML.parse(readFileSync(path.join(root, entry.name)).toString()))
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

    const transformDeployments = (selector: (d: k8s.V1Deployment) => boolean, transform: (d: k8s.V1Deployment) => void): ((c: Cluster) => void) => {
        return ((c: Cluster) => {
            c.Deployments.filter(d => selector(d)).forEach(d => transform(d))
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
            if (!c.metadata?.name) {
                console.error('missing name from', c)
                return
            }
            fs.writeFileSync(path.join(outDir, c.metadata.name + '.yaml'), c)
        })
    }
    
})()
