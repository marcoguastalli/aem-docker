# ------------------------------------------------------------
# AEM PUBLISH — Dockerfile (uses run_publish.sh as entrypoint)
# ------------------------------------------------------------
# This Dockerfile builds an AEM Publish instance using the
# official AEM SDK Quickstart JAR and license.properties.
#
# IMPORTANT:
# - The "crx-quickstart" folder should be mounted externally
#   to persist published content and indexes.
# - You must place the AEM quickstart JAR + license.properties
#   inside the publish/ folder before building.
# ------------------------------------------------------------

FROM eclipse-temurin:11-jdk

ENV AEM_HOME=/opt/aem
WORKDIR ${AEM_HOME}

# Copy AEM Quickstart and license
COPY aem-publish-p4503.jar ${AEM_HOME}/aem-publish-p4503.jar
COPY license.properties ${AEM_HOME}/license.properties

# Copy your custom start script
COPY run_publish.sh ${AEM_HOME}/run_publish.sh

# Make script executable
RUN chmod +x ${AEM_HOME}/run_publish.sh

# Expose publish port + debug port
EXPOSE 4503 8503

# JVM defaults (local dev tuned)
ENV JVM_OPTS="\
 -server \
 -Xms2g -Xmx4g \
 -XX:+UseG1GC \
 -XX:+UseStringDeduplication \
 -Djava.awt.headless=true \
 -Doak.queryLimitInMemory=500000 \
 -Doak.queryLimitReads=1000000 \
"

# Enable remote debugging
ENV DEBUG_OPTS="\
 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8503 \
"

ENTRYPOINT ["./run_publish.sh"]