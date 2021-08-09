import { Transform, patchApp, patchCustomRedis, patchPlatform } from "./common";

export const transformations: Transform[] = [
  patchPlatform("gcp"),
  patchApp("gitserver.statefulset", (app) => {
    app.spec = {
      replicas: 9000,
      template: {
        spec: {
          containers: [ { name: 'gitserver', resources: { limits: { cpu: '9000' } } } ]
        },
      },
    }
  }),
  patchCustomRedis("rediscash.com", "redisstore.com"),
  patchApp("sourcegraph-frontend.deployment", (app) => {
    app.spec = {
      replicas: 9000,
    }
  }),
];
