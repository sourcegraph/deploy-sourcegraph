#!/bin/bash

set -e

sed -e 's/\\/\\\\/g' <&0 | sed -e 's/"/\\"/g'
