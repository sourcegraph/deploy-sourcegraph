let ImageUpdater =
      https://raw.githubusercontent.com/sourcegraph/image-updater-pipeline/a3c8b1df96a16f6a51810b972223e9bbdfa63204/package.dhall sha256:52689c47ba36526061e25035b9b002bfaf0f9f1f0f76b7e0f2014a4625e9fc15

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/deploy-sourcegraph-dogfood-k8s-2"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipeline = ImageUpdater.MakePipeline c

in  { Pipeline, Scripts = ImageUpdater.Scripts }
