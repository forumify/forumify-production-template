su nginx -c "/usr/src/app/bin/console doctrine:migrations:migrate --no-interaction"
su nginx -c "/usr/src/app/bin/console cache:warmup"

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
