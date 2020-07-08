let kubernetes = (../../imports.dhall).Kubernetes

let util = ../../util/util.dhall

let configuration =
      { Type =
          { namespace : Optional Text
          , additionalAnnotations : Optional (List util.keyValuePair)
          , additionalLabels : Optional (List util.keyValuePair)
          , additionalEnvironmentVariables :
              Optional (List kubernetes.EnvVar.Type)
          , image : Optional Text
          , replicas : Optional Natural
          }
      , default =
        { namespace = None Text
        , additionalAnnotations = None (List util.keyValuePair)
        , additionalLabels = None (List util.keyValuePair)
        , image = None Text
        , additionalEnvironmentVariables = None (List kubernetes.EnvVar.Type)
        , replicas = None Natural
        }
      }

in  configuration
