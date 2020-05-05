let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , labels = Some
          (   [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
              , { mapKey = "app", mapValue = "jaeger" }
              , { mapKey = "app.kubernetes.io/component"
                , mapValue = "collector"
                }
              ]
            # util.deploySourcegraphLabel
          )
      , name = Some "jaeger-collector"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , ports = Some
        [ kubernetes.ServicePort::{
          , name = Some "jaeger-collector-tchannel"
          , port = 14267
          , protocol = Some "TCP"
          , targetPort = Some (kubernetes.IntOrString.Int 14267)
          }
        , kubernetes.ServicePort::{
          , name = Some "jaeger-collector-http"
          , port = 14268
          , protocol = Some "TCP"
          , targetPort = Some (kubernetes.IntOrString.Int 14268)
          }
        , kubernetes.ServicePort::{
          , name = Some "jaeger-collector-grpc"
          , port = 14250
          , protocol = Some "TCP"
          , targetPort = Some (kubernetes.IntOrString.Int 14250)
          }
        ]
      , selector = Some
        [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
        , { mapKey = "app.kubernetes.io/component", mapValue = "all-in-one" }
        ]
      , type = Some "ClusterIP"
      }
    }
