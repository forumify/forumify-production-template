FROM composer as backend-builder

WORKDIR /usr/src/app

COPY composer.* .

RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs --no-scripts --no-progress

FROM node:lts-slim as frontend-builder

WORKDIR /usr/src/app

COPY package*.json .
COPY --from=backend-builder /usr/src/app/vendor ./vendor
RUN npm i

COPY assets assets
COPY webpack.config.js webpack.config.js
RUN npm run build

FROM php:8.2-fpm-alpine

WORKDIR /usr/src/app

COPY . .
COPY --from=backend-builder /usr/src/app/vendor ./vendor
COPY --from=frontend-builder /usr/src/app/public/build ./public/build

# Configure OS
RUN apk add --no-cache \
    busybox-suid \
    icu-dev \
    libzip-dev \
    shadow \
    supervisor \
    tzdata \
    xmlstarlet && \
    docker-php-ext-install -j$(nproc) pdo_mysql intl opcache zip && \
    mkdir -p /var/log/supervisor

# Install nginx
RUN addgroup -S nginx && \
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
    usermod -u 1000 nginx && \
    groupmod -g 1000 nginx && \
    usermod --shell /bin/ash nginx && \
    apk add nginx && \
    apk del shadow

# Configuration files
COPY .docker/php/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY .docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

COPY .docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY .docker/nginx/http.d/default.conf /etc/nginx/http.d/default.conf

COPY .docker/supervisor/supervisord.conf /etc/supervisord.conf
COPY .docker/supervisor/conf.d /etc/supervisor/conf.d

COPY .docker/cron/crontab /var/spool/cron/crontabs/nginx

# Set Permissions
RUN mkdir -p var/cache && \
    chmod -R 755 var && \
    mkdir -p public/storage && \
    chmod -R 755 public/storage && \
    chown -R nginx:nginx . && \
    chmod +x -R bin

# Start forumify
COPY .docker/start.sh /start.sh
RUN chmod 755 /start.sh

CMD ["/start.sh"]
