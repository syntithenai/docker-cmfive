FROM phusion/baseimage
MAINTAINER Steve Ryan <stever@syntithenai.com>

RUN apt-get update && apt-get install -y python-software-properties
RUN add-apt-repository ppa:nginx/stable

RUN apt-get update && apt-get install -y  php5-cli git nginx

RUN mkdir -p /var/log/nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./src/start.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

RUN git clone -b 0-8-0-BRANCH https://github.com/2pisoftware/cmfive.git /var/www/cmfive
COPY ./src/config.php /var/www/cmfive/config.php
RUN mkdir -p /var/www/cmfive/storage; mkdir -p /var/www/cmfive/storage/logs; mkdir -p /var/www/cmfive/storage/backups; mkdir -p /var/www/cmfive/storage/session

RUN git clone https://github.com/2pisoftware/testrunner.git /var/www/testrunner; chmod -R 777 /var/www/testrunner;  chmod -R 777 /var/www/cmfive
RUN cd /var/www/cmfive/system; php composer.phar update;
RUN cd /var/www/testrunner; php composer.phar update;
RUN apt-get install -y php5-mysql curl php5-curl 
RUN apt-get install -y  phantomjs
COPY ./src/environment.cmfive.docker.csv /var/www/testrunner/environment.cmfive.docker.csv
COPY ./src/runcmfivedockertests.sh /runtests.sh
RUN chown -R www-data.www-data /var/www/cmfive
RUN chmod -R 755 /var/www/cmfive

# enable ssh insecure login for dev container
#curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/services/sshd/keys/insecure_key
#chmod 600 insecure_key
# Login to the container
#ssh -i insecure_key root@<IP address>
#in putty use puttygen to convert key to ppk for use as ssh auth key.
RUN rm -f /etc/service/sshd/down;  /etc/my_init.d/00_regen_ssh_host_keys.sh; /usr/sbin/enable_insecure_key

VOLUME /var/www

EXPOSE 80

#DISABLE
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD ["/sbin/my_init"]
