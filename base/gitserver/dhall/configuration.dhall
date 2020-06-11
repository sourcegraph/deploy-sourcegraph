let Configuration/universal = ../../../config/universal.dhall

let Configuration/statefulset = ../../../config/resource/statefulset.dhall

let configuration =
      { Type =
          { StatefulSet : Configuration/statefulset.Type
          , Service : Configuration/universal.Type
          }
      , default =
        { StatefulSet = Configuration/statefulset.default
        , Service = Configuration/universal.default
        }
      }

in  configuration
