let kubernetes = (../imports.dhall).Kubernetes

let util = ../util/util.dhall

let configuration =
      { Type =
            { replicas : Optional Natural
            , image : Optional Text
            , namespace : Optional Text
            , additionalEnvironmentVariables :
                Optional (List kubernetes.EnvVar.Type)
            , additionalAnnotations : Optional (List util.keyValuePair)
            , additionalLabels : Optional (List util.keyValuePair)
            }
          : Type
      , default =
        { replicas = None
        , image = None
        , namespace = None
        , additionalEnvironmentVariables = None
        , additionalAnnotations = None
        , additionalLabels = None
        }
      }

in  configuration
