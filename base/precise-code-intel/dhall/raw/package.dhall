{ APIServer =
  { Deployment = ./api-server.Deployment-RAW-IMPORT.dhall
  , Service = ./api-server.Service-RAW-IMPORT.dhall
  }
, BundleManger =
  { Deployment = ./bundle-manager.Deployment-RAW-IMPORT.dhall
  , Service = ./bundle-manager.Service-RAW-IMPORT.dhall
  , PersistentVolumeClaim =
      ./bundle-manager.PersistentVolumeClaim-RAW-IMPORT.dhall
  }
, Worker =
  { Deployment = ./worker.Deployment-RAW-IMPORT.dhall
  , Service = ./worker.Service-RAW-IMPORT.dhall
  }
}
