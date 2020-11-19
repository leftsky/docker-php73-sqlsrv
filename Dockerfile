FROM ubuntu:16.04
LABEL maintainer="leftsky <leftsky@vip.qq.com>"

COPY sources.list /etc/apt/sources.list
COPY supervisord.conf /etc/supervisord.conf
COPY start.sh /start.sh

# update package list
RUN apt-get update
RUN apt upgrade -y
RUN apt-get install software-properties-common -y
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
# RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/nginx
RUN apt-get update
# install curl and git
RUN apt-get install -y curl git nginx supervisor

# install php
RUN apt-get -y install php7.3 php7.3-fpm mcrypt php-mbstring php-pear php7.3-dev php7.3-xml php7.3-json php7.3-redis \
  php7.3-mysqli php7.3-fileinfo php7.3-gd php7.3-pdo php7.3-mbstring php7.3-zip 
#RUN apt-get install -y libapache2-mod-php7.3

# install pre requisites
RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list >/etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql mssql-tools
RUN apt-get install -y unixodbc-utf16
RUN apt-get install -y unixodbc-dev-utf16

RUN update-alternatives --set php /usr/bin/php7.3
RUN update-alternatives --set phpize /usr/bin/phpize7.3
RUN update-alternatives --set php-config /usr/bin/php-config7.3
# install driver sqlsrv
RUN pecl upgrade
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
RUN echo "extension=pdo.so" >>/etc/php/7.3/fpm/php.ini
RUN echo "extension=sqlsrv.so" >>/etc/php/7.3/fpm/php.ini
RUN echo "extension=pdo_sqlsrv.so" >>/etc/php/7.3/fpm/php.ini

# load driver sqlsrv
# RUN find / -name sqlsrv.so
#RUN echo "extension=/usr/lib/php/20180731/sqlsrv.so" >> /etc/php/7.3/apache2/php.ini
#RUN echo "extension=/usr/lib/php/20180731/pdo_sqlsrv.so" >> /etc/php/7.3/apache2/php.ini
#RUN echo "extension=/usr/lib/php/20180731/sqlsrv.so" >> /etc/php/7.3/cli/php.ini
#RUN echo "extension=/usr/lib/php/20180731/pdo_sqlsrv.so" >> /etc/php/7.3/cli/php.ini
# RUN echo "extension=sqlsrv.so" >> /etc/php/7.3/fpm/php.ini

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
# RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# install ODBC Driver
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN apt-get install -y unixodbc-dev
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN exec bash
RUN service php7.3-fpm start
RUN service php7.3-fpm stop

# install locales
RUN apt-get install -y locales && echo "en_US.UTF-8 UTF-8" >/etc/locale.gen && locale-gen

COPY default /etc/nginx/sites-available/default
RUN chmod 755 /start.sh

EXPOSE 80

WORKDIR /var/www/html/

CMD ["/start.sh"]
