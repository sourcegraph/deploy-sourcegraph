let ImageUpdater =
      https://raw.githubusercontent.com/sourcegraph/image-updater-pipeline/eec274d84996ee9fc05b4bced9591de792aed41b/package.dhall sha256:98ed8de0599828c7e1badb9d0f772c36edf6b231d02c5a3188313b81c11b75f6

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/deploy-sourcegraph-dogfood-k8s-2"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipelines = ImageUpdater.MakePipeline c

in  { Pipelines, Scripts = ImageUpdater.Scripts }
