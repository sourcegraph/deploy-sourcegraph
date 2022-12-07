import {
  platform,
  ingress,
  Config,
  setNamespace,
  kustomizeFilenameMapper,
} from "../../common";
import { nonPrivileged } from "../../privilege";

export const configuration: Config = {
  filenameMapper: kustomizeFilenameMapper,
  outputDirectory: './examples/unprivileged/rendered',
  transformations: [
    platform("aws"),
    ingress({ ingressType: 'NodePort'}),
    nonPrivileged(),
    setNamespace('*', '*', 'ns-sourcegraph'),
 ],
}