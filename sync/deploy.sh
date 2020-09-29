#!/bin/bash
set -e

TZ=Europe/Moscow
# Go to script directory for correct define all paths
cd $(dirname ${BASH_SOURCE[0]})
# Path of the repository
ROOT=$(git rev-parse --show-toplevel)
HASHFILE=.content_sha1

cd ${ROOT}

${ROOT}/sync/synchronize.sh

SYNC_EXIT_CODE=$?

# Read previous hash of content
touch ${HASHFILE}
PREVHASH=$(cat ${HASHFILE})
# Calculate current hash of content
CURRHASH=$(find $(ls . | grep -v sync) -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum)

if [ ${SYNC_EXIT_CODE} -eq 0 ] && [ "${PREVHASH}" != "${CURRHASH}" ]; then
  hugo -D
  echo ${CURRHASH} > ${HASHFILE}
fi
