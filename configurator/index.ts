import * as k8s from "@kubernetes/client-node";
import { fstat, readdirSync, readFile, readFileSync } from "fs";
import * as fs from "fs";
import * as YAML from "yaml";
import * as path from "path";
import * as mkdirp from "mkdirp";
import { Overlay, PatchTarget } from "./common";
import { transformations as userTransformations } from "./customize";
import { transformations as defaultTransformations } from "./customize.default";
import * as glob from "glob"
import { Dictionary } from "lodash";

(async function () {
  const outDir = process.argv.length >= 3 ? process.argv[2] : '../overlays/rendered'
  const transformations = outDir === 'rendered-default' ? defaultTransformations : userTransformations

  const basesFiles = glob.sync('../base/**/*.yaml')
  const bases = basesFiles.reduce((acc, base) => {
    const target = YAML.parse(readFileSync(base).toString()) as PatchTarget;
    const identifier = path.basename(base).replace(path.extname(base), '').toLowerCase()
    acc[identifier] = {
      apiVersion: target.apiVersion,
      kind: target.kind,
      metadata: target.metadata,
    };
    return acc
  }, {} as { [key: string]: PatchTarget })

  const overlay: Overlay = {
    Bases: bases,
    Patches: [],
    Unrecognized: [],
    ManualInstructions: [],

    // TODO
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
  };

  try {
    for (const t of transformations) {
      await t(overlay);
    }
  } catch (error) {
    console.error("Failed to generate manifest: ", error)
  }

  async function writeOverlay(c: Overlay) {
    const fileContents = [];
    fileContents.push(
      ...c.Patches
    );
    const patches: string[] = []
    await mkdirp(outDir);
    await Promise.all(
      fileContents.map(async (c) => {
        const filename = path.join(outDir, c[0] + '.yaml');
        patches.push(path.basename(filename));
        const directory = path.dirname(filename);
        await mkdirp(directory);
        fs.writeFileSync(filename, YAML.stringify(c[1]));
      })
    );
    for (const [name, contents] of c.RawFiles) {
      fs.writeFileSync(path.join(outDir, name), contents);
    }
    fs.writeFileSync(path.join(outDir, 'kustomization.yaml'), YAML.stringify({
      apiVersion: 'kustomize.config.k8s.io/v1beta1',
      kind: 'Kustomization',
      patchesStrategicMerge: patches,
      resources: basesFiles,
    }))

    if (c.ManualInstructions.length > 0) {
      console.log(
        "####################\n# Additional steps #\n####################\n"
      );

      for (const instruction of c.ManualInstructions) {
        console.log(instruction + "\n\n\n");
      }
    }
  }

  await writeOverlay(overlay);
})().then(() => {
  console.log("Done");
});
