let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Deployment::{
    , apiVersion = "apps/v1"
    , kind = "Deployment"
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue = "Serves precise code intelligence requests."
          }
        ]
      , labels = Some util.deploySourcegraphLabel
      , name = Some "precise-code-intel-api-server"
      }
    , spec = Some kubernetes.DeploymentSpec::{
      , minReadySeconds = Some 10
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some
          [ { mapKey = "app", mapValue = "precise-code-intel-api-server" } ]
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
            [ { mapKey = "app", mapValue = "precise-code-intel-api-server" } ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , env = Some
                [ kubernetes.EnvVar::{
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
                  "index.docker.io/sourcegraph/precise-code-intel-api-server:3.15.1@sha256:ee80ffbd8b2d50c9cd8a38ed2e02f4e4be0886557089d56525d71e601d3a74e7"
              , livenessProbe = Some kubernetes.Probe::{
                , httpGet = Some kubernetes.HTTPGetAction::{
                  , path = Some "/healthz"
                  , port = kubernetes.IntOrString.String "server"
                  , scheme = Some "HTTP"
                  }
                , initialDelaySeconds = Some 60
                , timeoutSeconds = Some 5
                }
              , name = "precise-code-intel-api-server"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 3186
                  , name = Some "server"
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
