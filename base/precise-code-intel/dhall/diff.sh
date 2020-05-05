#!/usr/bin/env bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")"

dhall diff ./raw/package.dhall ./human/package.dhall
