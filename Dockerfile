# Base
FROM debian:buster
MAINTAINER oswin.bult@gmail.com
LABEL description="oswins ft_server for 42 Amsterdam (Codam)"

# Update
RUN apt-get update
RUN apt-get upgrade -y

# Installation
RUN apt-get -y install wget
RUN apt-get -y install php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring

RUN apt-get -y install nginx
RUN apt-get -y install mariadb-server

# Phpmyadmin
RUN wget -q https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz
RUN tar -xf phpMyAdmin-5.0.1-english.tar.gz && rm -rf phpMyAdmin-5.0.1-english.tar.gz
RUN mv phpMyAdmin-5.0.1-english /var/www/html/phpmyadmin
COPY srcs/config.inc.php /var/www/html/phpmyadmin

# Wordpress
COPY srcs/*.tar.gz .
RUN tar -xzf *.tar.gz && rm -rf *.tar.gz
RUN mv wordpress /var/www/html/wordpress
COPY srcs/wp-config.php /var/www/html/wordpress/

# Ssl
RUN openssl req -x509 -nodes -days 202 -subj "/C=NL/ST=Noord Holland/L=Amsterdam/O=Codam/OU=Student/CN=localhost" -newkey rsa:2048 -keyout /etc/ssl/localhost.key -out /etc/ssl/localhost.crt;

# Permission management
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html/*

# Last file copying
COPY srcs/onginx.conf /etc/nginx/sites-available/default
COPY srcs/phpmyadmin.sql .
COPY srcs/offginx.conf .
COPY srcs/*.sh . 
COPY srcs/index.html /var/www/html/

# Startup
RUN chmod 711 init.sh
RUN ./init.sh

EXPOSE 80 443
CMD bash next.sh