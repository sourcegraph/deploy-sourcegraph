import { patchApp, patchRedis } from "./common";

export const transformations = [
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
  patchRedis("rediscash.com", "redisstore.com")
];
