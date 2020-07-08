let kubernetes = (../../imports.dhall).Kubernetes

let prelude = (../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../configuration/config.dhall

let util = ../../util/util.dhall

let make =
      λ(c : Configuration/global.Type) →
      let overrides  = c.Frontend.Service
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
                    (   [ { mapKey = "prometheus.io/port", mapValue = "6060" }
                        , { mapKey = "sourcegraph.prometheus/scrape"
                          , mapValue = "true"
                          }
                        ]
                      # additionalAnnotations
                    )
                , labels = Some
                    (   [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
                        , { mapKey = "deploy", mapValue = "sourcegraph" }
                        , { mapKey = "sourcegraph-resource-requires"
                          , mapValue = "no-cluster-admin"
                          }
                        ]
                      # additionalLabels
                    )
                , namespace = overrides.namespace
                , name = Some "sourcegraph-frontend"
                }
              , spec = Some kubernetes.ServiceSpec::{
                , ports = Some
                  [ kubernetes.ServicePort::{
                    , name = Some "http"
                    , port = 30080
                    , targetPort = Some (kubernetes.IntOrString.String "http")
                    }
                  ]
                , selector = Some
                  [ { mapKey = "app", mapValue = "sourcegraph-frontend" } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

in  make
