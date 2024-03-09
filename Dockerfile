FROM composer as backend-builder

WORKDIR /usr/src/app

COPY composer.* .

RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs --no-scripts --no-progress

FROM node:lts as frontend-builder

WORKDIR /usr/src/app

COPY package*.json .
COPY --from=backend-builder /usr/src/app/vendor ./vendor
RUN npm i

COPY assets assets
COPY webpack.config.js webpack.config.js
RUN npm run build

FROM forumify/forumify:latest

WORKDIR /usr/src/app

COPY . .
COPY --from=backend-builder /usr/src/app/vendor ./vendor
COPY --from=frontend-builder /usr/src/app/public/build ./public/build
