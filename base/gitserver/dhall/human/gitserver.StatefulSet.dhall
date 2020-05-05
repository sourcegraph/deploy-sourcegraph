let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.StatefulSet::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue =
              "Stores clones of repositories to perform Git operations."
          }
        ]
      , labels = Some [ { mapKey = "deploy", mapValue = "sourcegraph" } ]
      , name = Some "gitserver"
      }
    , spec = Some kubernetes.StatefulSetSpec::{
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some [ { mapKey = "app", mapValue = "gitserver" } ]
        }
      , serviceName = "gitserver"
      , template = kubernetes.PodTemplateSpec::{
        , metadata = kubernetes.ObjectMeta::{
          , labels = Some
            [ { mapKey = "group", mapValue = "backend" }
            , { mapKey = "app", mapValue = "gitserver" }
            , { mapKey = "type", mapValue = "gitserver" }
            ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , args = Some [ "run" ]
              , image = Some
                  "index.docker.io/sourcegraph/gitserver:3.15.1@sha256:d2e5c67a5005342421326e22ed1d8a8d4e9699e75d294860f3c7ea209528a8f3"
              , livenessProbe = Some kubernetes.Probe::{
                , initialDelaySeconds = Some 5
                , tcpSocket = Some kubernetes.TCPSocketAction::{
                  , port = kubernetes.IntOrString.String "rpc"
                  }
                , timeoutSeconds = Some 5
                }
              , name = "gitserver"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 3178
                  , name = Some "rpc"
                  }
                ]
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "8G" }
                  , { mapKey = "cpu", mapValue = "4" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "8G" }
                  , { mapKey = "cpu", mapValue = "4" }
                  ]
                }
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{
                  , mountPath = "/data/repos"
                  , name = "repos"
                  }
                ]
              }
            , util.jaegerAgent
            ]
          , schedulerName = None Text
          , securityContext = Some kubernetes.PodSecurityContext::{
            , runAsUser = Some 0
            }
          , volumes = Some [ kubernetes.Volume::{ name = "repos" } ]
          }
        }
      , updateStrategy = Some
        { rollingUpdate = None { partition : Optional Natural }
        , type = Some "RollingUpdate"
        }
      , volumeClaimTemplates = Some
        [ kubernetes.PersistentVolumeClaim::{
          , metadata = kubernetes.ObjectMeta::{ name = Some "repos" }
          , spec = Some kubernetes.PersistentVolumeClaimSpec::{
            , accessModes = Some [ "ReadWriteOnce" ]
            , resources = Some kubernetes.ResourceRequirements::{
              , requests = Some [ { mapKey = "storage", mapValue = "200Gi" } ]
              }
            , storageClassName = Some "sourcegraph"
            }
          }
        ]
      }
    }
