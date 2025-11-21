FROM nginx:stable-alpine-slim

# Upgrade packages
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

# Create certs directory
RUN mkdir -p /usr/share/nginx/certs/

# Copy files
COPY certs /usr/share/nginx/certs/
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY html /usr/share/nginx/html/

# Fix permissions - nginx user needs to read the files
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    find /usr/share/nginx/html -type f -exec chmod 644 {} \;

# Expose ports
EXPOSE 80 443