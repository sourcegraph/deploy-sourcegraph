let kubernetes = (../../../imports.dhall).Kubernetes

let prelude = (../../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../../config/config.dhall

let util = ../../../util/util.dhall

let gitserverContainer/render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Gitserver.StatefulSet.Containers.Gitserver

        let environment = overrides.additionalEnvironmentVariables

        let image =
              Optional/default
                Text
                "index.docker.io/sourcegraph/gitserver:3.16.1@sha256:1e81230b978a60d91ba2e557fe2e2cb30518d9d043763312db08e52c814aeb2c"
                overrides.image

        let resources =
              Optional/default
                kubernetes.ResourceRequirements.Type
                { limits = Some
                  [ { mapKey = "cpu", mapValue = "4" }
                  , { mapKey = "memory", mapValue = "8G" }
                  ]
                , requests = Some
                  [ { mapKey = "cpu", mapValue = "4" }
                  , { mapKey = "memory", mapValue = "8G" }
                  ]
                }
                overrides.resources

        let container =
              kubernetes.Container::{
              , args = Some [ "run" ]
              , image = Some image
              , env = environment
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
              , resources = Some resources
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{
                  , mountPath = "/data/repos"
                  , name = "repos"
                  }
                ]
              }

        in  container

let render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Gitserver.StatefulSet

        let additionalAnnotations =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                overrides.additionalAnnotations

        let additionalLabels =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                overrides.additionalLabels

        let replicas = Optional/default Natural 1 overrides.replicas

        let gitserverContainer = gitserverContainer/render c

        let statefulSet =
              kubernetes.StatefulSet::{
              , metadata = kubernetes.ObjectMeta::{
                , annotations = Some
                    (   [ { mapKey = "description"
                          , mapValue =
                              "Stores clones of repositories to perform Git operations."
                          }
                        ]
                      # additionalAnnotations
                    )
                , labels = Some
                    (   [ { mapKey = "deploy", mapValue = "sourcegraph" }
                        , { mapKey = "sourcegraph-resource-requires"
                          , mapValue = "no-cluster-admin"
                          }
                        ]
                      # additionalLabels
                    )
                , namespace = overrides.namespace
                , name = Some "gitserver"
                }
              , spec = Some kubernetes.StatefulSetSpec::{
                , replicas = Some replicas
                , revisionHistoryLimit = Some 10
                , selector = kubernetes.LabelSelector::{
                  , matchLabels = Some
                    [ { mapKey = "app", mapValue = "gitserver" } ]
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
                    , containers = [ gitserverContainer, util.jaegerAgent ]
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
                        , requests = Some
                          [ { mapKey = "storage", mapValue = "200Gi" } ]
                        }
                      , storageClassName = Some "sourcegraph"
                      }
                    }
                  ]
                }
              }

        in  statefulSet

in  render
