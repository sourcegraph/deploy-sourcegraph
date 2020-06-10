let util = ../../../util/util.dhall

let kubernetesTypeUnion = util.kubernetesTypeUnion

let gitserver = ./package.dhall

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ kubernetesTypeUnion.StatefulSet gitserver.StatefulSet
      , kubernetesTypeUnion.Service gitserver.Service
      ]
    }
