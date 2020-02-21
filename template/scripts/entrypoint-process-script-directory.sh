#!/bin/bash

set -o errexit
shopt -s extglob

execute_script() {
  if [[ ! -x "$1" ]]; then
      echo "Insufficient Permission: $1 is not executable"
      return 0
  fi

  echo "Running $1"
  ("$1" || die_script "$1")
}

die_script() {
  echo "Failed to run script ${1}"

  if [[ "$LCP_PROJECT_SCRIPT_FORCE_STARTUP" = "true" ]]; then
      return 0
  fi

  echo "Aborting container start because the script ${1} return a non-zero value. If you want to force initialization, please set the environment variable LCP_FORCE_STARTUP_SCRIPTS to false"
  return 1
}

process_script_directory() {
    echo "##
## Script
##"
  if [[ ! -d "$ENTRYPOINT_DIR/script" ]]; then
    echo "No 'script' directory found. If you wish to extra customize Liferay
drop your *.sh files into 'script' directory.

  "
    return 0
  fi

  echo "'script' directory found. The following contents are going to be executed
  "

  show-files ${ENTRYPOINT_DIR}/script
  copy-files ${ENTRYPOINT_DIR}/script /tmp/script

  for f in /tmp/script/*; do
    case "$f" in
      *.sh)     execute_script "$f" ;;
      *)        echo "Ignoring $f" ;;
    esac
    echo
  done

  echo "
"
}

process_script_directory "$@"
