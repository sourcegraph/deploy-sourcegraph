let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.PersistentVolumeClaim::{
    , metadata = kubernetes.ObjectMeta::{
      , labels = Some util.deploySourcegraphLabel
      , name = Some "bundle-manager"
      }
    , spec = Some kubernetes.PersistentVolumeClaimSpec::{
      , accessModes = Some [ "ReadWriteOnce" ]
      , resources = Some kubernetes.ResourceRequirements::{
        , requests = Some [ { mapKey = "storage", mapValue = "200Gi" } ]
        }
      , storageClassName = Some "sourcegraph"
      }
    }
