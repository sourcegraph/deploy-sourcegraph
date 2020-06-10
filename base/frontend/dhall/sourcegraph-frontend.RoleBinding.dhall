let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in  { defaults = kubernetes.RoleBinding::{
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
      , roleRef = kubernetes.RoleRef::{
        , apiGroup = ""
        , kind = "Role"
        , name = "sourcegraph-frontend"
        }
      , subjects = Some
        [ kubernetes.Subject::{
          , kind = "ServiceAccount"
          , name = "sourcegraph-frontend"
          }
        ]
      }
    , Type = kubernetes.RoleBinding.Type
    }
