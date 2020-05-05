let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Deployment::{
    , metadata = kubernetes.ObjectMeta::{
      , labels = Some
          (   [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
              , { mapKey = "app", mapValue = "jaeger" }
              , { mapKey = "app.kubernetes.io/component"
                , mapValue = "all-in-one"
                }
              ]
            # util.deploySourcegraphLabel
          )
      , name = Some "jaeger"
      }
    , spec = Some kubernetes.DeploymentSpec::{
      , replicas = Some 1
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some
          [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
          , { mapKey = "app", mapValue = "jaeger" }
          , { mapKey = "app.kubernetes.io/component", mapValue = "all-in-one" }
          ]
        }
      , strategy = Some kubernetes.DeploymentStrategy::{
        , type = Some "Recreate"
        }
      , template = kubernetes.PodTemplateSpec::{
        , metadata = kubernetes.ObjectMeta::{
          , annotations = Some
            [ { mapKey = "prometheus.io/port", mapValue = "16686" }
            , { mapKey = "prometheus.io/scrape", mapValue = "true" }
            ]
          , labels = Some
            [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
            , { mapKey = "app", mapValue = "jaeger" }
            , { mapKey = "app.kubernetes.io/component"
              , mapValue = "all-in-one"
              }
            ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , args = Some [ "--memory.max-traces=20000" ]
              , image = Some
                  "sourcegraph/jaeger-all-in-one:3.15.0@sha256:5fa54e0ef24d0c4afea3616b892e83210a8ab8d0906d4bc604bbfdc6c90df30f"
              , name = "jaeger"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 5775
                  , protocol = Some "UDP"
                  }
                , kubernetes.ContainerPort::{
                  , containerPort = 6831
                  , protocol = Some "UDP"
                  }
                , kubernetes.ContainerPort::{
                  , containerPort = 6832
                  , protocol = Some "UDP"
                  }
                , kubernetes.ContainerPort::{
                  , containerPort = 5778
                  , protocol = Some "TCP"
                  }
                , kubernetes.ContainerPort::{
                  , containerPort = 16686
                  , protocol = Some "TCP"
                  }
                , kubernetes.ContainerPort::{
                  , containerPort = 14250
                  , protocol = Some "TCP"
                  }
                ]
              , readinessProbe = Some kubernetes.Probe::{
                , httpGet = Some kubernetes.HTTPGetAction::{
                  , path = Some "/"
                  , port = kubernetes.IntOrString.Int 14269
                  }
                , initialDelaySeconds = Some 5
                }
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "1G" }
                  , { mapKey = "cpu", mapValue = "1" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "500M" }
                  , { mapKey = "cpu", mapValue = "500m" }
                  ]
                }
              }
            ]
          , securityContext = Some kubernetes.PodSecurityContext::{
            , runAsUser = Some 0
            }
          }
        }
      }
    }
