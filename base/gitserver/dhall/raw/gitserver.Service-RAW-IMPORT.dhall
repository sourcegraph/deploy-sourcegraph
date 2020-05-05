{ apiVersion = "v1"
, kind = "Service"
, metadata =
  { annotations = Some
    [ { mapKey = "sourcegraph.prometheus/scrape", mapValue = "true" }
    , { mapKey = "prometheus.io/port", mapValue = "6060" }
    , { mapKey = "description"
      , mapValue =
          "Headless service that provides a stable network identity for the gitserver stateful set."
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
    [ { mapKey = "app", mapValue = "gitserver" }
    , { mapKey = "type", mapValue = "gitserver" }
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
  , name = Some "gitserver"
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
  { clusterIP = Some "None"
  , externalIPs = None (List Text)
  , externalName = None Text
  , externalTrafficPolicy = None Text
  , healthCheckNodePort = None Natural
  , ipFamily = None Text
  , loadBalancerIP = None Text
  , loadBalancerSourceRanges = None (List Text)
  , ports = Some
    [ { name = Some "unused"
      , nodePort = None Natural
      , port = 10811
      , protocol = None Text
      , targetPort = Some (< Int : Natural | String : Text >.Int 10811)
      }
    ]
  , publishNotReadyAddresses = None Bool
  , selector = Some
    [ { mapKey = "app", mapValue = "gitserver" }
    , { mapKey = "type", mapValue = "gitserver" }
    ]
  , sessionAffinity = None Text
  , sessionAffinityConfig =
      None { clientIP : Optional { timeoutSeconds : Optional Natural } }
  , topologyKeys = None (List Text)
  , type = Some "ClusterIP"
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
