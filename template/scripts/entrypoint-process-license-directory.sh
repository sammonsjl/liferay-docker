#!/bin/bash

set -o errexit
shopt -s extglob

process_license_directory() {
    echo "##
## License
##"
  if [[ ! -d "$ENTRYPOINT_DIR/license" ]]; then
    echo "No 'license' directory found. If you wish to provide Liferay a license make sure
to drop your *.xml or *.aatf files in the 'license' directory.

  "
    return 0
  fi

  echo "'license' directory found. The following contents are going to be copied to $LIFERAY_HOME/deploy and/or $LIFERAY_HOME/data:
"

  show-files ${ENTRYPOINT_DIR}/license

  rm ${LIFERAY_HOME}/deploy/license.xml || true

  copy-files ${ENTRYPOINT_DIR}/license ${LIFERAY_HOME}/deploy "*.xml"
  copy-files ${ENTRYPOINT_DIR}/license ${LIFERAY_HOME}/data "*.aatf"

  rm -rf $LIFERAY_HOME/license
  echo "
"
}

process_license_directory "$@"
