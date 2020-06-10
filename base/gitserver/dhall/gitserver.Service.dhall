let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
          ( toMap
              { `sourcegraph.prometheus/scrape` = "true"
              , `prometheus.io/port` = "6060"
              , description =
                  "Headless service that provides a stable network identity for the gitserver stateful set."
              }
          )
      , labels = Some
          ( toMap
              { sourcegraph-resource-requires = "no-cluster-admin"
              , app = "gitserver"
              , type = "gitserver"
              , deploy = "sourcegraph"
              }
          )
      , name = Some "gitserver"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , clusterIP = Some "None"
      , ports = Some
        [ kubernetes.ServicePort::{
          , name = Some "unused"
          , port = 10811
          , targetPort = Some (kubernetes.IntOrString.Int 10811)
          }
        ]
      , selector = Some
        [ { mapKey = "app", mapValue = "gitserver" }
        , { mapKey = "type", mapValue = "gitserver" }
        ]
      , type = Some "ClusterIP"
      }
    }
