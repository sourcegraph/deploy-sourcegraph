let ImageUpdater =
      https://raw.githubusercontent.com/sourcegraph/image-updater-pipeline/b99441a4372d2daf203560c394ff7ff27b9dc49d/package.dhall sha256:1a24c012d53e8df12543e8f0e59e7c10b23f7cff71a4c442848d6d254a211f16

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/deploy-sourcegraph-dogfood-k8s-2"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipelines = ImageUpdater.MakePipeline c

in  { Pipelines, Scripts = ImageUpdater.Scripts }
