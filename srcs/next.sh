#!/bin/bash

if [ $OFF ];
then cp offginx.conf /etc/nginx/sites-available/default;
service nginx reload;
fi

bash