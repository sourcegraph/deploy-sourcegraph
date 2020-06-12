let kubernetes = (../../../imports.dhall).Kubernetes

let Configuration/global = ../../../config/config.dhall

let StatefulSet/render = ./gitserver.Statefulset.dhall

let Service/render = ./gitserver.Service.dhall

let util = ../../../util/util.dhall

let Kubernetes/list = util.kubernetesList

let Kubernetes/typeUnion = (../../../imports.dhall).KubernetesTypeUnion

let component =
      { StatefulSet : kubernetes.StatefulSet.Type
      , Service : kubernetes.Service.Type
      }

let render =
        ( λ(c : Configuration/global.Type) →
            { StatefulSet = StatefulSet/render c, Service = Service/render c }
        )
      : ∀(c : Configuration/global.Type) → component

let toList =
        ( λ(c : component) →
            Kubernetes/list::{
            , items =
              [ Kubernetes/typeUnion.StatefulSet c.StatefulSet
              , Kubernetes/typeUnion.Service c.Service
              ]
            }
        )
      : ∀(c : component) → Kubernetes/list.Type

in  { Render = render, ToList = toList }
