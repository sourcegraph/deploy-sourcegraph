let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in { defaults = kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "prometheus.io/port", mapValue = "6060" }
        , { mapKey = "sourcegraph.prometheus/scrape", mapValue = "true" }
        ]
      , labels = Some
        [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
        , { mapKey = "deploy", mapValue = "sourcegraph" }
        , { mapKey = "sourcegraph-resource-requires"
          , mapValue = "no-cluster-admin"
          }
        ]
      , name = Some "sourcegraph-frontend"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , ports = Some
        [ kubernetes.ServicePort::{
          , name = Some "http"
          , port = 30080
          , targetPort = Some (kubernetes.IntOrString.String "http")
          }
        ]
      , selector = Some
        [ { mapKey = "app", mapValue = "sourcegraph-frontend" } ]
      , type = Some "ClusterIP"
      }
    }, Type = kubernetes.Service.Type 
}
