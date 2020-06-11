let Frontend/configuration = ../base/frontend/dhall/configuration.dhall

let configuration =
      { Type = { Frontend : Frontend/configuration.Type }
      , default.Frontend = Frontend/configuration.default
      }

in  configuration
