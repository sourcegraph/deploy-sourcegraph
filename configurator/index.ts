import * as k8s from "@kubernetes/client-node";
import { readFileSync } from "fs";
import * as fs from "fs";
import * as YAML from "yaml";
import * as path from "path";
import * as mkdirp from "mkdirp";
import { Overlay, PatchTarget } from "./common";
import { transformations as userTransformations } from "./customize";
import { transformations as defaultTransformations } from "./customize.default";
import * as glob from "glob";

(async function () {
  const outDir =
    process.argv.length >= 3 ? process.argv[2] : "../overlays/rendered";
  const transformations =
    outDir === "rendered-default"
      ? defaultTransformations
      : userTransformations;

  const basesFiles = glob.sync("../base/**/*.yaml");
  const bases = basesFiles.reduce((acc, base) => {
    const target = YAML.parse(readFileSync(base).toString()) as PatchTarget;
    const identifier = path
      .basename(base)
      .replace(path.extname(base), "")
      .toLowerCase();
    acc[identifier] = {
      apiVersion: target.apiVersion,
      kind: target.kind,
      metadata: target.metadata,
    };
    return acc;
  }, {} as { [key: string]: PatchTarget });

  const overlay: Overlay = {
    Bases: bases,
    Patches: [],
    Create: [],

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
    console.error("Failed to generate manifest: ", error);
  }

  const resources = basesFiles.map((f) => f.replace("../", ""));
  async function writeOverlay(c: Overlay) {
    const patchFiles: { [key: string]: string } = {}

    await mkdirp(outDir);
    await Promise.all([
      ...c.Patches.map(async (c) => {
        let patchName = c[0]
        if (patchFiles[patchName]) {
          let altPatchName = patchName;
          for (let i = 1; patchFiles[altPatchName]; i++) {
            altPatchName = patchName + `-${i}`
          }
          patchName = altPatchName
        }
        const patchFile = patchName + ".yaml"
        const filename = path.join(outDir, patchFile);
        patchFiles[patchName] = patchFile;

        const directory = path.dirname(filename);
        await mkdirp(directory);
        fs.writeFileSync(filename, YAML.stringify(c[1]));
      }),
      ...c.Create.map(async (c) => {
        const resourceFile = path.join('base', c[0])
        resources.push(resourceFile);
        const filename = path.join(outDir, resourceFile);
        const directory = path.dirname(filename);
        await mkdirp(directory);
        fs.writeFileSync(filename, YAML.stringify(c[1]));
      }),
    ]);
    for (const [name, contents] of c.RawFiles) {
      fs.writeFileSync(path.join(outDir, name), contents);
    }
    fs.writeFileSync(
      path.join(outDir, "kustomization.yaml"),
      YAML.stringify({
        apiVersion: "kustomize.config.k8s.io/v1beta1",
        kind: "Kustomization",
        patchesStrategicMerge: Object.values(patchFiles),
        resources,
      })
    );

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
