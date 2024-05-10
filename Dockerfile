FROM composer as backend-builder

WORKDIR /usr/src/app

COPY composer.* .

RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs --no-scripts --no-progress

FROM node:lts as frontend-builder

WORKDIR /usr/src/app

COPY --from=backend-builder /usr/src/app .
COPY package*.json .
RUN npm i

COPY asset[s] assets
COPY webpack.config.j[s] webpack.config.js
RUN npm run build

FROM forumify/forumify:latest

WORKDIR /usr/src/app

COPY . .
COPY --from=backend-builder /usr/src/app/vendor ./vendor
COPY --from=frontend-builder /usr/src/app/public/build ./public/build
