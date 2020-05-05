let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.ConfigMap::{
    , data = Some
      [ { mapKey = "postgresql.conf", mapValue = ./postgresql.conf as Text } ]
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description", mapValue = "Configuration for PostgreSQL" }
        ]
      , labels = Some util.deploySourcegraphLabel
      , name = Some "pgsql-conf"
      }
    }
