let kubernetes = (../../imports.dhall).Kubernetes

let configuration =
      { Type =
          { image : Optional Text
          , resources : Optional kubernetes.ResourceRequirements.Type
          , additionalEnvironmentVariables :
              Optional (List kubernetes.EnvVar.Type)
          }
      , default =
        { image = None
        , resources = None
        , additionalEnvironmentVariables = None
        }
      }

in  configuration
