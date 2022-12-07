import * as k8s from "@kubernetes/client-node";
import * as _ from "lodash";
import { readFileSync } from "fs";
import * as YAML from "yaml";
import * as path from "path";
import * as request from "request";
import { flatten } from "lodash";
import { V1ConfigMap, V1Deployment, V1Ingress, V1ObjectMeta, V1PersistentVolumeClaim, V1Service, V1StatefulSet } from "@kubernetes/client-node";

export interface MustConfig {
  sourceDirectory: string
  additionalManifestDirectories?: string[]
  outputDirectory: string
  transformations: Transform[]
  filenameMapper: (sourceDir: string, filename: string) => string
}

export type Config = Partial<MustConfig> & Pick<MustConfig, 'transformations'>

export const clusterObjectKeys =  [
  'Deployments',
  'PersistentVolumeClaims',
  'PersistentVolumes',
  'Services',
  'ClusterRoles',
  'ClusterRoleBindings',
  'ConfigMaps',
  'DaemonSets',
  'Ingresss',
  'PodSecurityPolicys',
  'Roles',
  'RoleBindings',
  'ServiceAccounts',
  'Secrets',
  'StatefulSets',
'StorageClasses',
] as const

export interface Cluster {
  Deployments: [string, k8s.V1Deployment][];
  PersistentVolumeClaims: [string, k8s.V1PersistentVolumeClaim][];
  PersistentVolumes: [string, k8s.V1PersistentVolume][];
  Services: [string, k8s.V1Service][];
  ClusterRoles: [string, k8s.V1ClusterRole][];
  ClusterRoleBindings: [string, k8s.V1ClusterRoleBinding][];
  ConfigMaps: [string, k8s.V1ConfigMap][];
  DaemonSets: [string, k8s.V1DaemonSet][];
  Ingresss: [string, k8s.V1Ingress][];
  PodSecurityPolicys: [string, k8s.V1beta1PodSecurityPolicy][];
  Roles: [string, k8s.V1Role][];
  RoleBindings: [string, k8s.V1RoleBinding][];
  ServiceAccounts: [string, k8s.V1ServiceAccount][];
  Secrets: [string, k8s.V1Secret][];
  StatefulSets: [string, k8s.V1StatefulSet][];
  StorageClasses: [string, k8s.V1StorageClass][];

  RawFiles: [string, string][];
  Unrecognized: string[];
  ManualInstructions: string[];
}

export type Transform = (c: Cluster, config?: MustConfig) => Promise<void>;

export const removeComponent = (name: string, kind: string): Transform => async (c: Cluster) => {
  if (name === '*') {
    removeAllComponentsOfKind(kind, c)
    return
  }
  c.Deployments = c.Deployments.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.PersistentVolumeClaims = c.PersistentVolumeClaims.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.PersistentVolumes = c.PersistentVolumes.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.Services = c.Services.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.ClusterRoles = c.ClusterRoles.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.ClusterRoleBindings = c.ClusterRoleBindings.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.ConfigMaps = c.ConfigMaps.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.DaemonSets = c.DaemonSets.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.Ingresss = c.Ingresss.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.PodSecurityPolicys = c.PodSecurityPolicys.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.Roles = c.Roles.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.RoleBindings = c.RoleBindings.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.ServiceAccounts = c.ServiceAccounts.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.Secrets = c.Secrets.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.StatefulSets = c.StatefulSets.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
  c.StorageClasses = c.StorageClasses.filter(([,obj]) => obj.metadata?.name !== name || obj.kind !== kind)
}

const removeAllComponentsOfKind = (kind: string, c: Cluster): void => {
  c.Deployments = c.Deployments.filter(([,obj]) => obj.kind !== kind)
  c.PersistentVolumeClaims = c.PersistentVolumeClaims.filter(([,obj]) => obj.kind !== kind)
  c.PersistentVolumes = c.PersistentVolumes.filter(([,obj]) => obj.kind !== kind)
  c.Services = c.Services.filter(([,obj]) => obj.kind !== kind)
  c.ClusterRoles = c.ClusterRoles.filter(([,obj]) => obj.kind !== kind)
  c.ClusterRoleBindings = c.ClusterRoleBindings.filter(([,obj]) => obj.kind !== kind)
  c.ConfigMaps = c.ConfigMaps.filter(([,obj]) => obj.kind !== kind)
  c.DaemonSets = c.DaemonSets.filter(([,obj]) => obj.kind !== kind)
  c.Ingresss = c.Ingresss.filter(([,obj]) => obj.kind !== kind)
  c.PodSecurityPolicys = c.PodSecurityPolicys.filter(([,obj]) => obj.kind !== kind)
  c.Roles = c.Roles.filter(([,obj]) => obj.kind !== kind)
  c.RoleBindings = c.RoleBindings.filter(([,obj]) => obj.kind !== kind)
  c.ServiceAccounts = c.ServiceAccounts.filter(([,obj]) => obj.kind !== kind)
  c.Secrets = c.Secrets.filter(([,obj]) => obj.kind !== kind)
  c.StatefulSets = c.StatefulSets.filter(([,obj]) => obj.kind !== kind)
  c.StorageClasses = c.StorageClasses.filter(([,obj]) => obj.kind !== kind)
}

export const platform =
  (
    base: "gcp" | "aws" | "azure" | "minikube" | "generic",
    customizeStorageClass?: (sc: k8s.V1StorageClass) => void
  ): Transform =>
  (c: Cluster) => {
    const obj = YAML.parse(
      readFileSync(path.join("custom", `${base}.StorageClass.yaml`)).toString()
    );
    if (customizeStorageClass) {
      customizeStorageClass(obj);
    }
    c.StorageClasses.push(["sourcegraph.StorageClass.yaml", obj]);

    if (base === "minikube") {
      const removeResources = (
        deployOrSS: k8s.V1Deployment | k8s.V1StatefulSet
      ) => {
        deployOrSS.spec?.template.spec?.containers.forEach(
          (container) => delete container["resources"]
        );
      };
      c.Deployments.forEach(([, deployment]) => removeResources(deployment));
      c.StatefulSets.forEach(([, ss]) => removeResources(ss));
    }

    return Promise.resolve();
  };

export const ingress = (
  params:
    | {
        ingressType: "NginxIngressController";
        tls?: {
          certFile: string;
          keyFile: string;
          hostname: string;
        };
      }
    | {
        ingressType: "NginxNodePortService";
        tls: {
          certFile: string;
          keyFile: string;
        };
      }
    | {
        ingressType: "NodePort";
      }
): Transform => {
  switch (params.ingressType) {
    case "NginxIngressController":
      return ingressNginx(params.tls);
    case "NginxNodePortService":
      return serviceNginx(params.tls.certFile, params.tls.keyFile);
    case "NodePort":
      return nodePort();
    default:
        throw new Error('Unrecognized ingress type: ' + (params as any).ingressType)
  }
};

const ingressNginx =
  (tls?: { certFile: string; keyFile: string; hostname: string }): Transform =>
  async (c: Cluster) => {
    const body = await new Promise<any>((resolve) =>
      request(
        "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/cloud/deploy.yaml",
        (err, res, body) => {
          resolve(body);
        }
      )
    );

    // Add `deploy: sourcegraph` label
    const docs = YAML.parseAllDocuments(body);
    for (const doc of docs) {
      doc.setIn(["metadata", "labels", "deploy"], "sourcegraph");
    }

    if (tls) {
      c.Ingresss.forEach(([filepath, data]) => {
        data.spec!.tls = [
          {
            hosts: [tls.hostname],
            secretName: "sourcegraph-tls",
          },
        ];
        data.spec!.rules = [
          {
            http: {
              paths: [
                {
                  path: "/",
                  backend: {
                    service: {
                      name: "sourcegraph-frontend",
                      port: {
                        number: 300080,
                      },
                    },
                  },
                },
              ],
            },
            host: tls.hostname,
          },
        ];
      });

      const cert = readFileSync(tls.certFile).toString("base64");
      const key = readFileSync(tls.keyFile).toString("base64");
      c.Secrets.push([
        "sourcegraph-tls.Secret.yaml",
        {
          apiVersion: "v1",
          kind: "Secret",
          metadata: { name: "sourcegraph-tls" },
          type: "kubernetes.io/tls",
          data: {
            "tls.crt": cert,
            "tls.key": key,
          },
        },
      ]);

      c.ManualInstructions.push(
        `Update your [site configuration](https://docs.sourcegraph.com/admin/config/site_config) to set \`externalURL\` to ${tls.hostname}`
      );
    }

    c.RawFiles.push([
      "ingress-nginx.yaml",
      docs.map((doc) => doc.toString()).join("\n"),
    ]);
  };

const serviceNginx =
  (tlsCertFile: string, tlsKeyFile: string): Transform =>
  async (c: Cluster) => {
    const s = readFileSync(
      path.join("custom", "nginx-svc", "nginx.ConfigMap.yaml")
    ).toString();
    const y = YAML.parse(s) as k8s.V1ConfigMap;
    const tlsCert = readFileSync(tlsCertFile).toString();
    const tlsKey = readFileSync(tlsKeyFile).toString();
    y.data!["tls.crt"] = tlsCert;
    y.data!["tls.key"] = tlsKey;
    c.ConfigMaps.push(["nginx.ConfigMap.yaml", y]);
    c.Deployments.push([
      "nginx.Deployment.yaml",
      YAML.parse(
        readFileSync(
          path.join("custom", "nginx-svc", "nginx.Deployment.yaml")
        ).toString()
      ),
    ]);
    c.Services.push([
      "nginx.Service.yaml",
      YAML.parse(
        readFileSync(
          path.join("custom", "nginx-svc", "nginx.Service.yaml")
        ).toString()
      ),
    ]);
  };

const nodePort = (): Transform => async (c: Cluster) => {
  c.Services.forEach(([filename, service]) => {
    if (filename.endsWith("sourcegraph-frontend.Service.yaml")) {
      service.spec!.type = "NodePort";
      service.spec!.ports?.forEach((port) => {
        if (port.name === "http") {
          port.nodePort = port.port;
        }
      });
    }
  });
  c.ManualInstructions
    .push(`You've configured sourcegraph-frontend to be a NodePort service. This requires exposing a port on your cluster machines to the Internet.

If you are updating an existing service, you may need to delete the old service first:

  kubectl delete svc sourcegraph-frontend
  kubectl apply --prune -l deploy=sourcegraph -f .

Google Cloud Platform
=====================

  # Expose the necessary ports.
  gcloud compute --project=$PROJECT firewall-rules create sourcegraph-frontend-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:30080

  # Find a node name
  kubectl get pods -l app=sourcegraph-frontend -o=custom-columns=NODE:.spec.nodeName

  # Get the EXTERNAL-IP address (will be ephemeral unless you
  # [make it static](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#promote_ephemeral_ip)
  kubectl get node $NODE -o wide

AWS
===

Update the [AWS Security Group rules](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) for the nodes in your cluster to expose the NodePort port.

Afterward, Sourcegraph should be accessible at $EXTERNAL_ADDR:30080, where $EXTERNAL_ADDR is the address of any node in the cluster.

Other cloud providers
=====================

Follow your cloud provider documentation to expose the NodePort port on the cluster VMs to the Internet.
`);
};

export const sshCloning =
  (
    sshKeyFile: string,
    knownHostsFile: string,
    root: boolean = true
  ): Transform =>
  async (c: Cluster) => {
    const sshKey = readFileSync(sshKeyFile).toString("base64");
    const knownHosts = readFileSync(knownHostsFile).toString("base64");
    const sshDir = root ? "/root" : "/home/sourcegraph";
    c.Secrets.push([
      "gitserver-ssh.Secret.yaml",
      {
        apiVersion: "v1",
        kind: "Secret",
        metadata: { name: "gitserver-ssh" },
        type: "Opaque",
        data: {
          id_rsa: sshKey,
          known_hosts: knownHosts,
        },
      },
    ]);
    c.StatefulSets.filter(([filename]) =>
      filename.endsWith("gitserver.StatefulSet.yaml")
    ).forEach(([, data]) => {
      data.spec!.template.spec!.containers.forEach((container) => {
        if (container.name === "gitserver") {
          if (!container.volumeMounts) {
            container.volumeMounts = [];
          }
          container.volumeMounts.push({
            mountPath: `${sshDir}/.ssh`,
            name: "ssh",
          });
        }
      });
      if (!data.spec!.template.spec!.volumes) {
        data.spec!.template.spec!.volumes = [];
      }
      !data.spec!.template.spec!.volumes!.push({
        name: "ssh",
        secret: { defaultMode: 0o644, secretName: "gitserver-ssh" },
      });
    });
  };

export const redis =
  (redisCacheEndpoint: string, redisStoreEndpoint: string): Transform =>
  (c: Cluster) => {
    c.Deployments.filter(([, deployment]) =>
      _.includes(
        ["sourcegraph-frontend", "repo-updater"],
        deployment.metadata?.name
      )
    ).forEach(([, deployment]) => {
      deployment.spec?.template.spec?.containers
        .filter((container) =>
          _.includes(["frontend", "repo-updater"], container.name)
        )
        .forEach((container) => {
          if (!container.env) {
            container.env = [];
          }
          updateEnvironment(container.env, {
            REDIS_CACHE_ENDPOINT: redisCacheEndpoint,
            REDIS_STORE_ENDPOINT: redisStoreEndpoint,
          });
        });
    });
    removeComponentRegexp(/^redis\-/, c)
    return Promise.resolve();
  };

export const postgres =
  (postgresEndpoint: {
    PGPORT?: string;
    PGHOST?: string;
    PGUSER?: string;
    PGPASSWORD?: string;
    PGDATABASE?: string;
    PGSSLMODE?: string;
  }): Transform =>
  (c: Cluster) => {
    c.Deployments.filter(([, deployment]) =>
      _.includes(
        ["sourcegraph-frontend", "repo-updater"],
        deployment.metadata?.name
      )
    ).forEach(([, deployment]) => {
      deployment.spec?.template.spec?.containers
        .filter((container) =>
          _.includes(["frontend", "repo-updater"], container.name)
        )
        .forEach((container) => {
          if (!container.env) {
            container.env = [];
          }
          updateEnvironment(container.env, postgresEndpoint);
        });
    });
    removeComponentRegexp(/^pgsql/, c)
    return Promise.resolve();
  };

interface NameAndKindOptions {
  omit: [string, string][]
}

export const setNamespace = (name: string, kind: string, namespace: string, options?: NameAndKindOptions) => setMetadata(name, kind, {namespace}, options)

export const setMetadata = (name: string, kind: string, toMerge: DeepPartial<V1ObjectMeta>, options?: NameAndKindOptions ): Transform => async (c: Cluster) => {
  flatten<[string, { metadata?: V1ObjectMeta, kind?: string }]>([
    c.Deployments,
    c.PersistentVolumeClaims,
    c.PersistentVolumes,
    c.Services,
    c.ClusterRoles,
    c.ClusterRoleBindings,
    c.ConfigMaps,
    c.DaemonSets,
    c.Ingresss,
    c.PodSecurityPolicys,
    c.Roles,
    c.RoleBindings,
    c.ServiceAccounts,
    c.Secrets,
    c.StatefulSets,
    c.StorageClasses
  ]).map(([, obj]) => obj)
    .filter(obj => (name === '*' || obj.metadata?.name === name) && (kind === '*' || obj.kind === kind))
    .filter(obj => !(options?.omit && _.some(options.omit.map(([omitName, omitKind]) => obj.metadata?.name === omitName && obj.kind === omitKind))))
    .forEach(obj=> {
    _.merge(obj.metadata, toMerge)

    // If we're updating a namespace, also update namespace references
    if (toMerge.namespace) {
      _.concat(
        c.ClusterRoleBindings,
        c.RoleBindings,
      ).forEach(([,roleBinding]) => {
      roleBinding.subjects?.
        filter(subject => (name === '*' || subject.name === name) && (kind === '*' || subject.kind === kind)).
        forEach(subject => _.merge(subject, {namespace: toMerge.namespace}))
      })
    }
  })
}

type DeepPartial<T> = T extends object ? {
  [P in keyof T]?: DeepPartial<T[P]>;
} : T;


function mergeArrayCustomizer<T>(objValue: T, srcValue: T): any | undefined {
  if (!_.isArray(objValue) || !_.isArray(srcValue)) {
    return
  }
  const elemKey = (elem: any) => elem.name || elem.metadata?.name
  if (!_.every(objValue.map(elemKey)) || !_.every(srcValue.map(elemKey))) {
    return
  }
  const mergedElemsObj = _.mergeWith(
    _.fromPairs(objValue.map(elem => [elemKey(elem), elem])),
    _.fromPairs(srcValue.map(elem => [elemKey(elem), elem])),
    mergeArrayCustomizer,
  )
  return _.toPairs(mergedElemsObj).map(([,elem]) => elem)
}

export const overlay = (
  name: string,
  kind: {
    ingress?: DeepPartial<V1Ingress>,
    deployment?: DeepPartial<V1Deployment>,
    configMap?: DeepPartial<V1ConfigMap>,
    statefulSet?: DeepPartial<V1StatefulSet>,
    persistentVolumeClaim?: DeepPartial<V1PersistentVolumeClaim>,
    service?: DeepPartial<V1Service>,
  },
  unsetPaths?: {
    ingress?: string[],
    deployment?: string[],
    configMap?: string[],
    statefulSet?: string[],
    persistentVolumeClaim?: string[],
    service?: string[],
  },
): Transform => async (c: Cluster) => {    
  const mergeObjs = <T extends { metadata?: { name?: string }}>(namedObjs: [string, T][], toMerge?: DeepPartial<T>, toUnset?: string[]) => {
    if (!toMerge && !unsetPaths) {
      return
    }
    for (const [, obj] of namedObjs) {
      if (obj.metadata?.name !== name) {
        continue
      }
      _.mergeWith(obj, toMerge, mergeArrayCustomizer)
      if (toUnset) {
        for (const unsetPath of toUnset) {
          _.unset(obj, unsetPath)
        }
      }
    }
  }
  mergeObjs(c.Ingresss, kind.ingress, unsetPaths?.ingress)
  mergeObjs(c.Deployments, kind.deployment, unsetPaths?.deployment)
  mergeObjs(c.ConfigMaps, kind.configMap, unsetPaths?.configMap)
  mergeObjs(c.StatefulSets, kind.statefulSet, unsetPaths?.statefulSet)
  mergeObjs(c.PersistentVolumeClaims, kind.persistentVolumeClaim, unsetPaths?.persistentVolumeClaim)
  mergeObjs(c.Services, kind.service, unsetPaths?.service)
}

export const normalize = (): Transform => async (c: Cluster) => {
  _.concat(
    c.Deployments || [],
    c.StatefulSets || [],
    ).forEach(([, deploymentOrStatefulSet]) => {
      _.concat(
        deploymentOrStatefulSet.spec?.template.spec?.containers || [],
        deploymentOrStatefulSet.spec?.template.spec?.initContainers || [],
        ).forEach(c => {
          if (c.env === null) {
            delete c.env
          }
        })
      })
}
  
export function defaultFilenameMapper(sourceDir: string, filename: string): string {
  return path.relative(sourceDir, filename)
}

export function kustomizeFilenameMapper(sourceDir: string, filename: string): string {
  const rel = path.relative(sourceDir, filename);

  const yaml = YAML.parse(readFileSync(filename).toString())
  const dirParts = path.dirname(rel).split(path.sep)
  const baseParts = path.basename(filename).split('.')
  if (baseParts.length < 3) {
    console.log('ERROR: could not transform filename', filename)
    return filename
  }
  let [name, kind, ext] = baseParts
  let prefix = 'apps_v1'

  {
    // Adjustments
    if (dirParts.length > 0) {
      const dirName = dirParts[dirParts.length-1]
      if ([name, 'otel-collector', 'frontend', 'redis', 'jaeger', '.'].indexOf(dirName) === -1 && name.indexOf(`${dirName}-`) !== 0) {
        name = dirName + '-' + name
      }
    }
    const mappings: { [key: string]: string } = {
      'codeinsights-db': 'codeinsights-db-conf', // TODO: only apply this on the configmap change...
      'codeintel-db': 'codeintel-db-conf',
      'pgsql': 'pgsql-conf',
    }
    if (kind.toLowerCase() === 'configmap' && mappings[name]) {
      name = mappings[name]
    }
  }
  
  if (typeof yaml.apiVersion === 'string' || yaml.apiVersion instanceof String) {
    prefix = (yaml.apiVersion as string).replace('/', '_')
  }
  
  if (kind === 'IndexerService' && name === 'indexed-search') {
    return 'v1_service_indexed-search-indexer.yaml'
  }
  
  return prefix + '_' + kind.toLowerCase() + '_' + name.toLowerCase() + '.' + ext
}

const updateEnvironment = (
  curenv: Array<k8s.V1EnvVar>,
  newenv: { [name: string]: string | undefined }
) => {
  for (const key of _.keys(newenv)) {
    if (!newenv[key]) {
      continue;
    }
    let foundExisting = false;
    for (const curEnvVar of curenv) {
      if (curEnvVar.name === key) {
        curEnvVar.value = newenv[key];
        foundExisting = true;
        break;
      }
    }
    if (!foundExisting) {
      curenv.push({
        name: key,
        value: newenv[key],
      });
    }
  }
};

const removeComponentRegexp = (pattern: RegExp, c: Cluster) => {
  c.Deployments = c.Deployments.filter(([, e]) => (!e.metadata?.name) || !pattern.test(e.metadata.name))
  c.PersistentVolumeClaims = c.PersistentVolumeClaims.filter(([, e]) => (!e.metadata?.name) || !pattern.test(e.metadata.name))
  c.PersistentVolumeClaims = c.PersistentVolumeClaims.filter(([, e]) => (!e.metadata?.name) || !pattern.test(e.metadata.name))
  c.PersistentVolumes = c.PersistentVolumes.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.Services = c.Services.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.ClusterRoles = c.ClusterRoles.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.ClusterRoleBindings = c.ClusterRoleBindings.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.ConfigMaps = c.ConfigMaps.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.DaemonSets = c.DaemonSets.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.Ingresss = c.Ingresss.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.PodSecurityPolicys = c.PodSecurityPolicys.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.Roles = c.Roles.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.RoleBindings = c.RoleBindings.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.ServiceAccounts = c.ServiceAccounts.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.Secrets = c.Secrets.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.StatefulSets = c.StatefulSets.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
  c.StorageClasses = c.StorageClasses.filter(([, e]) => (!e.metadata?.name || !pattern.test(e.metadata.name)))
}

export function newCluster(): Cluster {
  return {
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
    Secrets: [],
    ServiceAccounts: [],
    StatefulSets: [],
    StorageClasses: [],
    RawFiles: [],
    Unrecognized: [],
    ManualInstructions: [],
  };
}

export function addToCluster(config: MustConfig, cluster: Cluster, filename: string) {
  const baseName = path.basename(filename)
  const k8sType = path.extname(baseName.substring(0, baseName.length - ".yaml".length));
  switch (k8sType) {
    case ".Deployment":
    cluster.Deployments.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".PersistentVolumeClaim":
    cluster.PersistentVolumeClaims.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".PersistentVolume":
    cluster.PersistentVolumes.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".Service":
    case ".IndexerService":
    cluster.Services.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".ClusterRole":
    cluster.ClusterRoles.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".ClusterRoleBinding":
    cluster.ClusterRoleBindings.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".ConfigMap":
    cluster.ConfigMaps.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".DaemonSet":
    cluster.DaemonSets.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".Ingress":
    cluster.Ingresss.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".PodSecurityPolicy":
    cluster.PodSecurityPolicys.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".Role":
    cluster.Roles.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".RoleBinding":
    cluster.RoleBindings.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".ServiceAccount":
    cluster.ServiceAccounts.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    case ".StatefulSet":
    cluster.StatefulSets.push([
      config.filenameMapper(config.sourceDirectory, filename),
      YAML.parse(readFileSync(filename).toString()),
    ]);
    break;
    default:
    cluster.Unrecognized.push(path.basename(filename));
  }
}
