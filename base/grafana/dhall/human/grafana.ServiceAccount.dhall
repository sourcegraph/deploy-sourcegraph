{ apiVersion = "v1"
, automountServiceAccountToken = None Bool
, imagePullSecrets = Some [ { name = Some "docker-registry" } ]
, kind = "ServiceAccount"
, metadata =
  { annotations = None (List { mapKey : Text, mapValue : Text })
  , clusterName = None Text
  , creationTimestamp = None Text
  , deletionGracePeriodSeconds = None Natural
  , deletionTimestamp = None Text
  , finalizers = None (List Text)
  , generateName = None Text
  , generation = None Natural
  , labels = Some
      ( toMap
          { sourcegraph-resource-requires = "no-cluster-admin"
          , category = "rbac"
          , deploy = "sourcegraph"
          }
      )
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
  , name = Some "grafana"
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
, secrets =
    None
      ( List
          { apiVersion : Text
          , fieldPath : Optional Text
          , kind : Text
          , name : Optional Text
          , namespace : Optional Text
          , resourceVersion : Optional Text
          , uid : Optional Text
          }
      )
}
