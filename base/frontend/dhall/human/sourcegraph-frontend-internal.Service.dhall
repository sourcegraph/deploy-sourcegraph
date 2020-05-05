let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall sha256:7150ac4309a091740321a3a3582e7695ee4b81732ce8f1ed1691c1c52791daa1

in  kubernetes.Service::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = None (List { mapKey : Text, mapValue : Text })
      , labels = Some
        [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
        , { mapKey = "deploy", mapValue = "sourcegraph" }
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
