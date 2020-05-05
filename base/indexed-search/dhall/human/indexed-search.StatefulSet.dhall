let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.StatefulSet::{
    , metadata = kubernetes.ObjectMeta::{
      , annotations = Some
        [ { mapKey = "description"
          , mapValue = "Backend for indexed text search operations."
          }
        ]
      , labels = Some util.deploySourcegraphLabel
      , name = Some "indexed-search"
      }
    , spec = Some kubernetes.StatefulSetSpec::{
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some [ { mapKey = "app", mapValue = "indexed-search" } ]
        }
      , serviceName = "indexed-search"
      , template = kubernetes.PodTemplateSpec::{
        , metadata = kubernetes.ObjectMeta::{
          , labels = Some [ { mapKey = "app", mapValue = "indexed-search" } ]
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , image = Some
                  "index.docker.io/sourcegraph/indexed-searcher:3.15.1@sha256:d48de388d28899fd0c3ad0d6f84d466b3a1f533f6b967a713918d438ab8bc63c"
              , name = "zoekt-webserver"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 6070
                  , name = Some "http"
                  }
                ]
              , readinessProbe = Some kubernetes.Probe::{
                , failureThreshold = Some 1
                , httpGet = Some kubernetes.HTTPGetAction::{
                  , path = Some "/healthz"
                  , port = kubernetes.IntOrString.String "http"
                  , scheme = Some "HTTP"
                  }
                , periodSeconds = Some 1
                }
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "4G" }
                  , { mapKey = "cpu", mapValue = "2" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "2G" }
                  , { mapKey = "cpu", mapValue = "500m" }
                  ]
                }
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{ mountPath = "/data", name = "data" }
                ]
              }
            , kubernetes.Container::{
              , image = Some
                  "index.docker.io/sourcegraph/search-indexer:3.15.1@sha256:354ed968e62a7d011b647476a63116813aea23bdada0a2fc4322df5381acb6b3"
              , name = "zoekt-indexserver"
              , ports = Some
                [ kubernetes.ContainerPort::{
                  , containerPort = 6072
                  , name = Some "index-http"
                  }
                ]
              , resources = Some
                { limits = Some
                  [ { mapKey = "memory", mapValue = "8G" }
                  , { mapKey = "cpu", mapValue = "8" }
                  ]
                , requests = Some
                  [ { mapKey = "memory", mapValue = "4G" }
                  , { mapKey = "cpu", mapValue = "4" }
                  ]
                }
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{ mountPath = "/data", name = "data" }
                ]
              }
            ]
          , securityContext = Some kubernetes.PodSecurityContext::{
            , runAsUser = Some 0
            }
          , volumes = Some [ kubernetes.Volume::{ name = "data" } ]
          }
        }
      , updateStrategy = Some kubernetes.StatefulSetUpdateStrategy::{
        , type = Some "RollingUpdate"
        }
      , volumeClaimTemplates = Some
        [ kubernetes.PersistentVolumeClaim::{
          , metadata = kubernetes.ObjectMeta::{
            , labels = Some util.deploySourcegraphLabel
            , name = Some "data"
            }
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
