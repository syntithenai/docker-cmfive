#Cmfive Developer workflow with Docker
## Introduction
As an organisation there are benefits to the development team working with standardised docker images. 
In particular, a stable environment for running tests optimises developer time.
To that end we have have created a cmfive developer toolkit using docker.

- We have a [docker.io image](https://hub.docker.com/r/2pisoftware/cmfive/) that enables a very easy standardised cmfive installation. The image includes browser based tools for file management, git and mysql.
- We have a [git repository](https://github.com/2pisoftware/docker-cmfive) that provides files to build the cmfive docker image. The repository also contains a collection of composer configurations and a docker-manager script to simplify running collections of images.

This document provides details on working with the image and repository.

## Getting started

- [Install docker](https://docs.docker.com/engine/installation) and Kitematic GUI
- Using Kitematic you can click `New` and search the docker hub for cmfive then click to download and run the image. 
  - This is a very large download ~400MB!! 
  - ![kitematic install cmfive](https://raw.githubusercontent.com/2pisoftware/docker-cmfive/master/doc/kitematic_install_cmfive.png)

## Docker container suite

The repository includes composer suites to start a collection of images.
The cmfive composer suite starts containers for web, db, testrunner and selenium. 

- Checkout https://github.com/2pisoftware/docker-cmfive 
- Use bin/docker-manager.sh 
`XX/bin/docker-manager.sh up cmfive mysite
XX/bin/docker-manager.sh down cmfive mysite
` 
There are composer suites for a general webserver and a webdav server included in the repository.
`XX/bin/docker-manager.sh up webdav mydav

The manager suite also provides commands for 

- build
- killall [reallytruly] - reallytruly will stop and remove all running containers, otherwise just cleanup
- clean
- test  

In the cmfive image, the web, db and testrunner all use the cmfive base image so there is little overhead in having multiple hosts. The hosts are split to avoid a problem with circular dependancies in docker compose v1 format. v2 format offers easier network configuration but is not compatible with the proxy approach to virtual hosting described below.

All the compose suites assume that an environment variable DOCKERMANAGER_WEB_ROOT is set to a path on your local filesystem where you store websites which is volume mapped as the www or data folder for the images. 

Before using the cmfive or 2picrm images, the mapped web folder needs to be primed with a cmfive and testrunner installations.
If you run the image without composer as described in the QuickStart section above, you can copy everything you need from the container to your local file system using 
`docker cp cmfivecomplete_1:/var/www C:\Users\User\Desktop\`
OR ssh access as described below.



## Other ways to get started
- [Install docker](https://docs.docker.com/engine/installation) and kitematic GUI
- Use Kitematic to install and run a cmfive container
  
- Alternative install and run the cmfive image
 - You can execute in the docker powershell
   docker run -e VIRTUAL_HOST=cmfive.docker -p 2222:22 -p 3306:3306 -P -v /var/www -d --name=cmfive 2pisoftware/cmfive
 - You can use docker compose file in the repository
   cd /repository
   docker-compose up -d
 - You can use docker manager `dm up cmfive mysite mysite.org.au`
- Another alternative is to build the image using the git repository.
 - ` docker build -t 2pisoftware/cmfive /repository `
 - then use docker run as described above


##	Virtual hosting
As you add containers it can be handy to refer to them by domain name.

1. A DNS proxy will allow wildcard domain configuration (as compared to tweaking hosts entry). Acrylic DNS proxy works well on windows. 
DNS entries need to point to the virtual box IP address on windows.
2. Install and run nginx-proxy docker image using DOCKER CLI powershell. 
  `docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy`
3. Restart your container with VIRTUAL_HOST set as an environment veriable and nginx-proxy will pick up the changes and detect the container port then create virtual host entries for nginx.
  `docker run -e VIRTUAL_HOST=foo.bar.com ...`
For more details see https://hub.docker.com/r/jwilder/nginx-proxy <https://hub.docker.com/r/jwilder/nginx-proxy>

## Security
These images are hopelessly insecure with published default passwords for important services and a published key for root login. 

**DO NOT EXPOSE any of the docker network interfaces to the internet without securing the image!!**


## Container persistence.

Docker has images, containers and volumes.
An image is a base filesystem for a container.

A container is a running (or stopped) instance.
Containers reset their filesystem to the base image on restart.

A volume is is a storage folder that will persist between container restarts.

- Volumes are destroyed when their parent container is destroyed.
- Volumes can be defined in the build or with docker run.
- Volumes are stored in the master linux filesystem so inside virtual box for windows/mac.
- Volumes can be lost when docker engine restarts.

It is possible to mount a volume onto a local filesystem using kitematic or `docker run -v src:target`. In this case the content of the mount point persists no  matter what.
This approach allows platform based tools access to the filesystem eg sourcetree or eclipse.

It is also possibly to explicitly create Data Volumes using   
  `  docker volumes create -name <volume name>  `  
This approach allows the volume to be mounted anywhere in a target image with  
   `docker run -v <volume name>`  

## Access to the container
There are variety of approaches to interacting with a container.

- The recommended approach is using volume mappings to the host.  By using volume mappings, any changes to files are not lost if the container is destroyed for a base image update. This can also be achieved using data volumes.

 For example, to work with /var/www directly on your host system 

  - Copy the www directory to the host system using scp or `docker cp src target`.
  - Remap the host volume back into the container.
   - Click change in the kitematic volume settings for the /var/www volume and select the location you copied the original files as the host path.
   - ![kitematic volumes](https://raw.githubusercontent.com/syntithenai/docker-cmfive/master/doc/kitematic_volumes.png)
   - Alternatively use 
     `docker run -v <\\c\host path>:/var/www <image>`.
   - Alternatively modify the docker-compose.yml file to add the volume and host mapping.
   - The docker container suite requires that an environment variable DOCKERMANAGER_WEB_ROOT is set so that the host mapping is managed by composer.
 
- Using the website 
 - click the link in the kitematic web preview. Cmfive login credentials admin/admin.
 - - ![cmfive login](https://raw.githubusercontent.com/syntithenai/docker-cmfive/master/doc/cmfive_login.png)
 - the website also provides user interfaces for
    - file management using codiad. http://cmfive.docker/codiad with login credentials admin/admin.
    - ![codiad](https://raw.githubusercontent.com/syntithenai/docker-cmfive/master/doc/codiad.png)
    - git management using ungit. http://ungit.docker/ with no authentication required.
    - ![ungit](https://raw.githubusercontent.com/syntithenai/docker-cmfive/master/doc/ungit.png)
    - mysql management using phpmyadmin. http://cmfive.docker/phpmyadmin with login credentials admin/admin.
- Using docker
 - run a shell inside the container
     `docker exec -it <container name> bash`
 - copy files from/to the container
   `docker cp <container:src> <container:dest>`
- using ssh/scp
 - To enable ssh, use kinetic to map a port or ensure your run command maps port 22 to a host port.
 - To login as root, use the key file docker.ppk from the docker-cmfive repository.
- using mysql exposed port 3306 with a sql client like HeidiSql
## Developing with the image



### Codiad IDE

 Codiad is a web based programmers editor.  
 It is available through the web interface as a top level subdirectory  `http://host:port/codiad`. Use login credentials admin/admin. 

Codiad can be installed as a docker image to edit files in any container volume
    `docker run -e VIRTUAL_HOST=codiad.docker -v <\\c\host path>:/opt/codiad/workspace -v /opt/codiad/plugins trobz/codiads`

The /opt/codiad/plugins volume allows mapping of plugin folder from the host system. A collection of most codiad plugins is available as part of the docker-cmfive repository.

### GIT

Git is installed and available from the command line.

Ungit is available as a docker image reinblau/ungit.
 
If you have access to the file system as a host volume mapping, you can run ungit with access to that folder 
    `docker run -e VIRTUAL_HOST=ungit.docker -v <\\c\host path>:/git reinblau/ungit`

When using the ungit UI, you search inside /git for www files.

To use ungit you must first gain shell access to the repository and to allow commit 

    git config user.name "User Name"
    git config user.email "user@2pisoftware.com" <mailto:"user@2pisoftware.com"> 
    git config core.fileMode false 

  Visit http://ungit.docker in a browser

  Enter /git/ into the search bar and look for completions.
  
 - Click enter to load the repository
 - Click plus to save the repository
 - ......

For a user guide see https://www.youtube.com/watch?v=hkBVAi3oKvo

Codiad also provides git workflows

### MySql
PhpMyAdmin is available through the web interface as a top level subdirectory   
http://host:port/phpmyadmin.   
Login credentials admin/admin.  

Mysql port 3306 is exposed in the images so it is possible to map that port to a host port and use a GUI client to connect.

### Tests
Tests can be run using the /runtests.sh script inside the image.
 
 
## Modifying the image
It may be appropriate to update the docker build file to make changes and rebuild the base image.  
The [docker build file](https://raw.githubusercontent.com/syntithenai/docker-cmfive/master/Dockerfile) is available as part of the docker-cmfive repository.   

Checkout and change directory to the docker-cmfive repository then run  
`docker build -t 2pisoftware/cmfive . `  

The image is based on phusion/baseimage. Detailed instructions on adding services, startup scripts and other modifications is available at [phusion.github.io](http://phusion.github.io/baseimage-docker) and [blog](https://github.com/phusion/baseimage-docker)

## Docker 101 
### ARCHITECTURE
            virtual box - used on windows to boot linux
            docker engine daemon managing containers as threads
            image - static filesystem image
                unionfs overlay for stacking images
            container - live enactment of an image
            swarm
                controller
                node
                    containers
                        shipyard
### INSTALL
            Linux
                <https://docs.docker.com/engine/installation/> <https://docs.docker.com/engine/installation/>>
                apt-get install docker.io docker-engine
            Windows/Mac
                There are binary images for windows and mac that include the whole toolbox of - docker machine, docker compose, docker swarm and kitematic GUI.
                You can login to the virtual box machine using ssh to localhost with user docker pw tcuser
                <https://docs.docker.com/engine/installation/windows/> <https://docs.docker.com/engine/installation/windows/>>
### RUN
            kitematic
                Fire up kitematic, click new to create a new container then search for hello-world-nginx and click create.
                Best place to access CLI docker because (at least on windows) key environment is configured for you.
            docker
                COMMANDS
                    Sooner or later Kitematic won't allow you to do what you want and you will need to use the command line tools.
                    docker - manages images and containers
                    commands
                        docker info
                        docker pull <image>
                        docker ps
                        docker run <image> <command>
                        docker build -t <image> .
                        docker exec -it <container> /bin/bash
                        docker inspect -f "{{}NetworkSettings.IPAddress}"
                        docker rm $(docker ps -a -q)
            dockerui docker image
                admin tools for containers and images and networks. more powerful than kitematic
                docker run --name docker-compose-ui -p 5000:5000 -v /Users/User/docks:/opt/docker-compose-projects:rw -v /var/run/docker.sock:/var/run/docker.sock francescou/docker-compose-ui:1.0.RC1
### CUSTOMISING IMAGES
            DockerFile
                scripted OS install/tweak
                each step is cached as an overlay filesystem image so rebuild only needs to implement the build from the point of change
                <https://docs.docker.com/engine/reference/builder/> <https://docs.docker.com/engine/reference/builder/>>
            BASE IMAGE
                phusion.github.io > Baseimage-docker > #intro <http://phusion.github.io/baseimage-docker/#intro> <http://phusion.github.io/baseimage-docker/#intro>>
                REBUILD
                    docker-compose stop;docker build -t syntithenai/cmfive .;docker rm $(docker ps -a -q);docker-compose up -d;docker exec -it dockercmfive_web_1 bash
            COMPOSING CONTAINERS
                docker-compose
                    docker-compose - manages multiple containers and their configuration. Eg spin up mysql, php ,nginx in three containers will port mappings from a config file.
                    stop this compose suite, rebuild the cmfive image, rm any persistent volumes, restart composer suite, run a shell
                    docker-compose stop;docker build -t syntithenai/cmfive .;docker rm $(docker ps -a -q);docker-compose up -d;docker exec -it dockercmfive_cmfiveweb_1 bash
                    <https://docs.docker.com/compose/compose-file/> <https://docs.docker.com/compose/compose-file/>>
                NETWORKS
                dockercompose-ui image
                    GUI for managing containers based on docker-compose files
                    run compose UI
### DEPLOY
            VIRTUAL HOSTING
                1. A DNS proxy will allow wildcard domain configuration (as compared to tweaking hosts entry). Acrylic DNS proxy work well on windows.
                DNS entries need to point to the virtual box IP address on windows.
                2. Install and run nginx-proxy docker image
                    docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
                3. Restart your container with VIRTUAL_HOST set as an environment veriable and nginx-proxy will pick up the changes and detect the container port then create virtual host entries for nginx.
                    docker run -e VIRTUAL_HOST=foo.bar.com ...
                <https://hub.docker.com/r/jwilder/nginx-proxy/> <https://hub.docker.com/r/jwilder/nginx-proxy/>>
                Voila
            DOCKER HUB
                what follows SHOULD work BUT https://github.com/docker/hub-feedback/issues/473 <https://github.com/docker/hub-feedback/issues/473>
                docker login
                docker push <mylogin>/<image>
                docker pull <mylogin>/<image>
            MICROSERVICES
                ideally services are split into containers
                    distributed networking
                    load balancing
                    monitoring
            SWARM
                shipyard
### CLEANUP
            docker is prone to leave images lying around and eat it's 20G limit
            #containers
                docker rm $(docker ps -a -q)
            #images
                docker rmi $(docker images -q --filter "dangling=true")
            # cron job - http://blog.yohanliyanage.com/2015/05/docker-clean-up-after-yourself/ <http://blog.yohanliyanage.com/2015/05/docker-clean-up-after-yourself/> <http://blog.yohanliyanage.com/2015/05/docker-clean-up-after-yourself/> <http://blog.yohanliyanage.com/2015/05/docker-clean-up-after-yourself/>
                docker rm -v $(docker ps -a -q -f status=exited)
                docker rmi $(docker images -f "dangling=true" -q)
                docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes
                
                docker rm -v $(docker ps -a -q -f status=exited)
                docker rmi $(docker images -f "dangling=true" -q)
                docker volume rm $(docker volume ls| awk '{ print $2; }')
            <https://github.com/meltwater/docker-cleanup> <https://github.com/meltwater/docker-cleanup>> <https://github.com/meltwater/docker-cleanup>>
### LINKS
            <https://github.com/wsargent/docker-cheat-sheet> <https://github.com/wsargent/docker-cheat-sheet>>
            jonathan.bergknoff.com > Journal > Building-good-docker-images <http://jonathan.bergknoff.com/journal/building-good-docker-images> <http://jonathan.bergknoff.com/journal/building-good-docker-images>>
            crosbymichael.com > Dockerfile-best-practices <http://crosbymichael.com/dockerfile-best-practices.html> <http://crosbymichael.com/dockerfile-best-practices.html>>
## Notes
        # To allow commit change directory into any repositories to be managed by ungit and execute
        git config user.name "Steve"
        git config user.email "steve@2pisoftware.com" <mailto:"steve@2pisoftware.com">
        git config core.fileMode false
        #ignore permission diffs
        git config --global core.fileMode false
        # show composer package version
        php composer.phar show -i codeception/codeception
        # minimum git download
        git clone --depth=1 <remote_repo_URL>
        #TEST find
        #service
        find . -name *Service.php
        #objects
        find . -name models|grep -v docs|grep cmfive|xargs ls -l|grep -v Service
        <https://github.com/2pisoftware/cmfive.git>
        # markdown reference
        http://daringfireball.net/projects/markdown/basics

https://help.github.com/articles/dealing-with-line-endings/
