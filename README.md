# Forumify Production Template

## Deploying to production

### Using docker compose

In `docker-compose.yml` a basic example infrastructure has been provided.
Replace the values in `environment` and run `docker-compose up -d` to launch forumify in production mode.

Verify your installation by going to `http://your-domain:8000`.

To enable HTTPS, use a proxy, for example [nginx proxy manager](https://nginxproxymanager.com/).

## Running locally

### Dependencies

- [PHP 8.2](https://www.php.net/downloads.php)
  - Add php installation to %PATH% variable
  - Enabled extensions (php.ini)
    - curl
    - fileinfo
    - intl
    - mbstring
    - openssl
    - pdo_mysql
    - zip
- [Composer](https://getcomposer.org/download/)
- [NodeJS](https://nodejs.org/en)
- [Symfony CLI](https://symfony.com/download)
  - If installing using the binary, add to %PATH%
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### First time setup (using docker)

1. Ensure docker is running and start the docker-compose infrastructure

```
docker compose up -d
```

2. Install project dependencies

```
composer install
npm install
```

3. Install TLS certificate

```
symfony server:ca:install
```

4. Start the symfony development server

```
symfony server:start
```
(optionally, add `-d` to run in background)

5. Start the frontend watcher

```
npm run watch
```

6. Install your instance

```
php bin/console forumify:platform:install
```

7. Visit the website at `https://localhost:8000`

### Future launches

1. (Optionally) Update dependencies, see step 2
2. (Optionally) Upgrade database schema, see step 6
3. Start symfony server
4. Start frontend watcher
