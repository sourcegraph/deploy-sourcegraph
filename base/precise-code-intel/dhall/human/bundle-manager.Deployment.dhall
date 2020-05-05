let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Deployment::{
    , apiVersion = "apps/v1"
    , kind = "Deployment"
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue = "Stores and manages precise code intelligence bundles."
          }
        ]
      , labels = Some util.deploySourcegraphLabel
      , name = Some "precise-code-intel-bundle-manager"
      }
    , spec = Some kubernetes.DeploymentSpec::{
      , minReadySeconds = Some 10
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some
          [ { mapKey = "app", mapValue = "precise-code-intel-bundle-manager" } ]
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
            [ { mapKey = "app", mapValue = "precise-code-intel-bundle-manager" }
            ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , env = Some
                [ kubernetes.EnvVar::{
                  , name = "PRECISE_CODE_INTEL_API_SERVER_URL"
                  , value = Some "http://precise-code-intel-api-server:3186"
                  }
                , kubernetes.EnvVar::{
                  , name = "LSIF_STORAGE_ROOT"
                  , value = Some "/lsif-storage"
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
                  "index.docker.io/sourcegraph/precise-code-intel-bundle-manager:3.15.1@sha256:73ea3f5995e745be2b1918943e02038ca4528feed848b969d1f5f6376417600a"
              , livenessProbe = Some kubernetes.Probe::{
                , httpGet = Some kubernetes.HTTPGetAction::{
                  , path = Some "/healthz"
                  , port = kubernetes.IntOrString.String "server"
                  , scheme = Some "HTTP"
                  }
                , initialDelaySeconds = Some 60
                , timeoutSeconds = Some 5
                }
              , name = "precise-code-intel-bundle-manager"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 3187
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
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{
                  , mountPath = "/lsif-storage"
                  , name = "bundle-manager"
                  }
                ]
              }
            ]
          , securityContext = Some kubernetes.PodSecurityContext::{
            , runAsUser = Some 0
            }
          , volumes = Some
            [ kubernetes.Volume::{
              , name = "bundle-manager"
              , persistentVolumeClaim = Some
                { claimName = "bundle-manager", readOnly = None Bool }
              }
            ]
          }
        }
      }
    }
