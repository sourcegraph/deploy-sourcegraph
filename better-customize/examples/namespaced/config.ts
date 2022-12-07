import {
  platform,
  ingress,
  Config,
  setNamespace,
  kustomizeFilenameMapper,
  includeSupplemental,
} from "../../common";

export const configuration: Config = {
  filenameMapper: kustomizeFilenameMapper,
  outputDirectory: './examples/namespaced/rendered',
  transformations: [
    platform("aws"),
    ingress({ ingressType: 'NodePort'}),
    setNamespace("*", "*", "ns-sourcegraph"),
 ],
}
