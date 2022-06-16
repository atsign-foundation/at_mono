#!/bin/bash

if [ -n "$GITHUB_ACTION" ];
then
  MELOS_ROOT_PATH="$GITHUB_WORKSPACE"
fi

source "$MELOS_ROOT_PATH/tools/REPOS.sh";

for i in ${REPOS//,/ }
do
  git submodule add -- "https://github.com/atsign-foundation/$i.git" "modules/$i" || true;
done;
