let kubernetes = (../../imports.dhall).Kubernetes

let configuration =
      { Type =
          { image : Optional Text
          , resources : Optional kubernetes.ResourceRequirements.Type
          , additionalEnvironmentVariables :
              Optional (List kubernetes.EnvVar.Type)
          }
      , default =
        { image = None Text
        , resources = None kubernetes.ResourceRequirements.Type
        , additionalEnvironmentVariables = None (List kubernetes.EnvVar.Type)
        }
      }

in  configuration
