#!/bin/bash

# ----------------------------------------------------------------------
# Create the .env file if it does not exist.
# ----------------------------------------------------------------------
# if [[ ! -f "/var/www/.env" ]] && [[ -f "/var/www/.env.example" ]];
# then
#     cp /var/www/.env.example /var/www/.env
# fi

# ----------------------------------------------------------------------
# Run Composer
# ----------------------------------------------------------------------
# if [[ ! -d "/var/www/vendor" ]];
# then
#     cd /var/www
#     composer update
#     composer dump-autoload -o
# fi

# php artisan storage:link

# ----------------------------------------------------------------------
# 启动 HPS 模块 命令行
# ----------------------------------------------------------------------
# php artisan DBDatas:DataSender start

# ----------------------------------------------------------------------
# 启动 crontab
# ----------------------------------------------------------------------
crond

if [[ -f "/var/www/html/start.sh" ]];
then
    chmod +x /start.sh
    /var/www/html/start.sh
fi

# ----------------------------------------------------------------------
# Start supervisord
# ----------------------------------------------------------------------
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
