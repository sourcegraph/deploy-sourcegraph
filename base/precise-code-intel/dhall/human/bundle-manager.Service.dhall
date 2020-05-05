let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Service::{
    , apiVersion = "v1"
    , kind = "Service"
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "sourcegraph.prometheus/scrape", mapValue = "true" }
        , { mapKey = "prometheus.io/port", mapValue = "3187" }
        ]
      , labels = Some
          (   [ { mapKey = "app"
                , mapValue = "precise-code-intel-bundle-manager"
                }
              ]
            # util.deploySourcegraphLabel
          )
      , name = Some "precise-code-intel-bundle-manager"
      }
    , spec = Some kubernetes.ServiceSpec::{
      , ports = Some
        [ kubernetes.ServicePort::{
          , name = Some "server"
          , port = 3187
          , targetPort = Some (kubernetes.IntOrString.String "server")
          }
        ]
      , selector = Some
        [ { mapKey = "app", mapValue = "precise-code-intel-bundle-manager" } ]
      , type = Some "ClusterIP"
      }
    }
