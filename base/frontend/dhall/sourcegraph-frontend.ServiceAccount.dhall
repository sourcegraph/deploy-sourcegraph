let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in  { default = kubernetes.ServiceAccount::{
      , imagePullSecrets = Some [ { name = Some "docker-registry" } ]
      , metadata = kubernetes.ObjectMeta::{
        , labels = Some
          [ { mapKey = "category", mapValue = "rbac" }
          , { mapKey = "deploy", mapValue = "sourcegraph" }
          , { mapKey = "sourcegraph-resource-requires"
            , mapValue = "no-cluster-admin"
            }
          ]
        , name = Some "sourcegraph-frontend"
        }
      }
    , Type = kubernetes.ServiceAccount.Type
    }
