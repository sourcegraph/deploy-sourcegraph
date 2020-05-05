let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , labels = Some
          (   [ { mapKey = "app", mapValue = "grafana" } ]
            # util.deploySourcegraphLabel
          )
      , name = Some "grafana"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , ports = Some
        [ kubernetes.ServicePort::{
          , name = Some "http"
          , port = 30070
          , targetPort = Some (kubernetes.IntOrString.String "http")
          }
        ]
      , selector = Some [ { mapKey = "app", mapValue = "grafana" } ]
      , type = Some "ClusterIP"
      }
    }
