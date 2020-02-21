#!/bin/bash

set -o errexit

process_monitor() {
    echo "##
## Monitor
##"
  if [ "$LCP_PROJECT_MONITOR_DYNATRACE_TENANT" -a "$LCP_PROJECT_MONITOR_DYNATRACE_TOKEN" ]; then
    echo "Monitor is enabled. This container will start to push metrics to Dynatrace dashboard.
Further information can be found at https://${LCP_PROJECT_MONITOR_DYNATRACE_TENANT}.live.dynatrace.com.
  "

    RESPONSE=$(curl -X GET \
      https://${LCP_PROJECT_MONITOR_DYNATRACE_TENANT}.live.dynatrace.com/api/v1/deployment/installer/agent/connectioninfo \
      -H "Authorization: Api-Token ${LCP_PROJECT_MONITOR_DYNATRACE_TOKEN}" \
      -H "Cache-Control: no-cache" \
      -H "Content-Type: application/json")

    TENANT_UUID=$(echo $RESPONSE | jq -r '.tenantUUID')
    TENANT_TOKEN=$(echo $RESPONSE | jq -r '.tenantToken')
    COMMUNICATION_ENDPOINTS=$(echo $RESPONSE | jq -r '.communicationEndpoints')

    cat /opt/dynatrace/oneagent/manifest.json | jq -r ".tenantUUID|=\"$TENANT_UUID\"" | jq -r ".tenantToken|=\"$TENANT_TOKEN\""  | jq -r ".communicationEndpoints|=$COMMUNICATION_ENDPOINTS" >> /tmp/manifest.json
    mv /tmp/manifest.json /opt/dynatrace/oneagent/manifest.json

    COMMUNICATION_ENDPOINTS=$(echo $RESPONSE | jq -r '.communicationEndpoints|join(";")')

    sed -i -e "s/tenant-to-replace/${TENANT_UUID}/g" /opt/dynatrace/oneagent/dynatrace-env.sh
    sed -i -e "s/token-to-replace/${TENANT_TOKEN}/g" /opt/dynatrace/oneagent/dynatrace-env.sh
    sed -i -e "s#connectionpoint-to-replace#${COMMUNICATION_ENDPOINTS}#g" /opt/dynatrace/oneagent/dynatrace-env.sh
  else
    echo "Monitor is not enabled. If you want to enable please set the environment variables
LCP_PROJECT_MONITOR_DYNATRACE_TENANT and LCP_PROJECT_MONITOR_DYNATRACE_TOKEN."
  fi
  echo "
"
}

process_monitor "$@"
