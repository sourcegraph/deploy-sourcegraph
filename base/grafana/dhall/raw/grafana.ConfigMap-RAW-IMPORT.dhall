{ apiVersion = "v1"
, binaryData = None (List { mapKey : Text, mapValue : Text })
, data = Some
  [ { mapKey = "prometheus.yml"
    , mapValue =
        ''
        apiVersion: 1

        datasources:
          - name: Prometheus
            type: prometheus
            access: proxy
            url: http://prometheus:30090
            isDefault: true
            editable: false
        ''
    }
  ]
, kind = "ConfigMap"
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
}
