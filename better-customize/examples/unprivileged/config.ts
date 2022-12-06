import {
  platform,
  ingress,
  Config,
  nonPrivileged,
} from "../../common";

export const configuration: Config = {
  outputDirectory: './examples/unprivileged/rendered',
  transformations: [
    platform("aws"),
    ingress({ ingressType: 'NodePort'}),
    nonPrivileged(),
 ],
}