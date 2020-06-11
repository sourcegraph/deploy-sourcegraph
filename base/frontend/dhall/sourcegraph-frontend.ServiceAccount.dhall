let kubernetes = (../../../imports.dhall).Kubernetes

let prelude = (../../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../../config/config.dhall

let util = ../../../util/util.dhall

let render =
      λ(c : Configuration/global.Type) →
        let additionalLabels =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                c.Frontend.ServiceAccount.additionalLabels

        let serviceAccount =
              kubernetes.ServiceAccount::{
              , imagePullSecrets = Some [ { name = Some "docker-registry" } ]
              , metadata = kubernetes.ObjectMeta::{
                , annotations = c.Frontend.ServiceAccount.additionalAnnotations
                , labels = Some
                    (   [ { mapKey = "category", mapValue = "rbac" }
                        , { mapKey = "deploy", mapValue = "sourcegraph" }
                        , { mapKey = "sourcegraph-resource-requires"
                          , mapValue = "no-cluster-admin"
                          }
                        ]
                      # additionalLabels
                    )
                , namespace = c.Frontend.ServiceAccount.namespace
                , name = Some "sourcegraph-frontend"
                }
              }

        in  serviceAccount

in  render
