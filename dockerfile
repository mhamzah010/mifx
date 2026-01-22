#Real on use alpine:3.18
FROM alpine:3.18

# Install Nginx, PHP 8.1 (FPM) and other extensions
RUN apk add --no-cache \
    nginx \
    nginx-mod-http-headers-more \
    php81 php81-fpm php81-cli php81-opcache php81-mbstring php81-json php81-session \
    php81-curl php81-xml php81-zip php81-pgsql curl bash ca-certificates tzdata \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -S web && adduser -S -G web web

# Prepare directories
RUN mkdir -p /var/www/public /var/www/logs /run/nginx /etc/nginx/conf.d \
    && chown -R web:web /var/www /run/nginx /var/lib/nginx /var/log/nginx

# Create logs dir and set php-fpm error log
RUN mkdir -p /var/www/logs \
    && chown -R web:web /var/www/logs

# Copy configs and app for Web security hardening
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY docker/php/security.ini /etc/php81/conf.d/zz-security.ini
COPY docker/php/www.conf /etc/php81/php-fpm.d/www.conf
COPY docker/php/logging.conf /etc/php81/php-fpm.d/logging.conf
COPY app /var/www

# Switch to non-root
USER web

# Expose internal port 8080
EXPOSE 8080

# Entrypoint to run PHP-FPM and Nginx
COPY docker/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]