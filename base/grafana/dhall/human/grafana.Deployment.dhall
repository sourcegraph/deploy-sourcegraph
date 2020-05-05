let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.Deployment::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue = "Metrics/monitoring dashboards and alerts."
          }
        ]
      , labels = Some util.deploySourcegraphLabel
      , name = Some "grafana"
      }
    , spec = Some kubernetes.DeploymentSpec::{
      , minReadySeconds = Some 10
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some [ { mapKey = "app", mapValue = "grafana" } ]
        }
      , strategy = Some
        { rollingUpdate = Some
          { maxSurge = Some (kubernetes.IntOrString.Int 1)
          , maxUnavailable = Some (kubernetes.IntOrString.Int 1)
          }
        , type = Some "RollingUpdate"
        }
      , template = kubernetes.PodTemplateSpec::{
        , metadata = kubernetes.ObjectMeta::{
          , labels = Some [ { mapKey = "app", mapValue = "grafana" } ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , image = Some
                  "index.docker.io/sourcegraph/grafana:3.15.0@sha256:94ef3e7673d12e92487ca8966ab74b456f685edfc54fb163e1d49c7eaf064e70"
              , name = "grafana"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 3370
                  , name = Some "http"
                  }
                ]
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "512Mi" }
                  , { mapKey = "cpu", mapValue = "1" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "512Mi" }
                  , { mapKey = "cpu", mapValue = "100m" }
                  ]
                }
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{
                  , mountPath = "/var/lib/grafana"
                  , name = "data"
                  }
                , kubernetes.VolumeMount::{
                  , mountPath = "/sg_config_grafana/provisioning/datasources"
                  , name = "config"
                  }
                ]
              }
            ]
          , securityContext = Some kubernetes.PodSecurityContext::{
            , runAsUser = Some 0
            }
          , serviceAccountName = Some "grafana"
          , volumes = Some
            [ kubernetes.Volume::{
              , name = "data"
              , persistentVolumeClaim = Some
                { claimName = "grafana", readOnly = None Bool }
              }
            , kubernetes.Volume::{
              , configMap = Some kubernetes.ConfigMapVolumeSource::{
                , defaultMode = Some 777
                , name = Some "grafana"
                }
              , name = "config"
              }
            ]
          }
        }
      }
    }
