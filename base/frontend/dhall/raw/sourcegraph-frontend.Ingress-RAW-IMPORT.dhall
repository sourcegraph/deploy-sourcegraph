{ apiVersion = "networking.k8s.io/v1beta1"
, kind = "Ingress"
, metadata =
  { annotations = Some
    [ { mapKey = "kubernetes.io/ingress.class", mapValue = "nginx" }
    , { mapKey = "nginx.ingress.kubernetes.io/proxy-body-size"
      , mapValue = "150m"
      }
    ]
  , clusterName = None Text
  , creationTimestamp = None Text
  , deletionGracePeriodSeconds = None Natural
  , deletionTimestamp = None Text
  , finalizers = None (List Text)
  , generateName = None Text
  , generation = None Natural
  , labels = Some
    [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
    , { mapKey = "deploy", mapValue = "sourcegraph" }
    ]
  , managedFields =
      None
        ( List
            { apiVersion : Text
            , fieldsType : Optional Text
            , fieldsV1 : Optional (List { mapKey : Text, mapValue : Text })
            , manager : Optional Text
            , operation : Optional Text
            , time : Optional Text
            }
        )
  , name = Some "sourcegraph-frontend"
  , namespace = None Text
  , ownerReferences =
      None
        ( List
            { apiVersion : Text
            , blockOwnerDeletion : Optional Bool
            , controller : Optional Bool
            , kind : Text
            , name : Text
            , uid : Text
            }
        )
  , resourceVersion = None Text
  , selfLink = None Text
  , uid = None Text
  }
, spec = Some
  { backend =
      None
        { serviceName : Text, servicePort : < Int : Natural | String : Text > }
  , rules = Some
    [ { host = None Text
      , http = Some
        { paths =
          [ { backend =
              { serviceName = "sourcegraph-frontend"
              , servicePort = < Int : Natural | String : Text >.Int 30080
              }
            , path = Some "/"
            }
          ]
        }
      }
    ]
  , tls =
      None (List { hosts : Optional (List Text), secretName : Optional Text })
  }
, status =
    None
      { loadBalancer :
          Optional
            { ingress :
                Optional (List { hostname : Optional Text, ip : Optional Text })
            }
      }
}
