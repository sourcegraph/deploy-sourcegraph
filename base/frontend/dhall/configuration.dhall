let Configuration/universal = ../../../config/universal.dhall

let Configuration/deployment = ../../../config/resource/deployment.dhall

let configuration =
      { Type =
          { Deployment : Configuration/deployment.Type
          , Ingress : Configuration/universal.Type
          , Role : Configuration/universal.Type
          , RoleBinding : Configuration/universal.Type
          , Service : Configuration/universal.Type
          , ServiceAccount : Configuration/universal.Type
          , ServiceInternal : Configuration/universal.Type
          }
      , default =
        { Frontend = Configuration/deployment.default
        , Ingress = Configuration/universal.default
        , Role = Configuration/universal.default
        , RoleBinding = Configuration/universal.default
        , Service = Configuration/universal.default
        , ServiceAccount = Configuration/universal.default
        , ServiceInternal = Configuration/universal.default
        }
      }

in  configuration
