#!/bin/bash

set -o errexit
shopt -s extglob

process_hotfix() {
    echo "##
## Hot fix
##"
  if [[ ! -d "$ENTRYPOINT_DIR/hotfix" ]]; then
    echo "No 'hotfix' directory found. If you wish to apply hotfixes to Liferay make sure
to drop your hotfixes (zip) files in the 'hotfix' directory.

  "
    return 0
  fi

  echo "'hotfix' directory found. The following contents are going to be copied to $LIFERAY_HOME/patching-tool/patches and processed:
"
  show-files ${ENTRYPOINT_DIR}/hotfix
  copy-files ${ENTRYPOINT_DIR}/hotfix /tmp/hotfix

  for f in /tmp/hotfix/*.zip; do
    case "$f" in
      *.zip)    echo "Installing $f"; apply_hotfix "$f"; echo ;;
      *)        echo "Ignoring $f" ;;
    esac
    echo
  done
  echo
}

apply_hotfix() {
  if [[ -d "$LIFERAY_HOME/patching-tool/patches" ]]; then
    cp -v "$@" $LIFERAY_HOME/patching-tool/patches

    $LIFERAY_HOME/patching-tool/patching-tool.sh install
  fi;
}

process_hotfix "$@"
