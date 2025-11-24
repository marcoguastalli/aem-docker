# ------------------------------------------------------------
# AEM AUTHOR — Dockerfile (uses run_author.sh as entrypoint)
# ------------------------------------------------------------
# This Dockerfile builds an AEM Author instance using the
# official AEM SDK Quickstart JAR and license.properties.
#
# IMPORTANT:
# - The "crx-quickstart" folder should be mounted externally
#   to persist published content and indexes.
# - You must place the AEM quickstart JAR + license.properties
#   inside the author/ folder before building.
# ------------------------------------------------------------
FROM eclipse-temurin:11-jdk

ENV AEM_HOME=/opt/aem
WORKDIR ${AEM_HOME}

# Copy AEM Quickstart and license
COPY license.properties ${AEM_HOME}/license.properties
COPY aem-author-p4502.jar ${AEM_HOME}/aem-author-p4502.jar
COPY aem-service-pkg-6.5.22.0.zip ${AEM_HOME}/crx-quickstart/install/

# Copy your custom start script
COPY run_author.sh ${AEM_HOME}/run_author.sh

# Make script executable
RUN chmod +x ${AEM_HOME}/run_author.sh

# Expose AEM port + Debug port
EXPOSE 4502 8502

# JVM defaults (applied if not overridden)
ENV JVM_OPTS="\
 -server \
 -Xms2g -Xmx4g \
 -XX:+UseG1GC \
 -XX:+UseStringDeduplication \
 -Djava.awt.headless=true \
 -Dorg.slf4j.simpleLogger.defaultLogLevel=info \
 -Doak.queryLimitInMemory=500000 \
 -Doak.queryLimitReads=1000000 \
"

# Enable JPDA debugging
ENV DEBUG_OPTS="\
 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8502 \
"

# Run your script as entrypoint
ENTRYPOINT ["./run_author.sh"]