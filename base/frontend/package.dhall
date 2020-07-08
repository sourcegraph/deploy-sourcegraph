let Frontend/component = ./component.dhall

let Configuration/global = ../../configuration/config.dhall

let Deployment/render = ./sourcegraph-frontend.Deployment.dhall

let Ingress/render = ./sourcegraph-frontend.Ingress.dhall

let Role/render = ./sourcegraph-frontend.Role.dhall

let RoleBinding/render = ./sourcegraph-frontend.RoleBinding.dhall

let Service/render = ./sourcegraph-frontend.Service.dhall

let ServiceAccount/render = ./sourcegraph-frontend.ServiceAccount.dhall

let ServiceInternal/render = ./sourcegraph-frontend-internal.Service.dhall

let util = ../../../util/util.dhall

let Kubernetes/list = util.kubernetesList

let Kubernetes/typeUnion = (../../../imports.dhall).KubernetesTypeUnion

let component =
      { Deployment : kubernetes.Deployment.Type
      , Ingress : kubernetes.Ingress.Type
      , Role : kubernetes.Role.Type
      , RoleBinding : kubernetes.RoleBinding.Type
      , Service : kubernetes.Service.Type
      , ServiceAccount : kubernetes.ServiceAccount.Type
      , ServiceInternal : kubernetes.Service.Type
      }

let render =
        ( λ(c : Configuration/global.Type) →
            { Deployment = Deployment/render c
            , Ingress = Ingress/render c
            , Role = Role/render c
            , RoleBinding = RoleBinding/render c
            , Service = Service/render c
            , ServiceAccount = ServiceAccount/render c
            , ServiceInternal = ServiceInternal/render c
            }
        )
      : ∀(c : Configuration/global.Type) → Frontend/component

let toList =
        ( λ(c : component) →
            Kubernetes/list::{
            , items =
              [ Kubernetes/typeUnion.Deployment c.Deployment
              , Kubernetes/typeUnion.Ingress c.Ingress
              , Kubernetes/typeUnion.Role c.Role
              , Kubernetes/typeUnion.RoleBinding c.RoleBinding
              , Kubernetes/typeUnion.Service c.Service
              , Kubernetes/typeUnion.ServiceAccount c.ServiceAccount
              , Kubernetes/typeUnion.Service c.ServiceInternal
              ]
            }
        )
      : ∀(c : Frontend/component) → Kubernetes/list.Type

in  { Render = render, ToList = toList }
