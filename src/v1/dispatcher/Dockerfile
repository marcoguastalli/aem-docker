# -----------------------------------------------------------------------------
# AEM Dispatcher Dockerfile
# Based on Apache HTTPD 2.4 — the standard foundation for Adobe Dispatcher.
#
# This image is meant to be used in a local AEMaaCS-like environment,
# together with AEM Author, Publish, and optional WAF / CDN layers.
#
# Every step below is documented so you know exactly what’s happening.
# -----------------------------------------------------------------------------

FROM httpd:2.4

# -----------------------------------------------------------------------------
# 📌 Create folder structure expected by Dispatcher
# -----------------------------------------------------------------------------

# This is where dispatcher modules and config usually live
RUN mkdir -p /etc/httpd/modules \
    && mkdir -p /etc/httpd/conf \
    && mkdir -p /etc/httpd/conf.d \
    && mkdir -p /etc/httpd/conf.dispatcher.d \
    && mkdir -p /var/cache/httpd/dispatcher \
    && mkdir -p /var/www/html

# -----------------------------------------------------------------------------
# 📦 Install required tools (curl, unzip, bash, etc.)
# -----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y curl unzip nano vim && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# 📌 Copy the Dispatcher module (dispatcher-apache2.x-*.so)
# Make sure the file is inside: dispatcher/modules/
# -----------------------------------------------------------------------------
# If you have multiple versions, adjust the file name here.
COPY modules/dispatcher.so /etc/httpd/modules/mod_dispatcher.so

# -----------------------------------------------------------------------------
# 📌 Copy Apache configuration snippets
# These override and extend the default httpd.conf
# -----------------------------------------------------------------------------
COPY conf/httpd.conf /usr/local/apache2/conf/httpd.conf

# Virtual hosts, rewrites, cache rules
COPY conf.d/ /etc/httpd/conf.d/

# Dispatcher configs ( farms, filters, cache config, renders, stats )
COPY conf.dispatcher.d/ /etc/httpd/conf.dispatcher.d/

# -----------------------------------------------------------------------------
# 📁 Copy cache presets if needed (optional)
# -----------------------------------------------------------------------------
COPY cache/ /var/cache/httpd/dispatcher/

# -----------------------------------------------------------------------------
# 🔧 Set file permissions so Apache can write cache logs
# -----------------------------------------------------------------------------
RUN chown -R www-data:www-data /var/cache/httpd/dispatcher \
    && chmod -R 755 /var/cache/httpd/dispatcher

# -----------------------------------------------------------------------------
# 🔥 Enable necessary Apache modules for Dispatcher to work correctly
# -----------------------------------------------------------------------------
RUN sed -i \
    -e 's/#LoadModule proxy_module/LoadModule proxy_module/' \
    -e 's/#LoadModule proxy_http_module/LoadModule proxy_http_module/' \
    -e 's/#LoadModule slotmem_shm_module/LoadModule slotmem_shm_module/' \
    -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
    -e 's/#LoadModule headers_module/LoadModule headers_module/' \
    /usr/local/apache2/conf/httpd.conf

# -----------------------------------------------------------------------------
# 🌐 Expose port 80 — standard HTTP port
# -----------------------------------------------------------------------------
EXPOSE 80

# -----------------------------------------------------------------------------
# 🏁 Start Apache in foreground mode (required in Docker)
# -----------------------------------------------------------------------------
CMD ["httpd-foreground"]