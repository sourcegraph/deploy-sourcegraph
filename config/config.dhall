let Frontend/configuration = ../base/frontend/dhall/configuration.dhall

let Gitserver/configuration = ../base/gitserver/dhall/configuration.dhall

let configuration =
      { Type =
          { Frontend : Frontend/configuration.Type
          , Gitserver : Gitserver/configuration.Type
          }
      , default =
        { Frontend = Frontend/configuration.default
        , Gitserver = Gitserver/configuration.default
        }
      }

in  configuration
