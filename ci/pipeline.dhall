let ImageUpdater =
      https://raw.githubusercontent.com/sourcegraph/image-updater-pipeline/849fd049f2c9ab74acb35e55bb003e853df15230/package.dhall sha256:7083d74f3646b143fa0b37a136d3429b759264ee616c3fe539f24d33cf75d5c7

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/deploy-sourcegraph-dogfood-k8s-2"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipeline = ImageUpdater.MakePipeline c

in  { Pipeline, Scripts = ImageUpdater.Scripts }
