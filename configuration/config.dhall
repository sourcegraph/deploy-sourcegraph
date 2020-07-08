let Frontend/configuration = ../base/frontend/dhall/configuration.dhall

let Gitserver/configuration = ../base/gitserver/dhall/configuration.dhall

let Postgres/configuration = ../base/pgsql/dhall/configuration.dhall


let configuration =   
      { Type =
          { Frontend : Frontend/configuration.Type
          , Gitserver : Gitserver/configuration.Type
          , Postgres : Postgres/configuration.Type
          }
      , default =
        { Frontend = Frontend/configuration.default
        , Gitserver = Gitserver/configuration.default 
        , Postgres = Postgres/configuration.default



        
        }
      }

in  configuration
