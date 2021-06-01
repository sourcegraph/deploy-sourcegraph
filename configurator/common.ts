import * as k8s from "@kubernetes/client-node";
import { fstat, readdirSync, readFile, readFileSync } from "fs";
import * as fs from "fs";
import * as YAML from 'yaml';
import * as path from "path";
import { PersistentVolume } from "@pulumi/kubernetes/core/v1";
import * as mkdirp from 'mkdirp'

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
    PodSecurityPolicys: [string, k8s.V1beta1PodSecurityPolicy][],
    Roles: [string, k8s.V1Role][]
    RoleBindings: [string, k8s.V1RoleBinding][]
    ServiceAccounts: [string, k8s.V1ServiceAccount][]
    StatefulSets: [string, k8s.V1StatefulSet][]
    Unrecognized: string[]
}

// Returns a thing that transforms all deployments that match a particular criteria
export const transformDeployments = (selector: (d: k8s.V1Deployment) => boolean, transform: (d: k8s.V1Deployment) => void): ((c: Cluster) => void) => {
    return ((c: Cluster) => {
        c.Deployments.filter(([, d]) => selector(d)).forEach(([, d]) => transform(d))
    })
}

