import { readdirSync, readFileSync } from "fs";
import * as fs from "fs";
import * as YAML from "yaml";
import * as path from "path";
import * as mkdirp from "mkdirp";
import { Cluster, Config, defaultFilenameMapper, MustConfig, addToCluster, newCluster } from "./common";
import { normalizeOptions, normalizeYAMLRecursive } from './utils/normalize'

(async function () {
  if (process.env.NORMALIZE) {
    await normalizeYAMLRecursive(process.env.NORMALIZE, process.env.OUTDIR)
    return
  }

  const configImportPath = process.env.EXAMPLE ? `./examples/${process.env.EXAMPLE}/config` : './config'
  const defaultConfig: MustConfig = {
      sourceDirectory: '../base',
      outputDirectory: '../rendered',
      filenameMapper: defaultFilenameMapper,
      transformations: [],
  }
  const userConfig: Config = (await import(configImportPath)).configuration
  const config = {
    ...defaultConfig,
    ...userConfig,
  }

  const cluster: Cluster = newCluster();

  function readCluster(root: string) {
    const contents = readdirSync(root, { withFileTypes: true });
    for (const entry of contents) {
      if (entry.isFile()) {
        if (entry.name.endsWith(".yaml")) {
          const filename = path.join(root, entry.name)
          addToCluster(cluster, filename, config.filenameMapper(config.sourceDirectory, filename));
        }
      } else if (entry.isDirectory()) {
        readCluster(path.join(root, entry.name));
      } else {
        console.error("Ignoring unrecognized file type, name: ", entry.name);
      }
    }
  }
  readCluster(config.sourceDirectory);

  try {
    for (const t of config.transformations) {
      await t(cluster, config);
    }
  } catch (error) {
      console.error("Failed to generate manifest: ", error)
      return
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

    // TODO: do the rm -rf ouptputDirectory in TypeScript
    
    await Promise.all(
      fileContents.map(async (c) => {
        const filename = path.join(config.outputDirectory, c[0]);
        const directory = path.dirname(filename);
        await mkdirp(directory);
        fs.writeFileSync(filename, YAML.stringify(c[1], normalizeOptions));
      })
    );
    for (const [name, contents] of c.RawFiles) {
      fs.writeFileSync(path.join(config.outputDirectory, name), contents);
    }

    // copy directory recursively
    const copy = (source: string, target: string) => {
      const files = readdirSync(source);
      for (const file of files) {
        const sourceFile = path.join(source, file);
        const targetFile = path.join(target, file);
        if (fs.lstatSync(sourceFile).isDirectory()) {
          copy(sourceFile, targetFile);
        } else {
          // TODO: check if directory already exists
          fs.copyFileSync(sourceFile, targetFile);
        }
      }
    }
    for (const manifestDir of config.additionalManifestDirectories || []) {
      copy(manifestDir, config.outputDirectory);
    }

    // if (c.ManualInstructions.length > 0) {
    //   console.log(
    //     "####################\n# Additional steps #\n####################\n"
    //   );

    //   for (const instruction of c.ManualInstructions) {
    //     console.log(instruction + "\n\n\n");
    //   }
    // }
  }

  await writeCluster(cluster);
})().then(() => {
  console.log("Done");
});
