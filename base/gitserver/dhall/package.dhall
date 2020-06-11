let Configuration/global = ../../../config/config.dhall

let StatefulSet/render = ./gitserver.Statefulset.dhall

let Service/render = ./gitserver.Service.dhall

let render =
      λ(c : Configuration/global.Type) →
        { StatefulSet = StatefulSet/render c, Service = Service/render c }

in  render
