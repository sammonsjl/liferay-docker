#!/bin/bash

set -o errexit
shopt -s extglob

process_config_directory() {
    echo "##
## Config
##"
  if [[ ! -d "$ENTRYPOINT_DIR/config" ]]; then
    echo "No 'config' directory found. If you wish to configure Liferay make sure
to drop your *.properties and *.config files in the 'config' directory.

  "
    return 0
  fi

  echo "'config' directory found. The following contents are going to be copied to $LIFERAY_HOME and/or $LIFERAY_HOME/osgi/configs:
"
  show-files ${ENTRYPOINT_DIR}/config

  copy-files ${ENTRYPOINT_DIR}/config ${LIFERAY_HOME} "portal-*.properties"
  copy-files ${ENTRYPOINT_DIR}/config ${LIFERAY_HOME}/osgi/configs "*.config"
  copy-files ${ENTRYPOINT_DIR}/config ${LIFERAY_HOME}/osgi/configs "*.cfg"

  echo "
"
}

process_config_directory "$@"
