let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "sourcegraph.prometheus/scrape", mapValue = "true" }
        , { mapKey = "description"
          , mapValue =
              "Headless service that provides a stable network identity for the indexed-search stateful set."
          }
        ]
      , labels = Some
          (   [ { mapKey = "app", mapValue = "indexed-search" } ]
            # util.deploySourcegraphLabel
          )
      , name = Some "indexed-search"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , clusterIP = Some "None"
      , ports = Some [ kubernetes.ServicePort::{ port = 6070 } ]
      , selector = Some [ { mapKey = "app", mapValue = "indexed-search" } ]
      , type = Some "ClusterIP"
      }
    }
