let ImageUpdater =
      https://raw.githubusercontent.com/sourcegraph/image-updater-pipeline/c9ee0bb140018fd65c6fb13ffb2b8b9bc197b932/package.dhall sha256:9b8636a8579f27b62afb8757d64830bd4013f3580f1117e321c9cbbeabebcecb

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/deploy-sourcegraph-dogfood-k8s-2"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipelines = ImageUpdater.MakePipeline c

in  { Pipelines, Scripts = ImageUpdater.Scripts }
