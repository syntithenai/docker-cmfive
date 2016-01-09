FROM phusion/baseimage
MAINTAINER Steve Ryan <stever@syntithenai.com>

VOLUME /var/www
RUN apt-get update && apt-get install -y python-software-properties
RUN add-apt-repository ppa:nginx/stable

RUN apt-get update && apt-get install -y  php5-cli git nginx

RUN mkdir -p /var/log/nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

ADD ./src/start.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

EXPOSE 80

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD /sbin/my_init
