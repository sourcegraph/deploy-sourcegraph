let util = ../../../../util/util.dhall

let kubernetes = util.kubernetes

in  kubernetes.ConfigMap::{
    , data = Some
      [ { mapKey = "postgresql.conf", mapValue = ./postgresql.conf as Text } ]
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description", mapValue = "Configuration for PostgreSQL" }
        ]
      , labels = Some
          (   util.deploySourcegraphLabel
            # [ { mapKey = "sourcegraph-resource-requires"
                , mapValue = "no-cluster-admin"
                }
              ]
          )
      , name = Some "pgsql-conf"
      }
    }
