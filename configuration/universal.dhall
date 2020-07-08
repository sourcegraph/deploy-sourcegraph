let util = ../util.dhall

let configuration =
      { Type =
          { namespace : Optional Text
          , additionalAnnotations : Optional (List util.keyValuePair)
          , additionalLabels : Optional (List util.keyValuePair)
          }
      , default =
        { namespace = None Text
        , additionalAnnotations = None (List util.keyValuePair)
        , additionalLabels = None (List util.keyValuePair)
        } 
      }

in  configuration
