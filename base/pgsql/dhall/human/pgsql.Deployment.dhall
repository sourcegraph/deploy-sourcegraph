let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Deployment::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue = "Postgres database for various data."
          }
        ]
      , labels = Some util.deploySourcegraphLabel
      , name = Some "pgsql"
      }
    , spec = Some kubernetes.DeploymentSpec::{
      , minReadySeconds = Some 10
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some [ { mapKey = "app", mapValue = "pgsql" } ]
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
            [ { mapKey = "group", mapValue = "backend" }
            , { mapKey = "app", mapValue = "pgsql" }
            ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , image = Some
                  "index.docker.io/sourcegraph/postgres-11.4:3.15.1@sha256:63090799b34b3115a387d96fe2227a37999d432b774a1d9b7966b8c5d81b56ad"
              , livenessProbe = Some kubernetes.Probe::{
                , exec = Some { command = Some [ "/liveness.sh" ] }
                , initialDelaySeconds = Some 15
                }
              , name = "pgsql"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 5432
                  , name = Some "pgsql"
                  }
                ]
              , readinessProbe = Some kubernetes.Probe::{
                , exec = Some { command = Some [ "/ready.sh" ] }
                }
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "2Gi" }
                  , { mapKey = "cpu", mapValue = "4" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "2Gi" }
                  , { mapKey = "cpu", mapValue = "4" }
                  ]
                }
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{ mountPath = "/data", name = "disk" }
                , kubernetes.VolumeMount::{
                  , mountPath = "/conf"
                  , name = "pgsql-conf"
                  }
                ]
              }
            , kubernetes.Container::{
              , env = Some
                [ kubernetes.EnvVar::{
                  , name = "DATA_SOURCE_NAME"
                  , value = Some
                      "postgres://sg:@localhost:5432/?sslmode=disable"
                  }
                ]
              , image = Some
                  "wrouesnel/postgres_exporter:v0.7.0@sha256:785c919627c06f540d515aac88b7966f352403f73e931e70dc2cbf783146a98b"
              , name = "pgsql-exporter"
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "50Mi" }
                  , { mapKey = "cpu", mapValue = "10m" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "50Mi" }
                  , { mapKey = "cpu", mapValue = "10m" }
                  ]
                }
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              }
            ]
          , initContainers = Some
            [ kubernetes.Container::{
              , command = Some
                [ "sh"
                , "-c"
                , "if [ -d /data/pgdata-11 ]; then chmod 750 /data/pgdata-11; fi"
                ]
              , image = Some
                  "sourcegraph/alpine:3.10@sha256:4d05cd5669726fc38823e92320659a6d1ef7879e62268adec5df658a0bacf65c"
              , name = "correct-data-dir-permissions"
              , securityContext = Some kubernetes.SecurityContext::{
                , runAsUser = Some 0
                }
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{ mountPath = "/data", name = "disk" }
                ]
              }
            ]
          , securityContext = Some kubernetes.PodSecurityContext::{
            , runAsUser = Some 0
            }
          , volumes = Some
            [ kubernetes.Volume::{
              , name = "disk"
              , persistentVolumeClaim = Some
                { claimName = "pgsql", readOnly = None Bool }
              }
            , kubernetes.Volume::{
              , configMap = Some kubernetes.ConfigMapVolumeSource::{
                , defaultMode = Some 777
                , name = Some "pgsql-conf"
                }
              , name = "pgsql-conf"
              }
            ]
          }
        }
      }
    }
