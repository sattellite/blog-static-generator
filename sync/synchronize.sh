#!/bin/bash

set -e

TZ=Europe/Moscow

# Go to script directory for correct define all paths
cd $(dirname ${BASH_SOURCE[0]})

# Path of the repository
ROOT=$(git rev-parse --show-toplevel)
# Path of the sync directory
SYNC=${ROOT}/sync
# Path of the original blog
BLOG=${SYNC}/blog

POSTS=${ROOT}/content/posts
NOTES=${ROOT}/content/notes

# Go to root repo directory for execute all commands
cd ${ROOT}

# Sync static generator
git reset --hard
git fetch --all
git rebase

# Renew blog posts
git submodule update --init
git submodule update sync/blog

# Copy images to static
cp -a ${BLOG}/images ${ROOT}/static

cd ${BLOG}

# Prepare posts for hugo
if [ -d posts ]; then
  mkdir -p ${POSTS}
  rm -f ${POSTS}/*.md
  for f in $(ls posts/*.md); do
    FILE=$(echo $(basename ${f}) |sed -e "s#[0-9]...-[0-9].-[0-9].-\\(.*\\)#\\1#")
    echo $FILE
    DATES=($(git log --format=%aI --reverse ${f} | sed -e 1b -e '$!d'))
    TITLE=$(sed -n "s/^# \\(.*\\)/\\1/p" ${f} | sed -e 1b -e '1!d')

    echo -e "---\ntitle: ${TITLE}\ndate: ${DATES[0]}" > ${POSTS}/${FILE}
    if [ "x${DATES[1]}" != "x" ]; then
      echo "edit: ${DATES[1]}" >> ${POSTS}/${FILE}
    fi
    echo -e "draft: false\n---\n" >> ${POSTS}/${FILE}
    cat ${f} >> ${POSTS}/${FILE}
  done
fi

# Prepare notes for hugo
if [ -d notes ]; then
  mkdir -p ${NOTES}
  rm -f ${NOTES}/*.md
  for f in $(ls notes/*.md); do
    FILE=$(basename ${f})
    DATES=($(git log --format=%aI --reverse ${f} | sed -e 1b -e '$!d'))
    TITLE=$(sed -n "s/^# \\(.*\\)/\\1/p" ${f} | sed -e 1b -e '1!d')

    echo -e "---\ntitle: ${TITLE}\ndate: ${DATES[0]}" > ${POSTS}/${FILE}
    if [ "x${DATES[1]}" != "x" ]; then
      echo "edit: ${DATES[1]}" >> ${POSTS}/${FILE}
    fi
    echo -e "draft: false\n---\n" >> ${POSTS}/${FILE}

    cat ${f} >> ${POSTS}/${FILE}
  done
fi
