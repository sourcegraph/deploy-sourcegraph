let kubernetes = ../../../../util/kubernetes.dhall
let util = ../../../../util/util.dhall

in  kubernetes.Deployment::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue = "Rate-limiting proxy for the GitHub API."
          }
        ]
      , labels = Some util.deploySourcegraphLabel
      , name = Some "github-proxy"
      }
    , spec = Some kubernetes.DeploymentSpec::{
      , minReadySeconds = Some 10
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some [ { mapKey = "app", mapValue = "github-proxy" } ]
        }
      , strategy = Some
        { rollingUpdate = Some
          { maxSurge = Some (kubernetes.IntOrString.Int 1)
          , maxUnavailable = Some (kubernetes.IntOrString.Int 0)
          }
        , type = Some "RollingUpdate"
        }
      , template = kubernetes.PodTemplateSpec::{
        , metadata = kubernetes.ObjectMeta::{
          , labels = Some [ { mapKey = "app", mapValue = "github-proxy" } ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , image = Some
                  "index.docker.io/sourcegraph/github-proxy:3.15.1@sha256:61d1a71d42a2f6feb71bd44a642afaeb388ef763f6e5d8c71056cd651479eed4"
              , name = "github-proxy"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 3180
                  , name = Some "http"
                  }
                ]
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "1G" }
                  , { mapKey = "cpu", mapValue = "1" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "250M" }
                  , { mapKey = "cpu", mapValue = "100m" }
                  ]
                }
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              }
            , util.jaegerAgent
            ]
          , securityContext = Some kubernetes.PodSecurityContext::{
            , runAsUser = Some 0
            }
          }
        }
      }
    }
