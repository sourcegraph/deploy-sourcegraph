let ImageUpdater =
      https://raw.githubusercontent.com/sourcegraph/image-updater-pipeline/92586e0bcf0afc588a8dfb311f8e8a2ba76cbde3/package.dhall sha256:0f91f30c4e9d374ad1381849c4ac948feda83cc72aef3ee9d48e81a678dd27ca

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/deploy-sourcegraph-dogfood-k8s-2"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipeline = ImageUpdater.MakePipeline c

in  { Pipeline, Scripts = ImageUpdater.Scripts }
