#!/bin/bash
cd /opt/aem

# Combine debug + JVM opts
export CQ_JVM_OPTS="$DEBUG_OPTS $JVM_OPTS"

echo "Starting AEM Author with JVM OPTS:"
echo "$CQ_JVM_OPTS"

java $CQ_JVM_OPTS -jar aem-author-p4502.jar \
  -gui \
  -r "author,localdev,dynamicmedia_scene7,nosamplecontent" \
  -p 4502