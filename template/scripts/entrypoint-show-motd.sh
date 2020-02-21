#!/bin/bash

set -o errexit

show_motd() {
  echo "Starting $@ instance.

  LIFERAY_HOME: $LIFERAY_HOME
  BUILD_DATE: $BUILD_DATE
  BUILD_VCS_REF: $BUILD_VCS_REF
  BUILD_VERSION: $BUILD_VERSION
  "
}

show_motd "$@"