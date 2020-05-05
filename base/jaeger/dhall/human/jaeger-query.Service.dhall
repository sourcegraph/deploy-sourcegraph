let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , labels = Some
          (   [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
              , { mapKey = "app", mapValue = "jaeger" }
              , { mapKey = "app.kubernetes.io/component", mapValue = "query" }
              ]
            # util.deploySourcegraphLabel
          )
      , name = Some "jaeger-query"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , ports = Some
        [ kubernetes.ServicePort::{
          , name = Some "query-http"
          , port = 16686
          , protocol = Some "TCP"
          , targetPort = Some (kubernetes.IntOrString.Int 16686)
          }
        ]
      , selector = Some
        [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
        , { mapKey = "app.kubernetes.io/component", mapValue = "all-in-one" }
        ]
      , type = Some "ClusterIP"
      }
    }
