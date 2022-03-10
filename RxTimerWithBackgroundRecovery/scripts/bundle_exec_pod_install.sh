#!/bin/bash
set -euo pipefail

PROJECT_DIR=$(dirname "$PWD")
echo -e "项目资源目录: \n${PROJECT_DIR}"

pushd $PROJECT_DIR
bundle exec pod install
popd 


