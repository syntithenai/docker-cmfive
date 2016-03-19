FROM 2pisoftware/cmfive
MAINTAINER Steve Ryan <steve@2pisoftware.com>

# CRM INSTALL 
ADD ./id_rsa /root/.ssh/id_rsa
ADD ./id_rsa.pub /root/.ssh/id_rsa.pub
ADD ./known_hosts /root/.ssh/known_hosts
RUN chmod 700 /root/.ssh/id_rsa;  git clone --depth=10  git@bitbucket.org:2pisoftware/2picrm.git /var/www/2picrm; 
RUN ln -s /var/www/cmfive/system /var/www/2picrm/system
ADD ./default /etc/nginx/sites-enabled/default
RUN mkdir -p /var/www/2picrm/cache; mkdir -p /var/www/2picrm/storage; mkdir -p /var/www/cmfive/2picrm/logs; mkdir -p /var/www/2picrm/storage/backups; mkdir -p /var/www/2picrm/storage/session; chown -R www-data.www-data /var/www/2picrm; chmod -R 755 /var/www/2picrm
ADD ./config.php /var/www/2picrm/config.php

# phusion/baseimage init script
CMD ["/sbin/my_init"]
