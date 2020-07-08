let kubernetes = (../../imports.dhall).Kubernetes

in  { Deployment : kubernetes.Deployment.Type
    , Ingress : kubernetes.Ingress.Type
    , Role : kubernetes.Role.Type
    , RoleBinding : kubernetes.RoleBinding.Type
    , Service : kubernetes.Service.Type
    , ServiceAccount : kubernetes.ServiceAccount.Type
    , ServiceInternal : kubernetes.Service.Type
    }
