let Configuration/universal = ../../../config/universal.dhall

let Configuration/container = ../../../config/resource/container.dhall

let util = ../../../util/util.dhall

let containers =
      { Type = { Gitserver : Configuration/container.Type }
      , default.Gitserver = Configuration/container.default
      }

let statefulset =
      { Type =
          { namespace : Optional Text
          , additionalAnnotations : Optional (List util.keyValuePair)
          , additionalLabels : Optional (List util.keyValuePair)
          , replicas : Optional Natural
          , Containers : containers.Type
          }
      , default =
        { namespace = None
        , additionalAnnotations = None
        , additionalLabels = None
        , replicas = None
        , Containers = containers.default
        }
      }

let configuration =
      { Type =
          { StatefulSet : statefulset.Type
          , Service : Configuration/universal.Type
          }
      , default =
        { StatefulSet = statefulset.default
        , Service = Configuration/universal.default
        }
      }

in  configuration
