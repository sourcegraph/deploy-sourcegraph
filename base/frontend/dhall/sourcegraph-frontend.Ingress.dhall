let kubernetes = (../../../imports.dhall).Kubernetes

let prelude = (../../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../../config/config.dhall

let util = ../../../util/util.dhall

let render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Frontend.Ingress

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

        let ingress =
              kubernetes.Ingress::{
              , metadata = kubernetes.ObjectMeta::{
                , annotations = Some
                    (   [ { mapKey = "kubernetes.io/ingress.class"
                          , mapValue = "nginx"
                          }
                        , { mapKey =
                              "nginx.ingress.kubernetes.io/proxy-body-size"
                          , mapValue = "150m"
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
              , spec = Some kubernetes.IngressSpec::{
                , rules = Some
                  [ kubernetes.IngressRule::{
                    , http = Some kubernetes.HTTPIngressRuleValue::{
                      , paths =
                        [ kubernetes.HTTPIngressPath::{
                          , backend =
                            { serviceName = "sourcegraph-frontend"
                            , servicePort = kubernetes.IntOrString.Int 30080
                            }
                          , path = Some "/"
                          }
                        ]
                      }
                    }
                  ]
                }
              }

        in  ingress

in  render
