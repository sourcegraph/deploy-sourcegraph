let kubernetes = (../../../imports.dhall).Kubernetes

let prelude = (../../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../../config/config.dhall

let util = ../../../util/util.dhall

let postgresContainer/render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Postgres.Deployment.Containers.Postgres

        let environment = overrides.additionalEnvironmentVariables

        let image =
              Optional/default
                Text
                "index.docker.io/sourcegraph/postgres-11.4:3.16.1@sha256:63090799b34b3115a387d96fe2227a37999d432b774a1d9b7966b8c5d81b56ad"
                overrides.image

        let resources =
              Optional/default
                kubernetes.ResourceRequirements.Type
                { limits = Some
                  [ { mapKey = "cpu", mapValue = "4" }
                  , { mapKey = "memory", mapValue = "2Gi" }
                  ]
                , requests = Some
                  [ { mapKey = "cpu", mapValue = "4" }
                  , { mapKey = "memory", mapValue = "2Gi" }
                  ]
                }
                overrides.resources

        let container =
              kubernetes.Container::{
              , image = Some image
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
              , env = environment
              , resources = Some resources
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{ mountPath = "/data", name = "disk" }
                , kubernetes.VolumeMount::{
                  , mountPath = "/conf"
                  , name = "pgsql-conf"
                  }
                ]
              }

        in  container

let postgresExporterContainer/render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Postgres.Deployment.Containers.PostgresExporter

        let additionalEnvironmentVariables =
              Optional/default
                (List kubernetes.EnvVar.Type)
                ([] : List kubernetes.EnvVar.Type)
                overrides.additionalEnvironmentVariables

        let environment =
                [ kubernetes.EnvVar::{
                  , name = "DATA_SOURCE_NAME"
                  , value = Some
                      "postgres://sg:@localhost:5432/?sslmode=disable"
                  }
                ]
              # additionalEnvironmentVariables

        let image =
              Optional/default
                Text
                "wrouesnel/postgres_exporter:v0.7.0@sha256:785c919627c06f540d515aac88b7966f352403f73e931e70dc2cbf783146a98b"
                overrides.image

        let resources =
              Optional/default
                kubernetes.ResourceRequirements.Type
                { limits = Some
                  [ { mapKey = "cpu", mapValue = "10m" }
                  , { mapKey = "memory", mapValue = "50Mi" }
                  ]
                , requests = Some
                  [ { mapKey = "cpu", mapValue = "10m" }
                  , { mapKey = "memory", mapValue = "50Mi" }
                  ]
                }
                overrides.resources

        let container =
              kubernetes.Container::{
              , env = Some environment
              , image = Some image
              , name = "pgsql-exporter"
              , resources = Some resources
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              }

        in  container

let initContainer/render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Postgres.Deployment.Containers.Init

        let environment = overrides.additionalEnvironmentVariables

        let image =
              Optional/default
                Text
                "sourcegraph/alpine:3.10@sha256:4d05cd5669726fc38823e92320659a6d1ef7879e62268adec5df658a0bacf65c"
                overrides.image

        let resources = overrides.resources

        let container =
              kubernetes.Container::{
              , command = Some
                [ "sh"
                , "-c"
                , "if [ -d /data/pgdata-11 ]; then chmod 750 /data/pgdata-11; fi"
                ]
              , env = environment
              , image = Some image
              , name = "correct-data-dir-permissions"
              , securityContext = Some kubernetes.SecurityContext::{
                , runAsUser = Some 0
                }
              , resources
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{ mountPath = "/data", name = "disk" }
                ]
              }

        in  container

let render =
      λ(c : Configuration/global.Type) →
        let additionalAnnotations =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                c.Postgres.Deployment.additionalAnnotations

        let additionalLabels =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                c.Postgres.Deployment.additionalLabels

        let postgresContainer = postgresContainer/render c

        let postgresExporterContainer = postgresExporterContainer/render c

        let initContainer = initContainer/render c

        let deployment =
              kubernetes.Deployment::{
              , metadata = kubernetes.ObjectMeta::{
                , annotations = Some
                    (   [ { mapKey = "description"
                          , mapValue = "Postgres database for various data."
                          }
                        ]
                      # additionalAnnotations
                    )
                , labels = Some
                    (   util.deploySourcegraphLabel
                      # [ { mapKey = "sourcegraph-resource-requires"
                          , mapValue = "no-cluster-admin"
                          }
                        ]
                      # additionalLabels
                    )
                , namespace = c.Postgres.Deployment.namespace
                , name = Some "pgsql"
                }
              , spec = Some kubernetes.DeploymentSpec::{
                , minReadySeconds = Some 10
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector = kubernetes.LabelSelector::{
                  , matchLabels = Some
                    [ { mapKey = "app", mapValue = "pgsql" } ]
                  }
                , strategy = Some kubernetes.DeploymentStrategy::{
                  , type = Some "Recreate"
                  }
                , template = kubernetes.PodTemplateSpec::{
                  , metadata = kubernetes.ObjectMeta::{
                    , labels = Some
                      [ { mapKey = "app", mapValue = "pgsql" }
                      , { mapKey = "deploy", mapValue = "sourcegraph" }
                      , { mapKey = "group", mapValue = "backend" }
                      ]
                    }
                  , spec = Some kubernetes.PodSpec::{
                    , containers =
                      [ postgresContainer, postgresExporterContainer ]
                    , initContainers = Some [ initContainer ]
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

        in  deployment

in  render
