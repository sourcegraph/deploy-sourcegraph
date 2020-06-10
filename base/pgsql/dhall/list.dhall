let util = ../../../util/util.dhall

let kubernetesTypeUnion = util.kubernetesTypeUnion

let pgsql = ./package.dhall

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ kubernetesTypeUnion.ConfigMap pgsql.ConfigMap
      , kubernetesTypeUnion.Deployment pgsql.Deployment 
      , kubernetesTypeUnion.PersistentVolumeClaim pgsql.PersistentVolumeClaim
      , kubernetesTypeUnion.Service pgsql.Service
      ]
    }
