let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.ServiceAccount::{
    , imagePullSecrets = Some [ { name = Some "docker-registry" } ]
    , metadata = kubernetes.ObjectMeta::{
      , labels = Some
          (   [ { mapKey = "category", mapValue = "rbac" } ]
            # util.deploySourcegraphLabel
          )
      , name = Some "grafana"
      }
    }
