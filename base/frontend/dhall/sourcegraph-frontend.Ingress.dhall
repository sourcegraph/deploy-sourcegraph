let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in  { defaults = kubernetes.Ingress::{
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
          , { mapKey = "sourcegraph-resource-requires"
            , mapValue = "no-cluster-admin"
            }
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
    , Type = kubernetes.Ingress.Type
    }
