let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
          (   util.prometheusAnnotations
            # [ { mapKey = "description"
                , mapValue =
                    "Headless service that provides a stable network identity for the gitserver stateful set."
                }
              ]
          )
      , labels = Some
          (   [ { mapKey = "app", mapValue = "gitserver" }
              , { mapKey = "type", mapValue = "gitserver" }
              ]
            # util.deploySourcegraphLabel
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
