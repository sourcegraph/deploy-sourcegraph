let ImageUpdater =
      https://raw.githubusercontent.com/sourcegraph/image-updater-pipeline/89981c7e5a76402060bc40ffe43a03723d7b5706/package.dhall sha256:11052fdfd7cfe82ae9267b66d148a1112b5666c5452513c3a9b04b03107fe6ca

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/deploy-sourcegraph-dogfood-k8s-2"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipeline = ImageUpdater.MakePipeline c

in  { Pipeline, Scripts = ImageUpdater.Scripts }
