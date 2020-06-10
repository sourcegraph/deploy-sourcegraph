let kubernetes = (./imports.dhall).Kubernetes

let kubernetesTypeUnion = (./imports.dhall).KubernetesTypeUnion

let prelude = (./imports.dhall).Prelude

let deploySourcegraphLabel = toMap { deploy = "sourcegraph" }

let noClusterAdminLabel =
      toMap { sourcegraph-resource-requires = "no-cluster-admin" }

let clusterAdminLabel =
      toMap { sourcegraph-resource-requires = "cluster-admin" }

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
        ) →
        kubernetes.Deployment::{
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
          "index.docker.io/sourcegraph/jaeger-agent:3.16.1@sha256:2fc0cdd7db449e411a01a6ba175ad0b33f8515c343edd7c19569e6f87c6f7fe2"
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
          [ { mapKey = "cpu", mapValue = "1" }
          , { mapKey = "memory", mapValue = "500M" }
          ]
        , requests = Some
          [ { mapKey = "cpu", mapValue = "100m" }
          , { mapKey = "memory", mapValue = "100M" }
          ]
        }
      }

let emptyCacheSSDVolume =
      kubernetes.Volume::{
      , emptyDir = Some { medium = None Text, sizeLimit = None Text }
      , name = "cache-ssd"
      }

let kubernetesList =
      { Type =
        { apiVersion = Text, kind = Text, items = List kubernetesTypeUnion }
      , default =
        { apiVersion = "v1"
        , kind = "List"
        }
      }

in  { emptyCacheSSDVolume
    , jaegerAgent
    , prometheusAnnotations
    , deploySourcegraphLabel
    , noClusterAdminLabel
    , clusterAdminLabel
    , kubernetes
    , kubernetesTypeUnion
    , prelude
    , kubernetesList
    }
