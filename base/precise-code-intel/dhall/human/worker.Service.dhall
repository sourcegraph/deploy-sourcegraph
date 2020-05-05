let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "prometheus.io/port", mapValue = "9090" }
        , { mapKey = "sourcegraph.prometheus/federate", mapValue = "true" }
        ]
      , labels = Some
          (   [ { mapKey = "app", mapValue = "precise-code-intel-worker" } ]
            # util.deploySourcegraphLabel
          )
      , name = Some "precise-code-intel-worker"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , ports = Some
        [ kubernetes.ServicePort::{
          , name = Some "server"
          , port = 3188
          , targetPort = Some (kubernetes.IntOrString.String "server")
          }
        , kubernetes.ServicePort::{
          , name = Some "prometheus"
          , port = 9090
          , targetPort = Some (kubernetes.IntOrString.String "prometheus")
          }
        ]
      , selector = Some
        [ { mapKey = "app", mapValue = "precise-code-intel-worker" } ]
      , type = Some "ClusterIP"
      }
    }
