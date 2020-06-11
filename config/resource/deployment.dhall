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
        { namespace = None
        , additionalAnnotations = None
        , additionalLabels = None
        , image = None
        , additionalEnvironmentVariables = None
        , repliacs = None
        }
      }

in  configuration
