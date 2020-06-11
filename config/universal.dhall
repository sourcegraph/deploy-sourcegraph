let util = ../util/util.dhall

let configuration =
      { Type =
          { namespace : Optional Text
          , additionalAnnotations : Optional (List util.keyValuePair)
          , additionalLabels : Optional (List util.keyValuePair)
          }
      , default =
        { namespace = None
        , additionalAnnotations = None
        , additionalLabels = None
        }
      }

in  configuration
