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
                c.Frontend.Role.additionalLabels

        let role =
              kubernetes.Role::{
              , metadata = kubernetes.ObjectMeta::{
                , annotations = c.Frontend.RoleBinding.additionalAnnotations
                , labels = Some
                    (   [ { mapKey = "category", mapValue = "rbac" }
                        , { mapKey = "deploy", mapValue = "sourcegraph" }
                        , { mapKey = "sourcegraph-resource-requires"
                          , mapValue = "cluster-admin"
                          }
                        ]
                      # additionalLabels
                    )
                , namespace = c.Frontend.Role.namespace
                , name = Some "sourcegraph-frontend"
                }
              , rules = Some
                [ kubernetes.PolicyRule::{
                  , apiGroups = Some [ "" ]
                  , resources = Some [ "endpoints", "services" ]
                  , verbs = [ "get", "list", "watch" ]
                  }
                ]
              }

        in  role

in  render
