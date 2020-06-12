let Configuration/universal = ../../../config/universal.dhall

let Configuration/container = ../../../config/resource/container.dhall

let util = ../../../util/util.dhall

let containers =
      { Type = { SourcegraphFrontend : Configuration/container.Type }
      , default.SourcegraphFrontend = Configuration/container.default
      }

let deployment =
      { Type =
          { namespace : Optional Text
          , additionalAnnotations : Optional (List util.keyValuePair)
          , additionalLabels : Optional (List util.keyValuePair)
          , replicas : Optional Natural
          , Containers : containers.Type
          }
      , default =
        { namespace = None Text
        , additionalAnnotations = None (List util.keyValuePair)
        , additionalLabels = None (List util.keyValuePair)
        , replicas = None Natural
        , Containers = containers.default
        }
      }

let configuration =
      { Type =
          { Deployment : deployment.Type
          , Ingress : Configuration/universal.Type
          , Role : Configuration/universal.Type
          , RoleBinding : Configuration/universal.Type
          , Service : Configuration/universal.Type
          , ServiceAccount : Configuration/universal.Type
          , ServiceInternal : Configuration/universal.Type
          }
      , default =
        { Deployment = deployment.default
        , Ingress = Configuration/universal.default
        , Role = Configuration/universal.default
        , RoleBinding = Configuration/universal.default
        , Service = Configuration/universal.default
        , ServiceAccount = Configuration/universal.default
        , ServiceInternal = Configuration/universal.default
        }
      }

in  configuration
