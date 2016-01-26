This repository contains a Dockerfile for building a cmfive nginx image file
It also includes a docker-compose.yml file to bring multiple services up together.


docker 101
    ARCHITECTURE
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
    INSTALL
        Linux
			https://docs.docker.com/engine/installation/
            apt-get install docker.io docker-engine
        Windows/Mac
            There are binary images for windows and mac that include the whole toolbox of - docker machine, docker compose, docker swarm and kitematic GUI.
            You can login to the virtual box machine using ssh to localhost with user  docker pw tcuser
			https://docs.docker.com/engine/installation/windows/
    RUN
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
    CUSTOMISING IMAGES
        DockerFile
            scripted OS install/tweak
            each step is cached as an overlay filesystem image so rebuild only needs to implement the build from the point of change
            https://docs.docker.com/engine/reference/builder/
        BASE IMAGE
            phusion.github.io > Baseimage-docker > #intro <http://phusion.github.io/baseimage-docker/#intro>
            REBUILD
                docker-compose stop;docker build -t syntithenai/cmfive .;docker rm $(docker ps -a -q);docker-compose up -d;docker exec -it dockercmfive_web_1 bash
        COMPOSING CONTAINERS
                docker-compose
                    docker-compose - manages multiple containers and their configuration. Eg spin up mysql, php ,nginx in three containers will port mappings from a config file.
                    stop this compose suite, rebuild the cmfive image, rm any persistent volumes, restart composer suite, run a shell
                    docker-compose stop;docker build -t syntithenai/cmfive .;docker rm $(docker ps -a -q);docker-compose up -d;docker exec -it dockercmfive_cmfiveweb_1 bash
                    https://docs.docker.com/compose/compose-file/
                NETWORKS
                dockercompose-ui image
                    GUI for managing containers based on docker-compose files
    DEPLOY
        VIRTUAL HOSTING
            1. A DNS proxy will allow wildcard domain configuration (as compared to tweaking hosts entry). Acrylic DNS proxy work well on windows.
            DNS entries need to point to the virtual box IP address on windows.
            2. Install and run nginx-proxy docker image
                docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
            3. Restart your container with VIRTUAL_HOST set as an environment veriable and nginx-proxy will pick up the changes and detect the container port then create virtual host entries for nginx.
                docker run -e VIRTUAL_HOST=foo.bar.com  ...
            https://hub.docker.com/r/jwilder/nginx-proxy/
            Voila
        DOCKER HUB
			what follows SHOULD work BUT https://github.com/docker/hub-feedback/issues/473
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
    CLEANUP
        docker is prone to leave images lying around and eat it's 20G limit
        #containers
            docker rm $(docker ps -a -q)
        #images
            docker rmi $(docker images -q --filter "dangling=true")
        # cron job  - http://blog.yohanliyanage.com/2015/05/docker-clean-up-after-yourself/ <http://blog.yohanliyanage.com/2015/05/docker-clean-up-after-yourself/>
            docker rm -v $(docker ps -a -q -f status=exited)
            docker rmi $(docker images -f "dangling=true" -q)
            docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes
        <https://github.com/meltwater/docker-cleanup>



https://github.com/wsargent/docker-cheat-sheet
http://jonathan.bergknoff.com/journal/building-good-docker-images
http://crosbymichael.com/dockerfile-best-practices.html
