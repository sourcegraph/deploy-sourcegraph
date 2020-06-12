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
        { replicas = None Natural
        , image = None Text
        , namespace = None Text
        , additionalEnvironmentVariables = None (List kubernetes.EnvVar.Type)
        , additionalAnnotations = None (List util.keyValuePair)
        , additionalLabels = None (List util.keyValuePair)
        }
      }

in  configuration
