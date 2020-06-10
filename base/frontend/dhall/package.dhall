{ Deployment = ./sourcegraph-frontend.Deployment.dhall
, Ingress = ./sourcegraph-frontend.Ingress.dhall
, Role = ./sourcegraph-frontend.Role.dhall
, RoleBinding = ./sourcegraph-frontend.RoleBinding.dhall
, Service = ./sourcegraph-frontend.Service.dhall
, ServiceAccount = ./sourcegraph-frontend.ServiceAccount.dhall
, ServiceInternal = ./sourcegraph-frontend-internal.Service.dhall
}
