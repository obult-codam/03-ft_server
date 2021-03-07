# Base
FROM debian:buster
MAINTAINER oswin.bult@gmail.com
LABEL description="first docker experiment for the 42 ft_server module"

#update
RUN apt-get update
RUN apt-get upgrade -y

#installation
RUN apt-get -y install wget
RUN apt-get -y install php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring

RUN apt-get -y install nginx
RUN apt-get -y install mariadb-server
RUN apt-get -y install openssl

#NginX
RUN service nginx start
COPY srcs/onginx.conf /etc/nginx/sites-available/localhost
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-enabled/default

#placing my own index.html
#COPY srcs/index.html /var/www/html/

#phpmyadmin
RUN wget -q https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz
RUN tar -xf phpMyAdmin-5.0.1-english.tar.gz && rm -rf phpMyAdmin-5.0.1-english.tar.gz
RUN mv phpMyAdmin-5.0.1-english /var/www/html/phpmyadmin

# RUN mkdir -p /var/lib/phpmyadmin/tmp
# RUN chown -R www-data:www-data /var/lib/phpmyadmin

COPY srcs/config.inc.php /var/www/html/phpmyadmin

#wordpress
#RUN wget -q https://wordpress.org/latest.tar.gz
COPY srcs/*.tar.gz .
RUN tar -xzf *.tar.gz && rm -rf *.tar.gz
RUN mv wordpress /var/www/html/wordpress
COPY srcs/wp-config.php /var/www/html/wordpress/

#ssl
RUN openssl req -x509 -nodes -days 202 -subj "/C=NL/ST=Noord Holland/L=Amsterdam/O=Codam/OU=Student/CN=localhost" -newkey rsa:2048 -keyout /etc/ssl/localhost.key -out /etc/ssl/localhost.crt;

#permission management
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html/*

#startup
COPY srcs/init.sh .

RUN service nginx start

EXPOSE 80 443

CMD bash init.sh