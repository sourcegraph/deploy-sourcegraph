let util = ../../../util/util.dhall

let frontend = ./package.dhall

let kubernetesTypeUnion = util.kubernetesTypeUnion

let frontend = ./package.dhall

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ kubernetesTypeUnion.Deployment frontend.Deployment
      , kubernetesTypeUnion.Ingress frontend.Ingress
      , kubernetesTypeUnion.Role frontend.Role
      , kubernetesTypeUnion.RoleBinding frontend.RoleBinding
      , kubernetesTypeUnion.ServiceAccount frontend.ServiceAccount
      , kubernetesTypeUnion.Service frontend.Service
      , kubernetesTypeUnion.Service frontend.ServiceInternal
      ]
    }
