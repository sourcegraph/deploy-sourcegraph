{ apiVersion = "v1"
, kind = "PersistentVolumeClaim"
, metadata =
  { annotations = None (List { mapKey : Text, mapValue : Text })
  , clusterName = None Text
  , creationTimestamp = None Text
  , deletionGracePeriodSeconds = None Natural
  , deletionTimestamp = None Text
  , finalizers = None (List Text)
  , generateName = None Text
  , generation = None Natural
  , labels = Some [ { mapKey = "deploy", mapValue = "sourcegraph" } ]
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
  , name = Some "pgsql"
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
  { accessModes = Some [ "ReadWriteOnce" ]
  , dataSource = None { apiGroup : Optional Text, kind : Text, name : Text }
  , resources = Some
    { limits = None (List { mapKey : Text, mapValue : Text })
    , requests = Some [ { mapKey = "storage", mapValue = "200Gi" } ]
    }
  , selector =
      None
        { matchExpressions :
            Optional
              ( List
                  { key : Text, operator : Text, values : Optional (List Text) }
              )
        , matchLabels : Optional (List { mapKey : Text, mapValue : Text })
        }
  , storageClassName = Some "sourcegraph"
  , volumeMode = None Text
  , volumeName = None Text
  }
, status =
    None
      { accessModes : Optional (List Text)
      , capacity : Optional (List { mapKey : Text, mapValue : Text })
      , conditions :
          Optional
            ( List
                { lastProbeTime : Optional Text
                , lastTransitionTime : Optional Text
                , message : Optional Text
                , reason : Optional Text
                , status : Text
                , type : Text
                }
            )
      , phase : Optional Text
      }
}
