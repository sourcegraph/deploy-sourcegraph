let kubernetes = (../../imports.dhall).Kubernetes

let prelude = (../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let util = ../../util.dhall

let Configuration/global = ../../configuration/config.dhall

let make =
      λ(c : Configuration/global.Type) →
        let overrides = c.Frontend.ServiceAccount

        let additionalLabels =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                overrides.additionalLabels

        let serviceAccount =
              kubernetes.ServiceAccount::{
              , imagePullSecrets = Some [ { name = Some "docker-registry" } ]
              , metadata = kubernetes.ObjectMeta::{
                , annotations = overrides.additionalAnnotations
                , labels = Some
                    (   [ { mapKey = "category", mapValue = "rbac" }
                        , { mapKey = "deploy", mapValue = "sourcegraph" }
                        , { mapKey = "sourcegraph-resource-requires"
                          , mapValue = "no-cluster-admin"
                          }
                        ]
                      # additionalLabels
                    )
                , namespace = overrides.namespace
                , name = Some "sourcegraph-frontend"
                }
              }

        in  serviceAccount

in  make
