let kubernetes = ./kubernetes.dhall

let deploySourcegraphLabel = toMap { deploy = "sourcegraph" }

let prometheusAnnotations =
      [ { mapKey = "sourcegraph.prometheus/scrape", mapValue = "true" }
      , { mapKey = "prometheus.io/port", mapValue = "6060" }
      ]

let makeDeployment =
        λ ( args
          : { name : Text
            , description : Text
            , image : Text
            , resources : kubernetes.ResourceRequirements.Type
            }
          )
      → kubernetes.Deployment::{
        , metadata = kubernetes.ObjectMeta::{
          , annotations = Some
            [ { mapKey = "description", mapValue = args.description } ]
          , labels = Some deploySourcegraphLabel
          , name = Some args.name
          }
        , spec = Some kubernetes.DeploymentSpec::{
          , minReadySeconds = Some 10
          , replicas = Some 1
          , revisionHistoryLimit = Some 10
          , selector = kubernetes.LabelSelector::{
            , matchLabels = Some [ { mapKey = "app", mapValue = args.name } ]
            }
          , strategy = Some kubernetes.DeploymentStrategy::{
            , rollingUpdate = Some
              { maxSurge = Some (kubernetes.IntOrString.Int 1)
              , maxUnavailable = Some (kubernetes.IntOrString.Int 1)
              }
            , type = Some "RollingUpdate"
            }
          , template = kubernetes.PodTemplateSpec::{
            , metadata = kubernetes.ObjectMeta::{
              , labels = Some [ { mapKey = "app", mapValue = args.name } ]
              }
            , spec = Some kubernetes.PodSpec::{
              , containers =
                [ kubernetes.Container::{
                  , image = Some args.description
                  , name = args.name
                  , terminationMessagePolicy = Some "FallbackToLogsOnError"
                  }
                ]
              , securityContext = Some kubernetes.PodSecurityContext::{
                , runAsUser = Some 0
                }
              }
            }
          }
        }

let jaegerAgent =
      kubernetes.Container::{
      , name = "jaeger-agent"
      , image = Some
          "sourcegraph/jaeger-agent:3.15.0@sha256:dc476845a723dce8e44ce07a50b5abb218ec86cb9d75b0ca9601df76db1fb65b"
      , args = Some
        [ "--reporter.grpc.host-port=jaeger-collector:14250"
        , "--reporter.type=grpc"
        ]
      , env = Some
        [ kubernetes.EnvVar::{
          , name = "POD_NAME"
          , valueFrom = Some kubernetes.EnvVarSource::{
            , fieldRef = Some
              { apiVersion = Some "v1", fieldPath = "metadata.name" }
            }
          }
        ]
      , ports = Some
        [ kubernetes.ContainerPort::{
          , containerPort = 5775
          , protocol = Some "UDP"
          }
        , kubernetes.ContainerPort::{
          , containerPort = 5778
          , protocol = Some "TCP"
          }
        , kubernetes.ContainerPort::{
          , containerPort = 6831
          , protocol = Some "UDP"
          }
        , kubernetes.ContainerPort::{
          , containerPort = 6832
          , protocol = Some "UDP"
          }
        ]
      , resources = Some
        { limits = Some
          [ { mapKey = "memory", mapValue = "500M" }
          , { mapKey = "cpu", mapValue = "1" }
          ]
        , requests = Some
          [ { mapKey = "memory", mapValue = "100M" }
          , { mapKey = "cpu", mapValue = "100m" }
          ]
        }
      }

let emptyCacheSSDVolume =
      kubernetes.Volume::{
      , emptyDir = Some { medium = None Text, sizeLimit = None Text }
      , name = "cache-ssd"
      }

in  { emptyCacheSSDVolume
    , jaegerAgent
    , prometheusAnnotations
    , deploySourcegraphLabel
    }
