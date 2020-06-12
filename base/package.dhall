let List/concatMap = (../imports.dhall).Prelude.List.concatMap

let Postgres/render = (./pgsql/dhall/package.dhall).Render

let Postgres/toList = (./pgsql/dhall/package.dhall).ToList

let Gitserver/render = (./gitserver/dhall/package.dhall).Render

let Gitserver/toList = (./gitserver/dhall/package.dhall).ToList

let Frontend/render = (./frontend/dhall/package.dhall).Render

let Frontend/toList = (./frontend/dhall/package.dhall).ToList

let Configure/global = ../config/config.dhall

let Kubernetes/list = (../util/util.dhall).kubernetesList

let Kubernetes/typeUnion = (../util/util.dhall).kubernetesTypeUnion

let toList =
      λ(c : Configure/global.Type) →
        let allResourceLists =
              [ Postgres/toList (Postgres/render c)
              , Gitserver/toList (Gitserver/render c)
              , Frontend/toList (Frontend/render c)
              ]

        in  Kubernetes/list::{
            , items =
                List/concatMap
                  Kubernetes/list.Type
                  Kubernetes/typeUnion
                  (λ(x : Kubernetes/list.Type) → x.items)
                  allResourceLists
            }

in  toList
