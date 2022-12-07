import {
  platform,
  ingress,
  Config,
  setNamespace,
  kustomizeFilenameMapper,
  includeSupplemental,
} from "../../common";
import { nonPrivileged } from "../../privilege";
import { readFileSync } from "fs";
import * as path from "path";
import * as YAML from "yaml";

export const configuration: Config = {
  filenameMapper: kustomizeFilenameMapper,
  outputDirectory: './examples/envoy/rendered',
  transformations: [
    platform("aws"),
    ingress({ ingressType: 'NodePort'}),
    setNamespace("*", "*", "ns-sourcegraph"),
    includeSupplemental("gitserver/gitserver.EnvoyFilter.yaml"),
 ],
}
