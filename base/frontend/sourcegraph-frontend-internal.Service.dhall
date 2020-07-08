let kubernetes = (../../imports.dhall).Kubernetes

let prelude = (../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../configuration/config.dhall

let keyValuePair = (../../util.dhall).keyValuePair

let make =
      λ(c : Configuration/global.Type) →
        let overrides = c.Frontend.ServiceInternal

        let additionalLabels =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                c.Frontend.ServiceInternal.additionalLabels

        let serviceInternal =
              kubernetes.Service::{
              , metadata = kubernetes.ObjectMeta::{
                , annotations = overrides.additionalAnnotations
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
                , name = Some "sourcegraph-frontend-internal"
                }
              , spec = Some kubernetes.ServiceSpec::{
                , ports = Some
                  [ kubernetes.ServicePort::{
                    , name = Some "http-internal"
                    , port = 80
                    , targetPort = Some
                        (kubernetes.IntOrString.String "http-internal")
                    }
                  ]
                , selector = Some
                  [ { mapKey = "app", mapValue = "sourcegraph-frontend" } ]
                , type = Some "ClusterIP"
                }
              }

        in  serviceInternal

in  make
