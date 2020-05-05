let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/fc275e649b48c5e6badcff25f377d03baf1ee5d0/package.dhall

in  kubernetes.Ingress::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "kubernetes.io/ingress.class", mapValue = "nginx" }
        , { mapKey = "nginx.ingress.kubernetes.io/proxy-body-size"
          , mapValue = "150m"
          }
        ]
      , labels = Some
        [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
        , { mapKey = "deploy", mapValue = "sourcegraph" }
        ]
      , name = Some "sourcegraph-frontend"
      }
    , spec = Some kubernetes.IngressSpec::{
      , rules = Some
        [ kubernetes.IngressRule::{
          , http = Some kubernetes.HTTPIngressRuleValue::{
            , paths =
              [ kubernetes.HTTPIngressPath::{
                , backend =
                  { serviceName = "sourcegraph-frontend"
                  , servicePort = kubernetes.IntOrString.Int 30080
                  }
                , path = Some "/"
                }
              ]
            }
          }
        ]
      }
    }
