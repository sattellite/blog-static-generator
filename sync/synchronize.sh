#!/bin/bash
set -e


function preparePost {
  local f=${1}
  local p=${2}
  local _FILE=$(echo $(basename ${f}) |sed -e "s#[0-9]...-[0-9].-[0-9].-\\(.*\\)#\\1#")
  local _DATES=($(git log --format=%aI --reverse ${f} | sed -e 1b -e '$!d'))
  local _TITLE=$(sed -n "s/^# \\(.*\\)/\\1/p" ${f} | sed -e 1b -e '1!d')
  local _DRAFT="false"

  local extra=""
  local cursor=1
  # If first line is front matter start
  if [ "$(head -n1 ${f})" == "---" ]; then
    # Extract front matter https://stackoverflow.com/a/20943542/1489324
    local fm=$(sed -n '/---/ {
      :loop
      n
      /---/q
      p
      b loop
    }' ${f})

    # Parsing values
    local lines=$(echo "${fm}"|wc -l)
    cursor=1
    while [ ${cursor} -le $((lines+1)) ]; do
      local line_str=$(echo "${fm}" | sed -n ${cursor}'p')
      if [ "x" == "x${line_str}" ]; then
        ((cursor += 1))
        continue
      fi
      local key=$(echo ${line_str} | sed -e 's/\(.*\):.*/\1/')
      local val=$(echo ${line_str} | sed -e 's/.*:\(.*\)/\1/')
      if [ "${key}" == "title" ]; then
        _TITLE=${val}
      elif [ "${key}" == "date" ]; then
        _DATES[0]=${val}
      elif [ "${key}" == "noedit" ]; then
        _DATES[1]=""
      elif [ "${key}" == "edit" ]; then
        _DATES[1]=${val}
      elif [ "${key}" == "draft" ]; then
        _DRAFT=${val}
      elif [ "${key}" == "tags" ]; then
        extra="${extra}\n${key}: [${val}]"
      else
        extra="${extra}\n${key}: ${val}"
      fi
      ((cursor += 1))
    done
    # First and last "---" rows. For later sed output
    ((cursor+=2))
  fi

  echo -e "---\ntitle: ${_TITLE}\ndate: ${_DATES[0]}" > ${p}/${_FILE}
  if [ "x${_DATES[1]}" != "x" ]; then
    echo "edit: ${_DATES[1]}" >> ${p}/${_FILE}
  fi
  echo -e "${extra}" >> ${p}/${_FILE}
  echo -e "draft: ${_DRAFT}\n---\n" >> ${p}/${_FILE}

  if [[ ! -z "${NOSYNC}" ]]; then
    echo -e "---\ntitle: ${_TITLE}\ndate: ${_DATES[0]}\nfile: ${_FILE}"
  fi

  sed -n "${cursor},\$p" ${f} >> ${p}/${_FILE}
}

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

if [[ -z "${NOSYNC}" ]]; then
  # Sync static generator
  git reset --hard
  git fetch --all
  git rebase

  # Renew blog posts and themes
  git submodule sync
  git submodule init
  git submodule update
  git submodule foreach "(git checkout master && git pull --ff origin master && git push origin master) || true"
fi

# Copy images to static
cp -a ${BLOG}/images ${ROOT}/static

cd ${BLOG}

# Prepare posts for hugo
if [ -d posts ]; then
  mkdir -p ${POSTS}
  rm -f ${POSTS}/*.md
  for f in $(ls posts/*.md); do
    preparePost "${f}" ${POSTS}
  done
fi

# Prepare notes for hugo
if [ -d notes ]; then
  mkdir -p ${NOTES}
  rm -f ${NOTES}/*.md
  for f in $(ls notes/*.md); do
    preparePost "${f}" ${NOTES}
  done
fi
