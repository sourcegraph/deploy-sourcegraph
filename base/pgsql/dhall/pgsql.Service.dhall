let kubernetes = (../../../imports.dhall).Kubernetes

let prelude = (../../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../../config/config.dhall

let util = ../../../util/util.dhall

let render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Postgres.Service

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

        let annotations =
                toMap
                  { `sourcegraph.prometheus/scrape` = "true"
                  , `prometheus.io/port` = "9187"
                  }
              # additionalAnnotations

        let labels =
                toMap
                  { sourcegraph-resource-requires = "no-cluster-admin"
                  , deploy = "sourcegraph"
                  }
              # additionalLabels

        let service =
              kubernetes.Service::{
              , apiVersion = "v1"
              , kind = "Service"
              , metadata = kubernetes.ObjectMeta::{
                , annotations = Some annotations
                , labels = Some labels
                , namespace = overrides.namespace
                , name = Some "pgsql"
                }
              , spec = Some kubernetes.ServiceSpec::{
                , ports = Some
                  [ kubernetes.ServicePort::{
                    , name = Some "pgsql"
                    , port = 5432
                    , targetPort = Some (kubernetes.IntOrString.String "pgsql")
                    }
                  ]
                , selector = Some (toMap { app = "pgsql" })
                , type = Some "ClusterIP"
                }
              }

        in  service

in  render
