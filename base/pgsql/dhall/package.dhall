let kubernetes = (../../../imports.dhall).Kubernetes

let Configuration/global = ../../../config/config.dhall

let ConfigMap/render = ./pgsql.ConfigMap.dhall

let Deployment/render = ./pgsql.Deployment.dhall

let PersistentVolumeClaim/render = ./pgsql.PersistentVolumeClaim.dhall

let Service/render = ./pgsql.Service.dhall

let util = ../../../util/util.dhall

let Kubernetes/list = util.kubernetesList

let Kubernetes/typeUnion = (../../../imports.dhall).KubernetesTypeUnion

let component =
      { ConfigMap : kubernetes.ConfigMap.Type
      , Deployment : kubernetes.Deployment.Type
      , PersistentVolumeClaim : kubernetes.PersistentVolumeClaim.Type 
      , Service : kubernetes.Service.Type
      }

let render =
        ( λ(c : Configuration/global.Type) →
            { Deployment = Deployment/render c
            , Service = Service/render c
            , PersistentVolumeClaim = PersistentVolumeClaim/render c
            , ConfigMap = ConfigMap/render c
            }
        )
      : ∀(c : Configuration/global.Type) → component

let toList =
        ( λ(c : component) →
            Kubernetes/list::{
            , items =
              [ Kubernetes/typeUnion.Deployment c.Deployment
              , Kubernetes/typeUnion.Service c.Service
              , Kubernetes/typeUnion.PersistentVolumeClaim
                  c.PersistentVolumeClaim
              , Kubernetes/typeUnion.ConfigMap c.ConfigMap
              ]
            }
        )
      : ∀(c : component) → Kubernetes/list.Type

in  { Render = render, ToList = toList }
