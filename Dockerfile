FROM ubuntu:16.04
MAINTAINER Steve Ryan <steve@2pisoftware.com>

# Add VOLUMEs to allow backup of config and databases
#VOLUME ["/etc/mysql","/etc/nginx", "/var/lib/mysql", "/var/run/mysqld","/var/www"]
  
# INTEGRATE PHUSION BASE IMAGE STEPS
ADD ./src/baseimage/ /bd_build/

RUN chmod +rx -R /bd_build/; /bd_build/prepare.sh && \
 	/bd_build/system_services.sh && \
 	/bd_build/utilities.sh && \
 	/bd_build/cleanup.sh


RUN  echo "deb http://archive.ubuntu.com/ubuntu xenial main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main universe\n" >> /etc/apt/sources.list \
  && echo "deb http://security.ubuntu.com/ubuntu xenial-security main universe\n" >> /etc/apt/sources.list

RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    bzip2 \
    ca-certificates \
    openjdk-8-jre-headless \
    sudo \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

#==========
# Selenium
#==========
RUN  mkdir -p /opt/selenium \
  && wget --no-verbose https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar -O /opt/selenium/selenium-server-standalone.jar

#========================================
# Add normal user with passwordless sudo
#========================================
RUN sudo useradd seluser --shell /bin/bash --create-home \
  && sudo usermod -a -G sudo seluser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'seluser:secret' | chpasswd
  

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

#===================
# Timezone settings
# Possible alternative: https://github.com/docker/docker/issues/3359#issuecomment-32150214
#===================
ENV TZ "US/Pacific"
RUN echo "${TZ}" > /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata

#==============
# VNC and Xvfb
#==============
RUN apt-get update -qqy \
  && apt-get -qqy install \
    xvfb \
  && rm -rf /var/lib/apt/lists/*



#============================
# Some configuration options
#============================
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0

#=========
# Firefox
#=========
ENV FIREFOX_VERSION 45.0.2
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install firefox \
  && rm -rf /var/lib/apt/lists/* \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
  && apt-get -y purge firefox \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

#========================
# Selenium Configuration
#========================
COPY ./src/selenium/config.json /opt/selenium/config.json

EXPOSE 4444

#=====
# VNC
#=====
RUN apt-get update -qqy \
  && apt-get -qqy install \
    x11vnc \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p ~/.vnc \
  && x11vnc -storepasswd secret ~/.vnc/passwd

#=================
# Locale settings
#=================
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
RUN locale-gen en_US.UTF-8 \
  && dpkg-reconfigure --frontend noninteractive locales \
  && apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    language-pack-en \
  && rm -rf /var/lib/apt/lists/*

#=======
# Fonts
#=======
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    fonts-ipafont-gothic \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    xfonts-scalable \
  && rm -rf /var/lib/apt/lists/*

#=========
# fluxbox
# A fast, lightweight and responsive window manager
#=========
RUN apt-get update -qqy \
  && apt-get -qqy install \
    fluxbox \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 5900

 
RUN apt-get update && apt-get install  -y --force-yes software-properties-common python-software-properties git php-cli
RUN apt-get --allow-unauthenticated update && apt-get install -y --force-yes  nano  php-cli git nginx php-mysql curl php-curl git
RUN DEBIAN_FRONTEND="noninteractive" apt-get update; apt-get install -y --force-yes php-cli php-fpm php-mysql php-pgsql php-curl php-gd php-mcrypt php-intl php-imap php-tidy
RUN apt-get update && apt-get install  -y --force-yes   php-mbstring php7.0-mbstring php-gettext

# CONFIGURE NGINX
RUN mkdir -p /var/log/nginx;  echo "daemon off;" >> /etc/nginx/nginx.conf; ln -sf /dev/stdout /var/log/nginx/localhost.com-access.log; ln -sf /dev/stderr /var/log/nginx/localhost.com-error.log
EXPOSE 80 443

# CMFIVE INSTALL 
RUN git clone --depth=1 -b master https://github.com/2pisoftware/cmfive.git /var/www/cmfive
RUN mkdir -p /var/www/cmfive/storage; mkdir -p /var/www/cmfive/storage/logs; mkdir -p /var/www/cmfive/storage/backups; mkdir -p /var/www/cmfive/storage/session; cd /var/www/cmfive/system; php composer.phar update; chown -R www-data.www-data /var/www/cmfive; chmod -R 755 /var/www/cmfive

# TEST RUNNER INSTALL
RUN git clone --depth=1 https://github.com/2pisoftware/testrunner.git /var/www/testrunner; chown -R www-data.www-data /var/www/testrunner; chmod -R 755 /var/www/testrunner; cd /var/www/testrunner; php composer.phar update;

# SSH ACCESS
#RUN rm -f /etc/service/sshd/down
#RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
#RUN /usr/sbin/enable_insecure_key
#EXPOSE 22

# MYSQL INSTALL AND SETUP
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get -yq install mysql-server-5.7 pwgen 
    #&& \
   # rm -rf /var/lib/apt/lists/* && \
   # rm /etc/mysql/conf.d/mysqld_safe_syslog.cnf && \
   # if [ ! -f /usr/share/mysql/my-default.cnf ] ; then cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf; fi && \
RUN touch /var/lib/mysql/.EMPTY_DB

# LOCALES
RUN locale-gen de_DE.UTF-8;  locale-gen fr_FR.UTF-8; locale-gen ja_JP.UTF-8;  locale-gen es_ES.UTF-8; locale-gen ru_RU.UTF-8; locale-gen gd_GB.UTF-8; locale-gen nl_NL.UTF-8; locale-gen zh_CN.UTF-8;


# Add MySQL scripts
ENV MYSQL_USER=admin MYSQL_PASS=admin ON_CREATE_DB=cmfive STARTUP_SQL=/install.sql


RUN mkdir /etc/service/mysql
EXPOSE 3306

# PHP CONFIG
RUN sed -i 's/^listen\s*=.*$/listen = 127.0.0.1:9000/' /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php\/cgi.log/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php\/cli.log/' /etc/php/7.0/cli/php.ini && \
    sed -i 's/^key_buffer\s*=/key_buffer_size =/' /etc/mysql/my.cnf

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

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
RUN git clone https://github.com/2pisoftware/cmfive-wiki.git /var/www/wiki; ln -s /var/www/wiki/wiki /var/www/cmfive/modules/wiki
# WEBDAV
RUN git clone https://github.com/syntithenai/webdav.git /var/www/webdav; ln -s /var/www/webdav /var/www/cmfive/modules/webdav


ENV TERM xterm

# executable service scripts
RUN chmod +x        /etc/service/phpfpm/run
RUN chmod +x /etc/service/nginx/run
RUN chmod +x /etc/service/mysql/run

#DISABLE apt cleanup
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ENV VIRTUAL_HOST cmfive.docker

RUN mkdir /run/php
#==============================
# Scripts to run Selenium Node
#==============================
COPY \
  ./src/selenium/entry_point.sh \
  ./src/selenium/functions.sh \
    /opt/bin/
    
RUN chmod +x /opt/bin/entry_point.sh; mkdir /etc/service/selenium; ln -s /opt/bin/entry_point.sh /etc/service/selenium/run

# phusion/baseimage init script
CMD ["/sbin/my_init"]
