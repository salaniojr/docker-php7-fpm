#!/usr/bin/env bash
php-fpm -D & /usr/local/nginx/sbin/nginx -g "daemon off;"