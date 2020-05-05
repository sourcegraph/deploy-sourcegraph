let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/fc275e649b48c5e6badcff25f377d03baf1ee5d0/package.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Deployment::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue = "Serves the frontend of Sourcegraph via HTTP(S)."
          }
        ]
      , labels = Some [ { mapKey = "deploy", mapValue = "sourcegraph" } ]
      , name = Some "sourcegraph-frontend"
      }
    , spec = Some kubernetes.DeploymentSpec::{
      , minReadySeconds = Some 10
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some
          [ { mapKey = "app", mapValue = "sourcegraph-frontend" } ]
        }
      , strategy = Some kubernetes.DeploymentStrategy::{
        , rollingUpdate = Some
          { maxSurge = Some (kubernetes.IntOrString.Int 2)
          , maxUnavailable = Some (kubernetes.IntOrString.Int 0)
          }
        , type = Some "RollingUpdate"
        }
      , template = kubernetes.PodTemplateSpec::{
        , metadata = kubernetes.ObjectMeta::{
          , labels = Some
            [ { mapKey = "app", mapValue = "sourcegraph-frontend" } ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , args = Some [ "serve" ]
              , env = Some
                [ kubernetes.EnvVar::{ name = "PGDATABASE", value = Some "sg" }
                , kubernetes.EnvVar::{ name = "PGHOST", value = Some "pgsql" }
                , kubernetes.EnvVar::{ name = "PGPORT", value = Some "5432" }
                , kubernetes.EnvVar::{
                  , name = "PGSSLMODE"
                  , value = Some "disable"
                  }
                , kubernetes.EnvVar::{ name = "PGUSER", value = Some "sg" }
                , kubernetes.EnvVar::{
                  , name = "SRC_GIT_SERVERS"
                  , value = Some "gitserver-0.gitserver:3178"
                  }
                , kubernetes.EnvVar::{
                  , name = "POD_NAME"
                  , valueFrom = Some kubernetes.EnvVarSource::{
                    , fieldRef = Some
                      { apiVersion = None Text, fieldPath = "metadata.name" }
                    }
                  }
                , kubernetes.EnvVar::{
                  , name = "CACHE_DIR"
                  , value = Some "/mnt/cache/\$(POD_NAME)"
                  }
                , kubernetes.EnvVar::{
                  , name = "GRAFANA_SERVER_URL"
                  , value = Some "http://grafana:30070"
                  }
                , kubernetes.EnvVar::{
                  , name = "LSIF_API_SERVER_URL"
                  , value = Some "k8s+http://precise-code-intel-api-server:3186"
                  }
                , kubernetes.EnvVar::{
                  , name = "PRECISE_CODE_INTEL_API_SERVER_URL"
                  , value = Some "k8s+http://precise-code-intel-api-server:3186"
                  }
                ]
              , image = Some
                  "index.docker.io/sourcegraph/frontend:3.15.1@sha256:d6a2253ef0f1b40acb5a6dab7ea785302214c47ae27c4738ad1f9d67f8453ff8"
              , livenessProbe = Some kubernetes.Probe::{
                , httpGet = Some kubernetes.HTTPGetAction::{
                  , path = Some "/healthz"
                  , port = kubernetes.IntOrString.String "http"
                  , scheme = Some "HTTP"
                  }
                , initialDelaySeconds = Some 300
                , timeoutSeconds = Some 5
                }
              , name = "frontend"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 3080
                  , name = Some "http"
                  }
                , kubernetes.ContainerPort::{
                  , containerPort = 3090
                  , name = Some "http-internal"
                  }
                ]
              , readinessProbe = Some kubernetes.Probe::{
                , httpGet = Some kubernetes.HTTPGetAction::{
                  , path = Some "/healthz"
                  , port = kubernetes.IntOrString.String "http"
                  , scheme = Some "HTTP"
                  }
                , periodSeconds = Some 5
                , timeoutSeconds = Some 5
                }
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "4G" }
                  , { mapKey = "cpu", mapValue = "2" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "2G" }
                  , { mapKey = "cpu", mapValue = "2" }
                  ]
                }
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{
                  , mountPath = "/mnt/cache"
                  , name = "cache-ssd"
                  }
                ]
              }
            , util.jaegerAgent
            ]
          , securityContext = Some kubernetes.PodSecurityContext::{
            , runAsUser = Some 0
            }
          , serviceAccountName = Some "sourcegraph-frontend"
          , volumes = Some [ util.emptyCacheSSDVolume ]
          }
        }
      }
    }
