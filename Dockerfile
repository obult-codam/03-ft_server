# Base
FROM debian:buster
MAINTAINER oswin.bult@gmail.com
LABEL description="oswins ft_server for 42 Amsterdam"

# Update
RUN apt-get update

# Installation of software
RUN apt-get -y install \
			php-mysql php-fpm php-gd php-mbstring \
			nginx \
			mariadb-server \
			openssl \
			wget

# Wordpress command line interface
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod 711 wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# Wordpress
COPY srcs/*.tar.gz .
RUN tar -xzf *.tar.gz \
		&& rm -rf *.tar.gz \
		&& mv wordpress /var/www/html/wordpress
RUN service mysql start \
		&& wp core config --allow-root --path=/var/www/html/wordpress --dbname=wordpress --dbuser=root --dbpass= --dbhost=localhost --dbprefix=wp_ \
		# && mysql -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY '';" \
		&& wp db create --allow-root --path=/var/www/html/wordpress \
		&& mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';" \
		&& wp core install --allow-root --path=/var/www/html/wordpress --url=https://localhost/wordpress --title=FT_server --admin_user=admin --admin_password=code --admin_email=admin@mail.org

# Phpmyadmin
RUN wget -q https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz \
	 	&& tar -xf phpMyAdmin-5.0.1-english.tar.gz \
		&& rm -rf phpMyAdmin-5.0.1-english.tar.gz \
		&& mv phpMyAdmin-5.0.1-english /var/www/html/phpmyadmin
COPY srcs/config.inc.php /var/www/html/phpmyadmin
COPY srcs/phpmyadmin.sql .
RUN service mysql start \
		&& mysql -e  "CREATE DATABASE phpmyadmin;" \
		&& mysql -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'root'@'localhost';" \
		&& mysql -e "update mysql.user set plugin='' where user='root';" \
		&& mysql phpmyadmin < /var/www/html/phpmyadmin/sql/create_tables.sql

# Ssl
RUN openssl req -x509 -nodes -days 202 -subj "/C=NL/ST=Noord Holland/L=Amsterdam/O=Codam/OU=Student/CN=localhost" -newkey rsa:2048 -keyout /etc/ssl/localhost.key -out /etc/ssl/localhost.crt;

# Permission management
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html/*

# Last file copying / placing nginx conf, startup script and my own index
COPY srcs/nginx.conf /etc/nginx/sites-available/default
COPY srcs/start.sh ./ 
COPY srcs/index.html /var/www/html/

# Startup
CMD bash start.sh && tail -f /dev/null

EXPOSE 80 443