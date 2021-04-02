let ImageUpdater =
      https://raw.githubusercontent.com/sourcegraph/image-updater-pipeline/ede3b188dd13df165cdfbdd04510c6414c858fcc/package.dhall sha256:73afd3ac2a4cca9ef77e76f6943a402e20763bfc745d19604d7503c106b5e28c

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/deploy-sourcegraph-dogfood-k8s-2"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipeline = ImageUpdater.MakePipeline c

in  { Pipeline, Scripts = ImageUpdater.Scripts }
