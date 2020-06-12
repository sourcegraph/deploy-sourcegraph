let Base/toList = ./base/package.dhall

let Configuration/global = ./config/config.dhall

let c = Configuration/global::{=}

in  Base/toList c
