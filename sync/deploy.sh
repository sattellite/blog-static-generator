#!/bin/bash
set -e

TZ=Europe/Moscow
# Go to script directory for correct define all paths
cd $(dirname ${BASH_SOURCE[0]})
# Path of the repository
ROOT=$(git rev-parse --show-toplevel)

cd ${ROOT}

${ROOT}/sync/synchronize.sh

if [ $? -eq 0 ]; then
  hugo -D
fi
