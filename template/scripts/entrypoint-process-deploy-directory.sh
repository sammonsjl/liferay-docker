#!/bin/bash

set -o errexit
shopt -s extglob

process_deploy_directory() {
    echo "##
## Deploy
##"

  if [[ ! -d "$ENTRYPOINT_DIR/deploy" ]]; then
    echo "No 'deploy' directory found. If you wish to deploy custom jar/war/lpkg 
drop your custom modules in the 'deploy' directory.

  "

    return 0
  fi

  echo "'deploy' directory found. The content below will be copied according to the following:
  .jar files will be copied to ${LIFERAY_HOME}/osgi/modules
  .lpkg files will be copied to ${LIFERAY_HOME}/osgi/marketplace
  .war files will be copied to ${LIFERAY_HOME}/osgi/war
  "

  show-files ${ENTRYPOINT_DIR}/deploy

  copy-files ${ENTRYPOINT_DIR}/deploy ${LIFERAY_HOME}/osgi/modules "*.jar"
  copy-files ${ENTRYPOINT_DIR}/deploy ${LIFERAY_HOME}/osgi/marketplace "*.lpkg"
  copy-files ${ENTRYPOINT_DIR}/deploy ${LIFERAY_HOME}/osgi/war "*.war"

  echo "
"
}

process_deploy_directory "$@"
