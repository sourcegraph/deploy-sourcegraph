let kubernetes = (../../../imports.dhall).Kubernetes

let prelude = (../../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../../config/config.dhall

let util = ../../../util/util.dhall

let render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Postgres.PersistentVolumeClaim

        let annotations = overrides.additionalAnnotations

        let additionalLabels =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                overrides.additionalLabels

        let labels =
                toMap
                  { sourcegraph-resource-requires = "no-cluster-admin"
                  , deploy = "sourcegraph"
                  }
              # additionalLabels

        let persistentVolumeClaim =
              kubernetes.PersistentVolumeClaim::{
              , apiVersion = "v1"
              , kind = "PersistentVolumeClaim"
              , metadata = kubernetes.ObjectMeta::{
                , annotations
                , labels = Some labels
                , namespace = overrides.namespace
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

        in  persistentVolumeClaim

in  render
