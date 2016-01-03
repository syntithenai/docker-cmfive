# docker-cmfive
docker scripts to install cmfive
0. Install docker engine, docker compose and kitematic https://docs.docker.com/engine/installation/
1. For Windows, run the docker quickstart terminal to initialise a VM. For other OS ....
2. In the terminal type ./run.sh
3. Start kitematic, select the web image, the use the ports tab in the settings to discover the IP address of the instance.
4. Edit your hosts file to map the ip address to cmfive.docker
5. Visit http://cmfive.docker:8090 in a browser (or http://cmfive.docker/phpMyAdmin:8090)  use admin/admin for access in both cases

* TODO Ideally the stuff in run.sh would be part of the Dockerfile to build cmfive
