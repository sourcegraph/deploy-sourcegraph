import * as k8s from "@kubernetes/client-node";
import { fstat, readdirSync, readFile, readFileSync } from "fs";
import * as fs from "fs";
import * as YAML from 'yaml';
import * as path from "path";
import { PersistentVolume } from "@pulumi/kubernetes/core/v1";
import * as mkdirp from 'mkdirp'
import { Cluster } from './common'
import { transformations } from './customize'

(async function() {
    const sourceDir = '../base'
    const outDir = 'rendered'
    
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
    
    transformations.forEach(t => t(cluster))
    
    async function writeCluster(c: Cluster) {
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
        await fileContents.forEach(async c => {
            const filename = path.relative(sourceDir, c[0])
            await mkdirp(path.dirname(path.join(outDir, filename)))
            fs.writeFileSync(path.join(outDir, filename), YAML.stringify(c[1]))
        })
    }

    await writeCluster(cluster)
})().then(() => {
    console.log("Done")
})
