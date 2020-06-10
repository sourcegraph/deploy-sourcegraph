let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in  { default = kubernetes.Deployment::{
      , metadata = kubernetes.ObjectMeta::{
        , annotations = Some
          [ { mapKey = "description"
            , mapValue = "Serves the frontend of Sourcegraph via HTTP(S)."
            }
          ]
        , labels = Some
          [ { mapKey = "deploy", mapValue = "sourcegraph" }
          , { mapKey = "sourcegraph-resource-requires"
            , mapValue = "no-cluster-admin"
            }
          ]
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
              [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
              , { mapKey = "deploy", mapValue = "sourcegraph" }
              ]
            }
          , spec = Some kubernetes.PodSpec::{
            , containers =
              [ kubernetes.Container::{
                , args = Some [ "serve" ]
                , env = Some
                  [ kubernetes.EnvVar::{
                    , name = "PGDATABASE"
                    , value = Some "sg"
                    }
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
                    , name = "JAEGER_SERVER_URL"
                    , value = Some "http://jaeger-query:16686"
                    }
                  , kubernetes.EnvVar::{
                    , name = "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL"
                    , value = Some
                        "http://precise-code-intel-bundle-manager:3187"
                    }
                  , kubernetes.EnvVar::{
                    , name = "PROMETHEUS_URL"
                    , value = Some "http://prometheus:30090"
                    }
                  ]
                , image = Some
                    "index.docker.io/sourcegraph/frontend:3.16.1@sha256:8c144508a7f2a662d95c1831ba4b6542942aa25c0eb2f87abe80ff0a9151cf20"
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
                    [ { mapKey = "cpu", mapValue = "2" }
                    , { mapKey = "memory", mapValue = "4G" }
                    ]
                  , requests = Some
                    [ { mapKey = "cpu", mapValue = "2" }
                    , { mapKey = "memory", mapValue = "2G" }
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
    , Type = kubernetes.Deployment.Type
    }
