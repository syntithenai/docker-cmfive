#FROM ubuntu:16.04
FROM selenium/standalone-firefox-debug
MAINTAINER Steve Ryan <steve@2pisoftware.com>
  
# INTEGRATE PHUSION BASE IMAGE STEPS
ADD ./src/baseimage/ /bd_build/
RUN chmod +rx -R /bd_build/

RUN /bd_build/prepare.sh && \
 	/bd_build/system_services.sh && \
 	/bd_build/utilities.sh && \
 	/bd_build/cleanup.sh

# BASE PACKAGES INSTALL
RUN apt-get update && apt-get install  -y --force-yes software-properties-common python-software-properties
RUN add-apt-repository ppa:nginx/stable
#RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update && apt-get install -y --force-yes  nano python-software-properties php-cli git nginx php-mysql curl php-curl git
RUN DEBIAN_FRONTEND="noninteractive" apt-get update; apt-get install -y --force-yes php-cli php-fpm php-mysql php-pgsql php-curl php-gd php-mcrypt php-intl php-imap php-tidy

# CONFIGURE NGINX
RUN mkdir -p /var/log/nginx;  echo "daemon off;" >> /etc/nginx/nginx.conf; ln -sf /dev/stdout /var/log/nginx/localhost.com-access.log; ln -sf /dev/stderr /var/log/nginx/localhost.com-error.log
EXPOSE 80 443


# CMFIVE INSTALL 
#RUN git clone  -b 0-8-0-BRANCH https://github.com/2pisoftware/cmfive.git /var/www/cmfive
#RUN mkdir -p /var/www/cmfive/storage; mkdir -p /var/www/cmfive/storage/logs; mkdir -p /var/www/cmfive/storage/backups; mkdir -p /var/www/cmfive/storage/session; cd /var/www/cmfive/system; php composer.phar update; chown -R www-data.www-data /var/www/cmfive; chmod -R 755 /var/www/cmfive

RUN apt-get update && apt-get install  -y --force-yes   php-mbstring php7.0-mbstring php-gettext

# TEST RUNNER INSTALL
#RUN git clone --depth=10 https://github.com/2pisoftware/testrunner.git /var/www/testrunner; chown -R www-data.www-data /var/www/testrunner; chmod -R 755 /var/www/testrunner; cd /var/www/testrunner; php composer.phar update;

# SSH ACCESS
#RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN /usr/sbin/enable_insecure_key
EXPOSE 22

# MYSQL INSTALL AND SETUP
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get -yq install mysql-server-5.7 pwgen 
    #&& \
   # rm -rf /var/lib/apt/lists/* && \
   # rm /etc/mysql/conf.d/mysqld_safe_syslog.cnf && \
   # if [ ! -f /usr/share/mysql/my-default.cnf ] ; then cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf; fi && \
#RUN   mysql_install_db > /dev/null 2>&1 
RUN touch /var/lib/mysql/.EMPTY_DB

# Add MySQL scripts
ENV MYSQL_USER=admin MYSQL_PASS=admin ON_CREATE_DB=cmfive STARTUP_SQL=/install.sql

# Add VOLUMEs to allow backup of config and databases
VOLUME ["/etc/mysql","/etc/nginx", "/var/lib/mysql", "/var/run/mysqld","/var/www"]
#RUN mkdir /etc/service/mysql
EXPOSE 3306


# PHP CONFIG
# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

#RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
#RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini
#RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
#RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
#RUN mkdir           /etc/service/phpfpm

# nginx
ADD ./src/nginx/run /etc/service/nginx/run
ADD ./src/nginx/default /etc/nginx/sites-enabled/default
# php
ADD ./src/nginx/phpfpm.sh /etc/service/phpfpm/run
ADD ./src/phpMyAdmin/ /var/www/cmfive/phpMyAdmin
# cmfive
ADD ./src/cmfive/config.php /var/www/cmfive/config.php
# testrunner
ADD ./src/cmfive/environment.cmfive.docker.csv /environment.cmfive.docker.csv
ADD ./src/cmfive/runcmfivedockertests.sh /runtests.sh
ADD ./src/cmfive/installcmfive.sh /installcmfive.sh
# mysql
ADD ./src/mysql/my.cnf /etc/mysql/conf.d/my.cnf
ADD ./src/mysql/mysqld_charset.cnf /etc/mysql/conf.d/mysqld_charset.cnf
ADD ./src/mysql/import_sql.sh /import_sql.sh
ADD ./src/cmfive/install.sql /install.sql
ADD ./src/mysql/run.sh /etc/service/mysql/run
# PHPMYADMIN
ADD ./src/phpMyAdmin /var/www/cmfive/phpmyadmin
#CODIAD
ADD ./src/codiad /var/www/cmfive/codiad
# WIKI
#RUN git clone https://github.com/2pisoftware/cmfive-wiki.git /var/www/wiki; ln -s /var/www/wiki/wiki /var/www/cmfive/modules/wiki

ENV TERM xterm

# executable service scripts
RUN chmod +x        /etc/service/phpfpm/run
RUN chmod +x /etc/service/nginx/run
RUN chmod +x /etc/service/mysql/run

#DISABLE apt cleanup
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expose volume after set up

RUN locale-gen de_DE.UTF-8;  locale-gen fr_FR.UTF-8; locale-gen ja_JP.UTF-8;  locale-gen es_ES.UTF-8; locale-gen ru_RU.UTF-8; locale-gen gd_GP.UTF-8; locale-gen nl_NL.UTF-8; locale-gen zh_CN.UTF-8;

ENV VIRTUAL_HOST cmfive.docker
VOLUME /var/www

# phusion/baseimage init script
CMD ["/sbin/my_init"]

  
