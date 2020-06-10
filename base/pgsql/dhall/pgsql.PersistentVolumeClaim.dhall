let util = ../../../util/util.dhall

let kubernetes = util.kubernetes

in  kubernetes.PersistentVolumeClaim::{
    , apiVersion = "v1"
    , kind = "PersistentVolumeClaim"
    , metadata = kubernetes.ObjectMeta::{
      , labels = Some
          ( toMap
              { sourcegraph-resource-requires = "no-cluster-admin"
              , deploy = "sourcegraph"
              }
          )
      , name = Some "pgsql"
      }
    , spec = Some kubernetes.PersistentVolumeClaimSpec::{
      , accessModes = Some [ "ReadWriteOnce" ]
      , resources = Some kubernetes.ResourceRequirements::{
        , requests = Some (toMap { storage = "200Gi" })
        }
      , storageClassName = Some "sourcegraph"
      }
    }
