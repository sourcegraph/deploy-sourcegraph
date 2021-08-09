import * as k8s from "@kubernetes/client-node";
import * as _ from "lodash";
import { readFileSync } from "fs";
import * as YAML from "yaml";
import * as path from "path";

export interface Overlay {
  Bases: { [key: string]: PatchTarget };
  Patches: [string, any][];
  Create: [string, any][];

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

export type Transform = (c: Overlay) => Promise<void>;

export type PatchTarget = {
  apiVersion?: string;
  kind?: string;
  metadata?: k8s.V1ObjectMeta;
};

type DeepPartial<T> = {
  [P in keyof T]?: DeepPartial<T[P]>;
};

// a bare-bones patch. primary way to make simple changes
export const patchApp =
  (
    target: string,
    patch: (app: DeepPartial<k8s.V1Deployment | k8s.V1StatefulSet>) => void
  ): Transform =>
  async (c: Overlay) => {
    const base = c.Bases[target.toLowerCase()];
    if (!base) c.Unrecognized.push(target);

    const app = { ...base };
    patch(app);
    c.Patches.push([target, app]);
  };

// a more complicated group of patches that we provide out of the box
export const patchCustomRedis =
  (redisCacheEndpoint: string, redisStoreEndpoint: string): Transform =>
  async (c: Overlay) => {
    const patches = [
      { target: "sourcegraph-frontend.deployment", container: "frontend" },
      { target: "repo-updater.deployment", container: "redis" },
    ].map(({ target, container }) => {
      return patchApp(target, (app) => {
        app.spec = {
          template: {
            spec: {
              containers: [
                {
                  name: container,
                  env: [
                    { name: "REDIS_CACHE_ENDPOINT", value: redisCacheEndpoint },
                    { name: "REDIS_STORE_ENDPOINT", value: redisStoreEndpoint },
                  ],
                },
              ],
            },
          },
        };
      })(c);
    });
    await Promise.all(patches)
  };

export const patchPlatform =
  (
    base: "gcp" | "aws" | "azure" | "minikube" | "generic",
    customizeStorageClass?: (sc: k8s.V1StorageClass) => void
  ): Transform =>
  (c: Overlay) => {
    const obj = YAML.parse(
      readFileSync(path.join("custom", `${base}.StorageClass.yaml`)).toString()
    );
    if (customizeStorageClass) {
      customizeStorageClass(obj);
    }
    c.Create.push(["sourcegraph.StorageClass.yaml", obj])

    // TODO: should we reveal Bases internals to allow for operations like these?
    // Maybe the right way to do this is to not include resources at all in the bases,
    // and only provide them in overlays. Alternatively, could selectively provide some
    // aggregated metadata in Bases.
    //
    // if (base === "minikube") {
    //   const removeResources = (
    //     deployOrSS: k8s.V1Deployment | k8s.V1StatefulSet
    //   ) => {
    //     deployOrSS.spec?.template.spec?.containers.forEach(
    //       (container) => delete container["resources"]
    //     );
    //   };
    //   c.Deployments.forEach(([, deployment]) => removeResources(deployment));
    //   c.StatefulSets.forEach(([, ss]) => removeResources(ss));
    // }

    return Promise.resolve();
  };
