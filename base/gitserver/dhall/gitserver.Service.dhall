let kubernetes = (../../../imports.dhall).Kubernetes

let prelude = (../../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../../config/config.dhall

let util = ../../../util/util.dhall

let render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Gitserver.Service

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

        let service =
              kubernetes.Service::{
              , metadata = kubernetes.ObjectMeta::{
                , annotations = Some
                    (   toMap
                          { `sourcegraph.prometheus/scrape` = "true"
                          , `prometheus.io/port` = "6060"
                          , description =
                              "Headless service that provides a stable network identity for the gitserver stateful set."
                          }
                      # additionalAnnotations
                    )
                , labels = Some
                    (   toMap
                          { sourcegraph-resource-requires = "no-cluster-admin"
                          , app = "gitserver"
                          , type = "gitserver"
                          , deploy = "sourcegraph"
                          }
                      # additionalLabels
                    )
                , namespace = overrides.namespace
                , name = Some "gitserver"
                }
              , spec = Some kubernetes.ServiceSpec::{
                , clusterIP = Some "None"
                , ports = Some
                  [ kubernetes.ServicePort::{
                    , name = Some "unused"
                    , port = 10811
                    , targetPort = Some (kubernetes.IntOrString.Int 10811)
                    }
                  ]
                , selector = Some
                  [ { mapKey = "app", mapValue = "gitserver" }
                  , { mapKey = "type", mapValue = "gitserver" }
                  ]
                , type = Some "ClusterIP"
                }
              }

        in  service

in  render
