{ APIServer =
  { Deployment = ./api-server.Deployment.dhall
  , Service = ./api-server.Service.dhall
  }
, BundleManger =
  { Deployment = ./bundle-manager.Deployment.dhall
  , Service = ./bundle-manager.Service.dhall
  , PersistentVolumeClaim = ./bundle-manager.PersistentVolumeClaim.dhall
  }
, Worker =
  { Deployment = ./worker.Deployment.dhall, Service = ./worker.Service.dhall }
}
