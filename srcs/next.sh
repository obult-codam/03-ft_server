#!/bin/bash

if [ $OFF ];
then cp offginx.conf /etc/nginx/sites-available/default;
#service nginx reload;
fi

service nginx start
service mysql start
service php7.3-fpm start

bash