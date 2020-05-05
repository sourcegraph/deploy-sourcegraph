let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some util.prometheusAnnotations
      , labels = Some
          (   util.deploySourcegraphLabel
            # [ { mapKey = "app", mapValue = "github-proxy" } ]
          )
      , name = Some "github-proxy"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , ports = Some
        [ kubernetes.ServicePort::{
          , name = Some "http"
          , port = 80
          , targetPort = Some (kubernetes.IntOrString.String "http")
          }
        ]
      , selector = Some [ { mapKey = "app", mapValue = "github-proxy" } ]
      , type = Some "ClusterIP"
      }
    }
