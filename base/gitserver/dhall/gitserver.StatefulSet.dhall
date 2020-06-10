let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in  kubernetes.StatefulSet::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue =
              "Stores clones of repositories to perform Git operations."
          }
        ]
      , labels = Some
        [ { mapKey = "deploy", mapValue = "sourcegraph" }
        , { mapKey = "sourcegraph-resource-requires"
          , mapValue = "no-cluster-admin"
          }
        ]
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
            [ { mapKey = "app", mapValue = "gitserver" }
            , { mapKey = "deploy", mapValue = "sourcegraph" }
            , { mapKey = "group", mapValue = "backend" }
            , { mapKey = "type", mapValue = "gitserver" }
            ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , args = Some [ "run" ]
              , image = Some
                  "index.docker.io/sourcegraph/gitserver:3.16.1@sha256:1e81230b978a60d91ba2e557fe2e2cb30518d9d043763312db08e52c814aeb2c"
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
                  [ { mapKey = "cpu", mapValue = "4" }
                  , { mapKey = "memory", mapValue = "8G" }
                  ]
                , requests = Some
                  [ { mapKey = "cpu", mapValue = "4" }
                  , { mapKey = "memory", mapValue = "8G" }
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
