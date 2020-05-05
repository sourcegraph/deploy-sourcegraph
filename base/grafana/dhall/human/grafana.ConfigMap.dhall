let kubernetes = ../../../../util/kubernetes.dhall

let util = ../../../../util/util.dhall

in  kubernetes.ConfigMap::{
    , data = Some
      [ { mapKey = "prometheus.yml", mapValue = ./prometheus.yaml as Text } ]
    , metadata = kubernetes.ObjectMeta::{
      , labels = Some util.deploySourcegraphLabel
      , name = Some "grafana"
      }
    }
