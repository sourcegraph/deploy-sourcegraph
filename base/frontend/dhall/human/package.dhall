{ Service = ./sourcegraph-frontend.Service.dhall
, ServiceAccount = ./sourcegraph-frontend.ServiceAccount.dhall
, ServiceInternal = ./sourcegraph-frontend-internal.Service.dhall
, RoleBinding = ./sourcegraph-frontend.RoleBinding.dhall
, Role = ./sourcegraph-frontend.Role.dhall
, Ingress = ./sourcegraph-frontend.Ingress.dhall
, Deployment = ./sourcegraph-frontend.Deployment.dhall
}
