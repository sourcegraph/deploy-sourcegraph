let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in  { defaults = kubernetes.Role::{
      , metadata = kubernetes.ObjectMeta::{
        , labels = Some
          [ { mapKey = "category", mapValue = "rbac" }
          , { mapKey = "deploy", mapValue = "sourcegraph" }
          , { mapKey = "sourcegraph-resource-requires"
            , mapValue = "cluster-admin"
            }
          ]
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
    , Type = kubernetes.Role.Type
    }
