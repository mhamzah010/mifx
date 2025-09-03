#!/bin/sh
set -euo pipefail

# Start PHP-FPM in background
php-fpm81 -F -y /etc/php81/php-fpm.conf &

# Start Nginx in foreground
exec nginx -g "daemon off;"