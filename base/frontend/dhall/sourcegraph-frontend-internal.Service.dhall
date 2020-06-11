let kubernetes = (../../../imports.dhall).Kubernetes

let prelude = (../../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../../config/config.dhall

let util = ../../../util/util.dhall

let render =
      λ(c : Configuration/global.Type) →
        let additionalLabels =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                c.Frontend.ServiceInternal.additionalLabels

        let serviceInternal =
              kubernetes.Service::{
              , metadata = kubernetes.ObjectMeta::{
                , annotations = c.Frontend.ServiceInternal.additionalAnnotations
                , labels = Some
                    (   [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
                        , { mapKey = "deploy", mapValue = "sourcegraph" }
                        , { mapKey = "sourcegraph-resource-requires"
                          , mapValue = "no-cluster-admin"
                          }
                        ]
                      # additionalLabels
                    )
                , namespace = c.Frontend.ServiceInternal.namespace
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

in  render
