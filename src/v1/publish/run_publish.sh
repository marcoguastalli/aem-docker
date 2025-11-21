#!/bin/bash
cd /opt/aem

export CQ_JVM_OPTS="$DEBUG_OPTS $JVM_OPTS"

echo "Starting AEM Publish with JVM OPTS:"
echo "$CQ_JVM_OPTS"

java $CQ_JVM_OPTS -jar aem-publish-p4503.jar \
  -gui \
  -r "publish,localdev,dynamicmedia_scene7,nosamplecontent" \
  -p 4503