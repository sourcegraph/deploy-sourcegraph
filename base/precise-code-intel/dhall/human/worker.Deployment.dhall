let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Deployment::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue =
              "Handles conversion of uploaded precise code intelligence bundles."
          }
        ]
      , labels = Some util.deploySourcegraphLabel
      , name = Some "precise-code-intel-worker"
      }
    , spec = Some kubernetes.DeploymentSpec::{
      , minReadySeconds = Some 10
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some
          [ { mapKey = "app", mapValue = "precise-code-intel-worker" } ]
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
          , labels = Some
            [ { mapKey = "app", mapValue = "precise-code-intel-worker" } ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , env = Some
                [ kubernetes.EnvVar::{ name = "NUM_WORKERS", value = Some "4" }
                , kubernetes.EnvVar::{
                  , name = "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL"
                  , value = Some "http://precise-code-intel-bundle-manager:3187"
                  }
                , kubernetes.EnvVar::{
                  , name = "POD_NAME"
                  , valueFrom = Some kubernetes.EnvVarSource::{
                    , fieldRef = Some
                      { apiVersion = None Text, fieldPath = "metadata.name" }
                    }
                  }
                ]
              , image = Some
                  "index.docker.io/sourcegraph/precise-code-intel-worker:3.15.1@sha256:00642b4bd6f37ff3e80b4b94a5699cef5ededae6875a5010c4202fd91ad0dfaf"
              , livenessProbe = Some kubernetes.Probe::{
                , exec = None { command : Optional (List Text) }
                , failureThreshold = None Natural
                , httpGet = Some kubernetes.HTTPGetAction::{
                  , path = Some "/healthz"
                  , port = kubernetes.IntOrString.String "server"
                  , scheme = Some "HTTP"
                  }
                , initialDelaySeconds = Some 60
                , timeoutSeconds = Some 5
                }
              , name = "precise-code-intel-worker"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 3188
                  , name = Some "server"
                  }
                , kubernetes.ContainerPort::{
                  , containerPort = 9090
                  , name = Some "prometheus"
                  }
                ]
              , readinessProbe = Some kubernetes.Probe::{
                , httpGet = Some kubernetes.HTTPGetAction::{
                  , path = Some "/healthz"
                  , port = kubernetes.IntOrString.String "server"
                  , scheme = Some "HTTP"
                  }
                , periodSeconds = Some 5
                , timeoutSeconds = Some 5
                }
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "2G" }
                  , { mapKey = "cpu", mapValue = "2" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "500M" }
                  , { mapKey = "cpu", mapValue = "500m" }
                  ]
                }
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
