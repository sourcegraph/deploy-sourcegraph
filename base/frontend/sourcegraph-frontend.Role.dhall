let kubernetes = (../../imports.dhall).Kubernetes

let prelude = (../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../configuration/config.dhall

let util = ../../util/util.dhall

let make =
      λ(c : Configuration/global.Type) →
      let overrides = c.Frontend.Role
        let additionalLabels =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                overrides.additionalLabels

        let role =
              kubernetes.Role::{
              , metadata = kubernetes.ObjectMeta::{
                , annotations = overrides.additionalAnnotations
                , labels = Some
                    (   [ { mapKey = "category", mapValue = "rbac" }
                        , { mapKey = "deploy", mapValue = "sourcegraph" }
                        , { mapKey = "sourcegraph-resource-requires"
                          , mapValue = "cluster-admin"
                          }
                        ]
                      # additionalLabels
                    )
                , namespace = overrides.namespace
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

in  make
