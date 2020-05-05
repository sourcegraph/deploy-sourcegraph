{ apiVersion = "v1"
, kind = "Service"
, metadata =
  { annotations = Some
    [ { mapKey = "prometheus.io/port", mapValue = "9090" }
    , { mapKey = "sourcegraph.prometheus/federate", mapValue = "true" }
    ]
  , clusterName = None Text
  , creationTimestamp = None Text
  , deletionGracePeriodSeconds = None Natural
  , deletionTimestamp = None Text
  , finalizers = None (List Text)
  , generateName = None Text
  , generation = None Natural
  , labels = Some
    [ { mapKey = "app", mapValue = "precise-code-intel-worker" }
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
  , name = Some "precise-code-intel-worker"
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
  { clusterIP = None Text
  , externalIPs = None (List Text)
  , externalName = None Text
  , externalTrafficPolicy = None Text
  , healthCheckNodePort = None Natural
  , ipFamily = None Text
  , loadBalancerIP = None Text
  , loadBalancerSourceRanges = None (List Text)
  , ports = Some
    [ { name = Some "server"
      , nodePort = None Natural
      , port = 3188
      , protocol = None Text
      , targetPort = Some (< Int : Natural | String : Text >.String "server")
      }
    , { name = Some "prometheus"
      , nodePort = None Natural
      , port = 9090
      , protocol = None Text
      , targetPort = Some
          (< Int : Natural | String : Text >.String "prometheus")
      }
    ]
  , publishNotReadyAddresses = None Bool
  , selector = Some
    [ { mapKey = "app", mapValue = "precise-code-intel-worker" } ]
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
