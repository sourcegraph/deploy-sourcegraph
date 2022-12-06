import {
  platform,
  ingress,
  Config,
} from "./common";

export const configuration: Config = {
  transformations: [
    platform("gcp"),
    ingress({ ingressType: 'NodePort'}),
 ],
}