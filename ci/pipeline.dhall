let ImageUpdater =
      https://raw.githubusercontent.com/sourcegraph/image-updater-pipeline/c57505015e2d2054446b70e49a96cee66f6e0b61/package.dhall sha256:22614ee59a29fb03efe74662c186ecb7bbc9b9c8236ecb7a5725c8d27046b1cb

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/deploy-sourcegraph-dogfood-k8s-2"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipelines = ImageUpdater.MakePipeline c

in  { Pipelines, Scripts = ImageUpdater.Scripts }
