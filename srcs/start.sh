#!/bin/bash

if [ $OFF ];
then sed -i $'s:autoindex on:autoindex off:' /etc/nginx/sites-available/default
fi

service nginx start
service mysql start
service php7.3-fpm start
