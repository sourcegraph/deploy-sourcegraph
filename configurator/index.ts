import * as k8s from "@kubernetes/client-node";
import { fstat, readdirSync, readFile, readFileSync } from "fs";
import * as fs from "fs";
import * as YAML from "yaml";
import * as path from "path";
import { PersistentVolume } from "@pulumi/kubernetes/core/v1";
import * as mkdirp from "mkdirp";
import { Cluster, deepPartial } from "./common";
import { transformations as userTransformations } from "./customize";
import { transformations as defaultTransformations } from "./customize.default";

(async function () {
  const sourceDir = "../base";
  const outDir = process.argv.length >= 3 ? process.argv[2] : 'rendered'
  const transformations = outDir === 'rendered-default' ? defaultTransformations : userTransformations

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
    Secrets: [],
    ServiceAccounts: [],
    StatefulSets: [],
    StorageClasses: [],
    RawFiles: [],
    Unrecognized: [],
    ManualInstructions: [],
  };

function transformFilename(sourceDir: string, filename: string): string {
  const rel = path.relative(sourceDir, filename);
  // return rel
  
  const yaml = YAML.parse(readFileSync(filename).toString())
  const dirParts = path.dirname(rel).split(path.sep)
  const baseParts = path.basename(filename).split('.')
  if (baseParts.length < 3) {
    console.log('ERROR: could not transform filename', filename)
    return filename
  }
  let [name, kind, ext] = baseParts
  let prefix = 'apps_v1'

  let foo = false
  if (name === 'backend') {
    foo = true
  }

  {
    // Adjustments
    if (dirParts.length > 0) {
      const dirName = dirParts[dirParts.length-1]
      if ([name, 'frontend', 'redis', 'jaeger', '.'].indexOf(dirName) === -1) {
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

function readCluster(root: string) {
  const contents = readdirSync(root, { withFileTypes: true });
  for (const entry of contents) {
    if (entry.isFile()) {
      if (entry.name.endsWith(".yaml")) {
        const k8sType = path.extname(
          entry.name.substring(0, entry.name.length - ".yaml".length)
          );
          const filename = path.join(root, entry.name);
          switch (k8sType) {
            case ".Deployment":
            cluster.Deployments.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".PersistentVolumeClaim":
            cluster.PersistentVolumeClaims.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".PersistentVolume":
            cluster.PersistentVolumes.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".Service":
            case ".IndexerService":
            cluster.Services.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".ClusterRole":
            cluster.ClusterRoles.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".ClusterRoleBinding":
            cluster.ClusterRoleBindings.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".ConfigMap":
            cluster.ConfigMaps.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".DaemonSet":
            cluster.DaemonSets.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".Ingress":
            cluster.Ingresss.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".PodSecurityPolicy":
            cluster.PodSecurityPolicys.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".Role":
            cluster.Roles.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".RoleBinding":
            cluster.RoleBindings.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".ServiceAccount":
            cluster.ServiceAccounts.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            case ".StatefulSet":
            cluster.StatefulSets.push([
              transformFilename(sourceDir, filename),
              YAML.parse(readFileSync(filename).toString()),
            ]);
            break;
            default:
            cluster.Unrecognized.push(entry.name);
          }
        }
      } else if (entry.isDirectory()) {
        readCluster(path.join(root, entry.name));
      } else {
        console.error("Ignoring unrecognized file type, name: ", entry.name);
      }
    }
  }
  readCluster(sourceDir);

  try {
    for (const t of transformations) {
      await t(cluster);
    }
  } catch (error) {
      console.error("Failed to generate manifest: ", error)
  }

  async function writeCluster(c: Cluster) {
    const fileContents = [];
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
      ...c.StorageClasses,
      ...c.Secrets
    );
    await Promise.all(
      fileContents.map(async (c) => {
        const filename = path.join(outDir, c[0]);
        const directory = path.dirname(filename);
        await mkdirp(directory);
        fs.writeFileSync(filename, YAML.stringify(c[1]));
      })
    );
    for (const [name, contents] of c.RawFiles) {
      fs.writeFileSync(path.join(outDir, name), contents);
    }

    if (c.ManualInstructions.length > 0) {
      console.log(
        "####################\n# Additional steps #\n####################\n"
      );

      for (const instruction of c.ManualInstructions) {
        console.log(instruction + "\n\n\n");
      }
    }
  }

  await writeCluster(cluster);
})().then(() => {
  console.log("Done");
});
