# 2PiSoftware Continuous Integration Systems

## Overview

The following document describes the triggers, components and processes involved in our automated continuous integration systems.

Actions on our repositories ie push, tag, branch trigger `webhooks` on our `code` server (code.2pisoftware.com).

Actions typically build and run Docker images.

Some actions may trigger execution of the test suite with email notification to relevant users.

Some actions may trigger deployment of the image to the code server as a virtual host or to another server or to Amazon EBS.

[More detail on working with the cmfive docker image](README.md)

## Developer perspective

Developers can create a deployment repository for a client project that extends the cmfive or crm image. Using a Dockerfile to add custom modules, change database connection or other features, the image can be built and run locally in the same environment as test and production.

We have our own docker registry on the code server. The cmfive images built and hosted there are kept up to date with develop and master for the cmfive and cmfive-dev (and crm) images respectively. The docker hub images for cmfive and cmfive-dev are also kept up to date with pushes to git.

By following the naming convention of XXX_deploy and adding a file Dockrrun.aws, the repository can be used to deploy to elastic beanstalk for production hosting when a deployment repository is tagged.

Developers have easy access to a test environment with the dev images.

Testing becomes part of our workflow with email notification of test results on all commits to develop.

There are lots more possibilities for git workflows...


## Triggers

The github and bitbucket web admin pages allow for adding webhooks. 

To enable a repository to trigger CI events,  add the webhook http://webhook.code.2pisoftware.com configured to notify for all git actions.

The CI system will only respond to repositories that have a match in the webhooks configuration file.

At the time of writing, the CI system is configured to 

- respond to push requests on the `master` branch of the `cmfive` and `2picrm` repositories by 
	- building the associated 2pisoftware/cmfive or 2pisoftware/crm image.
- respond to push requests on the `development` branch of the `cmfive` and `2picrm` repositories by 
	- building the associated 2pisoftware/cmfive-dev or 2pisoftware/crm-dev image.
	- starting a container from the image and running the test suite and notifying the user who pushed the changes about the success or failure of the test suite.

- respond to tag triggers on `deployment repositories` by building, testing and deploying the repository to AWS Elastic Beanstalk.


Other useful triggers could include
	- tagging the images when the source repositories are tagged.
	- creating a development site when a branch is created.
	- destroy a development site when a branch is deleted.
	
...

The CI configuration file allows for custom scripts to be associated with trigger events per repository.


## Components

### Servers
Servers involved in our CI process include

- Git Hosting on github or bitbucket.
- The code.2pisoftware.com server which is used to manage webhooks fro git hosting, build images, act as a docker registry server and host testing and development containers. 
- AWS servers using elastic beanstalk to configure docker images for live deployments.


### Source Code Repositories

Source repositories involved in our CI process include

- Application Repositories including `cmfive`, `2picrm`, `wiki`, `webdav` and `hosting` that provide application components.
- Deployment Repositories including `crm_2pisoftware_deploy`, `webhooks_deploy`, `cmfive_deploy`, `cmfive-dev_deploy`, 	2picrm_deploy`,`2picrm-dev_deploy` which include a Dockerfile (and resources) for building an image and optionally a Dockerrun.aws for deployment to AWS.
- Management Repositories including softare to drive the CI process.  Currently all the CI management software lives in the `docker-cmfive` repository. All software to assist with running tests is in the `testrunner` repository

#### Base Deployment Repositories

- `cmfive_deploy` provides a complete cmfive environment in a single docker image. It is used to build the image `2pisoftware/cmfive`.
- `cmfive-dev_deploy` provides a complete cmfive development environment in a single docker image. It includes vnc, selenium and the test run suite. It is used to build the image `2pisoftware/cmfive-dev`.
- `2picrm_deploy` extends `cmfive_deploy` to add the 2picrm modules. It is used to build the image `2pisoftware/crm`.
- `2picrm-dev_deploy` extends `cmfive-dev_deploy` to add the 2picrm modules within a testing environment. It is used to build the image `2pisoftware/cmfive-dev`.

#### Client Deployment Repositories

- `crm_2pisoftware_deploy` is the deployment repository for our 2pisoftware staff crm. It is not built locally but deployed as a Dockerfile and Dockerrun.aws combination. The Dockerfile is based from the `2pisoftware/crm:latest` image and customises the Database connection details. This is a typical template for client deployments.

- `webhooks_deploy` provides a Dockerfile that integrates the webhook handling script in the `docker-cmfive` repository and an nginx web server.
	- It is used to build the `2pisoftware/webhooks` image. `docker build -t 2pisoftware/webhooks .`
	- The webserver responds to valid webhook requests by writing jobs files that are shared back to the host filesystem for access with root permissions by a cron job (also part of the `docker-cmfive` repository). 
	- On the code server filesystem, docker-cmfive is installed in the /opt folder.
	- To run the webhooks image, mount the host filesystem version of `docker-cmfive`. `docker stop webhooks; docker rm webhooks; docker run -d -P --restart=always --name=webhooks -e VIRTUAL_HOST=webhook.code.2pisoftware.com -v /opt/docker-cmfive:/opt/docker-cmfive webhooks`
	- The webhooks repository works together with the script docker-cmfive/webhooks/cronjob.php running as root from cron to enact the job files.



Client deployment repositories can set environment variables to control the behavior of the parent image.
[More detail on working with the cmfive docker image](README.md)

`
# DB CONNECTION/SETUP
RDS_HOSTNAME=localhost 
RDS_USERNAME=admin 
RDS_PASSWORD=admin 
RDS_DB_NAME=cmfive 
STARTUP_SQL=/install.sql

# ON BUILD
GIT_VERSION_CMFIVE=master 
# ON IMAGE START
GIT_CMFIVE_BRANCH=
GIT_CMFIVE_TAG=

# FOR DEVELOPMENT IMAGES PRECONFIGURE GIT
GIT_USER_NAME=
GIT_USER_EMAIL=
`


#### Management Repositories

##### CI scripts `docker-cmfive`

! This repository used to contain deploy images for cmfive. These have all been refactored into individual deployment repositories.

Relevant files in the `docker-cmfive` repository include
- webhooks
	- www
		- index.php - webserver glue
		- config.php   - list of allowed repositories and trigger scripts.
		- WebHookHandler.php - controller for webhook single action.
		- WebHookRequest.php - encapsulate Webhook request interpretation for bitbucket and github.
	- cronjob.php  (run with php -f ) enact job files based on config.php
- bin
   - DockerManager scripts currently defunct.


## Setup of the code server

```
# Install docker  OR choose an Amazon instance type that includes docker
# apt-get install docker-engine
#Install nginx-proxy image for virtual hosting
docker run -d -p 80:80 --restart=always -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
#Install /opt/docker-cmfive management scripts
cd /opt; git clone https://github.com/2pisoftware/docker-cmfive.git
#Install webhooks image. 
docker stop webhooks; docker rm webhooks; docker run -d -P --restart=always --name=webhooks -e VIRTUAL_HOST=webhook.code.2pisoftware.com -v /opt/docker-cmfive:/opt/docker-cmfive webhooks
#Install plain webserver at code.2pisoftware.com with host volume to /var/www
docker stop code.2pisoftware.com; docker rm code.2pisoftware.com ; docker run --name code.2pisoftware.com -v /var/www:/usr/share/nginx/html -d -P -e VIRTUAL_HOST=code.2pisoftware.com nginx
```
For the cronjob add the line `* *     * * *   root    /opt/docker-cmfive/webhooks/cronjob.sh >> /dev/null 2>&1`


### Registry Server
The 2pisoftware docker registry server is available at `code.2pisoftware.com:5000`

It hosts images for 2pisoftware/cmfive, 2pisoftware/cmfive-dev, 2pisoftware/2picrm and 2pisoftware/2picrm-dev.

A username and password is required to access the registry. Details on how to add a user are below.

#### Install SSL Certificates

The registry server requires an SSL certificate. A process for retrieving a letsencrypt certificate follows.

As root

```
# 1. Install certbot 
mkdir /opt/certbot; cd /opt/certbot; wget https://dl.eff.org/certbot-auto;  chmod a+x certbot-auto
# 2. Run once to install 
# Choose the files in webroot option and select webroot as /var/www
# Ensure that the vanilla webserver for code.2pisoftware.com is running as described in install steps above
/opt/certbot/certbot-auto
# 3. Run again to obtain a certificate. Enter the domain code.2pisoftware.com.
/opt/certbot/certbot-auto certonly 
```

#### Install registry

```
# grab the code
cd /opt;
git clone https://steve_ryan@bitbucket.org/steve_ryan/registry_deploy.git (you will need user/pass and bitbucket access to this repo)
# build the image
cd /opt/registry_deploy
docker build -t 2pisoftware/registry . ;
# copy the certificates
cp /etc/letsencrypt/live/code.2pisoftware.com/* /opt/registry_deploy/certs/
# run the registry with host volume mappings
docker stop registry; docker rm registry; docker run -d -p 5000:5000 --restart=always --name registry -v /opt/registry_deploy/data:/var/lib/registry -v /opt/registry_deploy/auth:/auth   -v /opt/registry_deploy/certs:/certs  2pisoftware/registry
```
#### Auto renew SSL certificates
Add a cron job twice a day as root to generate certs and copy to docker registry

`18 1,14 * * *   root     /home/ubuntu/certbot-auto renew --quiet --no-self-upgrade; cp /etc/letsencrypt/live/code.2pisoftware.com/* /opt/docker-cmfive/registry/certs/`

#### Maintain user access to the registry

The auth file /opt/registry_deploy/auth/htpasswd is mounted on the host so 
`htpasswd /opt/registry_deploy/auth/htpasswd <newUser>` run on the code server will ask for password and add a user.

Edit the file to remove users.


### Ssh keys

ssh deployment keys are required for automated access to private repositories.

1. Deployment repositories may contain deployment keys. For example 2picrm_deploy includes the deployment keys to the 2picrm repository. See the Dockerfile for an example of using a deployment key.

It is essential that deployment repositories that contain keys are private repositories themselves to protect the private key.

2. Private deployment repositories will require their own ssh keys so that webhook tag requests can autonomously checkout the latest version onto the code server.

- Add http://webhook.code.2pisoftware.com to the webhooks UI for the repository on github or bitbucket.
- To create a key set `ssh-keygen -t rsa -b 4096 -C "secure key"`
- Create a config section for the repository and include the public key.  Assuming you chose the default names id_rsa and id_rsa.pub, copy the contents of the private key id_rsa to the deployment keys web UI on bitbucket or github.
- Copy the contents of the public key id_rsa.pub to a section matching the repository URL of the config file /opt/docker-cmfive/webhooks/www/config.php 
		eg 
		```
			'git@bitbucket.org:steve_ryan/crm_2pisoftware_deploy.git' => [
		'deploymentkey' =>'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZCOPdhCvqsBqoke37Kfk/9uoMYEt0J8987yENfPqAdxiQl+ZqVGhiIr2IgmBxPhkU+T8zJ/ZqytviR75HRoN/PFpSuBBN9AHjPvOlu0j/9BRexd0qx+5xMyLzr3tbddDCiEcXkt767EaGKZnPHNDew8ot5wdEV5prUIKhJcs5l6WKN6ZFBTTJ88N82ik6Fg2lRDDJuMZfU5PWjapLb0u5m/AfFzoBfC2IHZLQYHdYxSF4FMkdK7c+9Z0mAXLcNVBPWTiuogeuoD9EU/ENInmc/qYgSmpQb84brlNv5Ci/CNijP6WGT8Ic3NDw5jKY5uzGHleDgA9XICPPop7iIdl5 ubuntu@ip-172-31-15-105',
		'triggers' => [
			'tag' =>'',
			'push' => [
				'master'=>''
			]
		]
	],

- 		```



