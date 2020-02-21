#!/bin/bash

set -o errexit

process_cluster() {
  echo "##
## Cluster
##"

  if [[ $LCP_PROJECT_LIFERAY_CLUSTER_ENABLED != "true" ]]; then
    echo "Cluster not enabled. If you want to enable cluster please set the environment variable LCP_PROJECT_LIFERAY_CLUSTER_ENABLED to true"
    return 0
  fi

  echo "Cluster enabled. This node will establish communication with other nodes via unicast.
Further information about the configuration can be found at portal-clu.properties and unicast.xml files."
  cp /opt/liferay/tools/cluster/portal-clu.properties /opt/liferay
  cp /opt/liferay/tools/cluster/unicast.xml /opt/liferay

  PERIOD_PASSWORD=${LIFERAY_JDBC_PERIOD_DEFAULT_PERIOD_PASSWORD:-''}

  PROPERTIES_FILES=(
    /opt/liferay/portal-all.properties
    /opt/liferay/portal-env.properties
    /opt/liferay/portal-clu.properties
    /opt/liferay/portal-ext.properties
  )

  for file in ${PROPERTIES_FILES[@]}; do
    if [[ ! -f ${file} ]]; then
      continue
    fi

    DBHOST=''
    DBNAME=''
    DBPASSWORD=''

    URL=$(grep 'jdbc.default.url=' ${file} | sed 's/^[[:space:]]*jdbc.default.url=\(.*\)/\1/g')

    if [ ! -z "$URL" ]; then
      URLMYSQL=$(grep 'jdbc.default.url=jdbc:mysql://' ${file} | sed 's/^[[:space:]]*jdbc.default.url=jdbc:mysql:\/\/\(.*\)/\1/g')
      URLMYSQL=$(echo $URLMYSQL | tr "/" "\n" | tr "?" "\n")

      arr=(`echo $URLMYSQL | tr '\n' ' '`)

      DBHOST=${arr[0]}
      DBNAME=${arr[1]}
    fi

    DBUSER=$(grep 'jdbc.default.username=' ${file} | sed 's/^[[:space:]]*jdbc.default.username=\(.*\)/\1/g')

    if [ ! -z "$PERIOD_PASSWORD" ]; then
      DBPASSWORD=$PERIOD_PASSWORD
    else
      DBPASSWORD=$(grep 'jdbc.default.password=' ${file} | sed 's/^[[:space:]]*jdbc.default.password=\(.*\)/\1/g')
    fi

    if [ ! -z $DBHOST ] && [ ! -z $DBNAME ] && [ ! -z $DBUSER ] && [ ! -z $DBPASSWORD ]; then
      break;
    fi
  done

  if [[ -z "$DBHOST" ]]; then
    echo "Undefined jdbc.default.url=jdbc:mysql://DBHOST for cluster mode"
  fi

  if [[ -z "$DBNAME" ]]; then
    echo "Undefined jdbc.default.url=jdbc:mysql://DBHOST/DBNAME for cluster mode"
  fi

  if [[ -z "$DBUSER" ]]; then
    echo "Undefined jdbc.default.username for cluster mode"
  fi

  if [[ -z "$DBPASSWORD" ]]; then
    echo "Undefined jdbc.default.password for cluster mode"
  fi

  if [ -z $DBHOST ] || [ -z $DBNAME ] || [ -z $DBUSER ] || [ -z $DBPASSWORD ]; then
    exit 1
  fi

  sed -i -e "s/@DBHOST@/${DBHOST}/g" /opt/liferay/unicast.xml
  sed -i -e "s/@DBNAME@/${DBNAME}/g" /opt/liferay/unicast.xml
  sed -i -e "s/@DBUSER@/${DBUSER}/g" /opt/liferay/unicast.xml
  sed -i -e "s/@DBPASSWORD@/${DBPASSWORD}/g" /opt/liferay/unicast.xml
}

process_cluster "$@"
echo "
"
