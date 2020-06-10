let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in  { default = kubernetes.Service::{
      , metadata = kubernetes.ObjectMeta::{
        , annotations = None (List { mapKey : Text, mapValue : Text })
        , labels = Some
          [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
          , { mapKey = "deploy", mapValue = "sourcegraph" }
          , { mapKey = "sourcegraph-resource-requires"
            , mapValue = "no-cluster-admin"
            }
          ]
        , name = Some "sourcegraph-frontend-internal"
        }
      , spec = Some kubernetes.ServiceSpec::{
        , ports = Some
          [ kubernetes.ServicePort::{
            , name = Some "http-internal"
            , port = 80
            , targetPort = Some (kubernetes.IntOrString.String "http-internal")
            }
          ]
        , selector = Some
          [ { mapKey = "app", mapValue = "sourcegraph-frontend" } ]
        , type = Some "ClusterIP"
        }
      }
    , Type = kubernetes.Service.Type
    }
