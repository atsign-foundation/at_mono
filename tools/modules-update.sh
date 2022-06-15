#!/bin/bash

if [ -n "$GITHUB_ACTION" ];
then
  MELOS_ROOT_PATH="$GITHUB_WORKSPACE"
fi

source "$MELOS_ROOT_PATH/tools/REPOS.sh";

for i in ${REPOS//,/ }
do
  git submodule update --init --checkout -f --remote --reference "https://github.com/atsign-foundation/$i.git" -- modules/;
done;