let Configuration/global = ../../../config/config.dhall

let Deployment/render = ./sourcegraph-frontend.Deployment.dhall

let Ingress/render = ./sourcegraph-frontend.Ingress.dhall

let Role/render = ./sourcegraph-frontend.Role.dhall

let RoleBinding/render = ./sourcegraph-frontend.RoleBinding.dhall

let Service/render = ./sourcegraph-frontend.Service.dhall

let ServiceAccount/render = ./sourcegraph-frontend.ServiceAccount.dhall

let ServiceInternal/render = ./sourcegraph-frontend-internal.Service.dhall

let render =
      λ(c : Configuration/global.Type) →
        { Deployment = Deployment/render c
        , Ingress = Ingress/render c
        , Role = Role/render c
        , RoleBinding = RoleBinding/render c
        , Service = Service/render c
        , ServiceAccount = ServiceAccount/render c
        , ServiceInternal = ServiceInternal/render c
        }

in  render
