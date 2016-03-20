FROM phusion/baseimage
MAINTAINER Steve Ryan <steve@2pisoftware.com>
# BASE PACKAGES INSTALL
RUN add-apt-repository ppa:nginx/stable
RUN add-apt-repository -y ppa:ondrej/php5
RUN apt-get update && apt-get install -y --force-yes  nano python-software-properties php5-cli git nginx php5-mysql curl php5-curl phantomjs git
RUN DEBIAN_FRONTEND="noninteractive" apt-get update; apt-get install -y --force-yes php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl php5-gd php5-mcrypt php5-intl php5-imap php5-tidy

# CONFIGURE NGINX
RUN mkdir -p /var/log/nginx;  echo "daemon off;" >> /etc/nginx/nginx.conf; ln -sf /dev/stdout /var/log/nginx/localhost.com-access.log; ln -sf /dev/stderr /var/log/nginx/localhost.com-error.log
EXPOSE 80 443


# CMFIVE INSTALL 
RUN git clone  -b 0-8-0-BRANCH https://github.com/2pisoftware/cmfive.git /var/www/cmfive
RUN mkdir -p /var/www/cmfive/storage; mkdir -p /var/www/cmfive/storage/logs; mkdir -p /var/www/cmfive/storage/backups; mkdir -p /var/www/cmfive/storage/session; cd /var/www/cmfive/system; php composer.phar update; chown -R www-data.www-data /var/www/cmfive; chmod -R 755 /var/www/cmfive

# TEST RUNNER INSTALL
RUN git clone --depth=10 https://github.com/2pisoftware/testrunner.git /var/www/testrunner; chown -R www-data.www-data /var/www/testrunner; chmod -R 755 /var/www/testrunner; cd /var/www/testrunner; php composer.phar update;

# SSH ACCESS
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN /usr/sbin/enable_insecure_key
EXPOSE 22

# MYSQL INSTALL AND SETUP
RUN apt-get update && \
    apt-get -yq install mysql-server-5.5 pwgen && \
    rm -rf /var/lib/apt/lists/* && \
    rm /etc/mysql/conf.d/mysqld_safe_syslog.cnf && \
    if [ ! -f /usr/share/mysql/my-default.cnf ] ; then cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf; fi && \
    mysql_install_db > /dev/null 2>&1 && \
    touch /var/lib/mysql/.EMPTY_DB

# Add MySQL scripts
ENV MYSQL_USER=admin MYSQL_PASS=admin ON_CREATE_DB=cmfive STARTUP_SQL=/install.sql

# Add VOLUMEs to allow backup of config and databases
VOLUME ["/etc/mysql", "/var/lib/mysql", "/var/run/mysqld"]
RUN mkdir /etc/service/mysql
EXPOSE 3306


# PHP CONFIG
# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
RUN mkdir           /etc/service/phpfpm

# nginx
ADD ./src/nginx/run /etc/service/nginx/run
ADD ./src/nginx/default /etc/nginx/sites-enabled/default
# php
ADD ./src/nginx/phpfpm.sh /etc/service/phpfpm/run
ADD ./src/phpMyAdmin/ /var/www/cmfive/phpMyAdmin
# cmfive
ADD ./src/cmfive/config.php /var/www/cmfive/config.php
# testrunner
ADD ./src/cmfive/environment.cmfive.docker.csv /var/www/testrunner/environment.cmfive.docker.csv
ADD ./src/cmfive/runcmfivedockertests.sh /runtests.sh
ADD ./src/cmfive/installcmfive.sh /installcmfive.sh
# mysql
ADD ./src/mysql/my.cnf /etc/mysql/conf.d/my.cnf
ADD ./src/mysql/mysqld_charset.cnf /etc/mysql/conf.d/mysqld_charset.cnf
ADD ./src/mysql/import_sql.sh /import_sql.sh
# todo generate this
ADD ./src/cmfive/install.sql /install.sql
ADD ./src/mysql/run.sh /etc/service/mysql/run
# PHPMYADMIN
ADD ./src/phpMyAdmin /var/www/cmfive/phpmyadmin
#CODIAD
ADD ./src/codiad /var/www/cmfive/codiad
# WIKI
RUN git clone https://github.com/2pisoftware/cmfive-wiki.git /var/www/wiki; ln -s /var/www/wiki/wiki /var/www/cmfive/modules/wiki

ENV TERM xterm

# executable service scripts
RUN chmod +x        /etc/service/phpfpm/run
RUN chmod +x /etc/service/nginx/run
RUN chmod +x /etc/service/mysql/run

#DISABLE apt cleanup
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expose volume after set up
#VOLUME /var/www
RUN locale-gen de_DE.UTF-8;  locale-gen fr_FR.UTF-8; locale-gen ja_JP.UTF-8;  locale-gen es_ES.UTF-8; locale-gen ru_RU.UTF-8; locale-gen gd_GP.UTF-8; locale-gen nl_NL.UTF-8; locale-gen zh_CN.UTF-8;
# phusion/baseimage init script
CMD ["/sbin/my_init"]
