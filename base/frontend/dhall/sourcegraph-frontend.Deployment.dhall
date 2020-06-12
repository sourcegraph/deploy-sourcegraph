let kubernetes = (../../../imports.dhall).Kubernetes

let prelude = (../../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Natural/enumerate = prelude.Natural.enumerate

let Text/concatMapSep = prelude.Text.concatMapSep

let Configuration/global = ../../../config/config.dhall

let util = ../../../util/util.dhall

let makeGitserverEnvVar =
      λ(replicas : Natural) →
        let indicies = Natural/enumerate replicas

        let makeEndpoint = λ(i : Natural) → "gitserver-${Natural/show i}:3178"

        in  Text/concatMapSep "," Natural makeEndpoint indicies

let frontendContainer/render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Frontend.Deployment.Containers.SourcegraphFrontend

        let additionalEnvironmentVariables =
              Optional/default
                (List kubernetes.EnvVar.Type)
                ([] : List kubernetes.EnvVar.Type)
                overrides.additionalEnvironmentVariables

        let gitserverReplicas =
              Optional/default Natural 1 c.Gitserver.StatefulSet.replicas

        let environment =
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
                  , value = Some (makeGitserverEnvVar gitserverReplicas)
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
                  , value = Some "http://precise-code-intel-bundle-manager:3187"
                  }
                , kubernetes.EnvVar::{
                  , name = "PROMETHEUS_URL"
                  , value = Some "http://prometheus:30090"
                  }
                ]
              # additionalEnvironmentVariables

        let resources =
              Optional/default
                kubernetes.ResourceRequirements.Type
                { limits = Some
                  [ { mapKey = "cpu", mapValue = "2" }
                  , { mapKey = "memory", mapValue = "4G" }
                  ]
                , requests = Some
                  [ { mapKey = "cpu", mapValue = "2" }
                  , { mapKey = "memory", mapValue = "2G" }
                  ]
                }
                overrides.resources

        let image =
              Optional/default
                Text
                "index.docker.io/sourcegraph/frontend:3.16.1@sha256:8c144508a7f2a662d95c1831ba4b6542942aa25c0eb2f87abe80ff0a9151cf20"
                overrides.image

        let container =
              kubernetes.Container::{
              , args = Some [ "serve" ]
              , env = Some environment
              , image = Some image
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
              , resources = Some resources
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{
                  , mountPath = "/mnt/cache"
                  , name = "cache-ssd"
                  }
                ]
              }

        in  container

let render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Frontend.Deployment

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

        let frontendContainer = frontendContainer/render c

        let deployment =
              kubernetes.Deployment::{
              , metadata = kubernetes.ObjectMeta::{
                , annotations = Some
                    (   [ { mapKey = "description"
                          , mapValue =
                              "Serves the frontend of Sourcegraph via HTTP(S)."
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
                , name = Some "sourcegraph-frontend"
                }
              , spec = Some kubernetes.DeploymentSpec::{
                , minReadySeconds = Some 10
                , replicas = Some replicas
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
                    , containers = [ frontendContainer, util.jaegerAgent ]
                    , securityContext = Some kubernetes.PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    , serviceAccountName = Some "sourcegraph-frontend"
                    , volumes = Some [ util.emptyCacheSSDVolume ]
                    }
                  }
                }
              }

        in  deployment

in  render
