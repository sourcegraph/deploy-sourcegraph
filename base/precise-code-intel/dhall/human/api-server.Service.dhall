let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "sourcegraph.prometheus/scrape", mapValue = "true" }
        , { mapKey = "prometheus.io/port", mapValue = "3186" }
        ]
      , labels = Some
          (   [ { mapKey = "app", mapValue = "precise-code-intel-api-server" } ]
            # util.deploySourcegraphLabel
          )
      , name = Some "precise-code-intel-api-server"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , ports = Some
        [ kubernetes.ServicePort::{
          , name = Some "server"
          , port = 3186
          , targetPort = Some (kubernetes.IntOrString.String "server")
          }
        ]
      , selector = Some
        [ { mapKey = "app", mapValue = "precise-code-intel-api-server" } ]
      , type = Some "ClusterIP"
      }
    }
