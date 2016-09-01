# 2PiSoftware Continuous Integration Systems


## Technical Overview


### Components

#### Servers

Servers involved in our CI process include

- Git Hosting on github or bitbucket.
- The code.2pisoftware.com server which is used to manage webhooks fro git hosting, build images, act as a docker registry server and host testing and development containers. 
- AWS servers using elastic beanstalk to configure docker images for live deployments.


#### Source Code Repositories

Source repositories involved in our CI process include

- Application Repositories including `cmfive`, `2picrm`, `wiki`, `webdav` and `hosting` that provide application components.
- Deployment Repositories including `crm.2pisoftware.com_deploy`, `webhooks_deploy`, `cmfive_deploy`, `cmfive-dev_deploy`, 	`2picrm_deploy`,`2picrm-dev_deploy` which include a Dockerfile (and resources) for building an image and optionally a Dockerrun.aws for deployment to AWS.
- Management Repositories including software to drive the CI process.  The `webhooks_deploy` repository includes all the CI management software. The `registry_deploy` repository includes software for the 2pi software docker registry. All software to assist with running tests is in the `testrunner` repository

##### Base Deployment Repositories

- `cmfive_deploy` provides a complete cmfive environment in a single docker image. It is used to build the image `2pisoftware/cmfive`.
- `cmfive-dev_deploy` provides a complete cmfive development environment in a single docker image. It includes vnc, selenium and the test run suite. It is used to build the image `2pisoftware/cmfive-dev`.
- `2picrm_deploy` extends `cmfive_deploy` to add the 2picrm modules. It is used to build the image `2pisoftware/crm`.
- `2picrm-dev_deploy` extends `cmfive-dev_deploy` to add the 2picrm modules within a testing environment. It is used to build the image `2pisoftware/cmfive-dev`.

##### Client Deployment Repositories

- `crm_2pisoftware_deploy` is the deployment repository for our 2pisoftware staff crm. It is not built locally but deployed as a Dockerfile and Dockerrun.aws combination. The Dockerfile is based from the `2pisoftware/crm:latest` image and customises the Database connection details. This is a typical template for client deployments.

- `webhooks_deploy` provides a Dockerfile that integrates the webhook handling script in the `docker-cmfive` repository and an nginx web server.
	- It is used to build the `2pisoftware/webhooks` image. `docker build -t 2pisoftware/webhooks .`
	- The webserver responds to valid webhook requests by writing jobs files that are shared back to the host filesystem for access with root permissions by a cron job (also part of the `docker-cmfive` repository). 
	- On the code server filesystem, docker-cmfive is installed in the /opt folder.
	- To run the webhooks image, mount the host filesystem version of `docker-cmfive`. `docker stop webhooks; docker rm webhooks; docker run -d -P --restart=always --name=webhooks -e VIRTUAL_HOST=webhook.code.2pisoftware.com -v /opt/docker-cmfive:/opt/docker-cmfive webhooks`
	- The webhooks repository works together with the script docker-cmfive/webhooks/cronjob.php running as root from cron to enact the job files.

#### Deployment Repositories

Developers can create a deployment repository for a client project that extends the cmfive or crm image. 

List images hosted on our registry at  https://code.2pisoftware.com:5000/v2/_catalog?n=10

Clear all images from the registry  `docker stop registry; rm -rf /opt/registry_deploy/data/docker/; docker start registry`

Any repository with a Dockerfile in its root folder can be built an run locally.

Where a repository is intended for a specific deployment scenario, the convention of appending `_deploy` to the repository name clearly identifies such repositories.

To enable deployment to AWS EB, a repository must
- include the standard Dockerrun.aws file 
- EXPOSE at least one port in the Dockerfile
- include a CMD
- run `eb init` in the root of the repository then add and commit files in the `.elasticbeanstalk` folder. (after removing entry in .gitignore)

Client deployment repositories can set environment variables to control the behavior of the parent image.
[For more detail on working with the cmfive docker image see the README](README.md)

```
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
```


#### Management Repositories

##### CI scripts `webhooks_deploy`

The webhooks_deploy repository is installed on the code server and used to provide a cron job and sharing job queue files with the webhooks_deploy instance.

Relevant files in the `docker-cmfive` repository include
- src/webhooks
	- config.php   - list of allowed repositories and trigger scripts.
	- www
		- index.php - webserver glue
		
		- WebHookHandler.php - controller for webhook single action.
		- WebHookRequest.php - encapsulate Webhook request interpretation for bitbucket and github.
	- cronjob.php  (run with php -f ) enact job files based on config.php
- jobs/*   - job queue

###### Configuration

The actions taken by the CI system can be controlled by a configuration file webhooks_deploy/src/webhooks/config.php

The configuration allows custom scripts to be attached per repository and per git trigger. Custom scripts can be built using shared component scripts for common actions.

The configuration allows for a deployment key to be specified for a repository for automated checkout of private repositories.

Variables are added to the environment in which the trigger scripts are run including

- WEBHOOKBUILD_FOLDER
- WEBHOOKBUILD_NAME 
- WEBHOOKBUILD_CONTAINERNAME
- WEBHOOKBUILD_DOMAINNAME
- WEBHOOKBUILD_TAG

eg
```
$webHookConfig['repositories']=[
	# cmfive 
	'git@github.com:2pisoftware/cmfive.git' =>[
		'deploymentkey' =>'sAQABAAABAQDZCOPdhCvqsBqoke37Kfk/9uoMYEt0J8987yENfPqAdxiQl+ZqVGhiIr2IgmBxPhkU+T8zJ/ZqytviR75HRoN/PFpSuBBN9AHjPvOlu0j/9BRexd0qx+5xMyLzr3tbddDCiEcXkt767EaGKZnPHNDew8ot5wdEV5prUIKhJcs5l6WKN6ZFBTTJ88N82ik6Fg2lRDDJuMZfU5PWjapLb0u5m/AfFzoBfC2IHZLQYHdYxSF4FMkdK7c+9Z0mAXLcNVBPWTiuogeuoD9EU/ENInmc/qYgSmpQb84brlNv5Ci/CNijP6WGT8Ic3NDw5jKY5uzGHleDg',
		'triggers' => [
			'tag' => ['
				# use cmfive_deploy repository to build image
				git clone git@bitbucket.org:2pisoftware/cmfive_deploy.git $WEBHOOKBUILD_FOLDER
				cd $WEBHOOKBUILD_FOLDER
				docker build -t $WEBHOOKBUILD_NAME .
				rm -rf $WEBHOOKBUILD_FOLDER
				docker stop $WEBHOOKBUILD_CONTAINERNAME
				docker rm $WEBHOOKBUILD_CONTAINERNAME
				docker run --name=$WEBHOOKBUILD_CONTAINERNAME -d -P -e VIRTUAL_HOST=$WEBHOOKBUILD_DOMAINNAME $WEBHOOKBUILD_TAG &
				# AWS EB DEPLOY
				eb init --profile=eb-cli -r <YOURREGION> -k <YOURSSHKEYPAIR> --platform="Docker 1.11.1"
				eb create -ip code.2pisoftware.com_registry
			'],

```

### For AWS EB 

- copy the file Dockerun.aws from the cmfive_deploy repository into the repository root folder.
- run eb init in the repository root folder.
	- `eb init --profile=eb-cli -r <YOURREGION> -k <YOURSSHKEYPAIR> --platform="Docker 1.11.1"`
	- authentication credentials will be sourced from /root/.aws/config prepared in the AWS install.
	- the eb init command should return successfully without asking questions.





## Creating a Deployment Repository

### Quickstart
- create and clone a repository named <XXXX>_deploy
- create a file named Dockerfile in the repository root folder
	- specify a base image
	- ADD any resource file used to customise the image.
	- ........
- use bitbucket or github web UI to add webhook
- create a deployment script and add it to the webhooks config file !!! (?? HOSTING MODULE)
	- use some of the resource scripts(see the config file)  to simplify writing your deployment scripts


### Overview

A deployment repository is created for each client project that is part of our CI framework.

The only way to update a clients website is to tag their deployment repository.

The deployment repository includes a top level Dockerfile that typically extends our hosted cmfive or crm image, customising the config file and adding modules like the wiki.

Where a repository is intended for a specific deployment scenario, the convention of appending `_deploy` to the repository name clearly identifies such repositories.

The following example is based on the Dockerfile used to build the 2pisoftware/crm image and shows a number of features.

- base image 2pisoftware/cmfive:<TAG>
- set database connection parameters. Note that the config file needs to include the same credentials or source them from the environment as per the config file included in the image.
- first boot install scripts can be disabled by creating flag files.
- including a deployment key for private source code inside this deployment repository
- updating composer from a docker file
- specifying VOLUMES for persistence between image reboots. Note that specifying a VOLUME in an image that could be further used as a base image makes it impossible to ADD files inside the VOLUME paths in derived images.
- All Dockerfiles must include a CMD
- Repositories used for AWS deployment must EXPOSE at least one port.

```
FROM 2pisoftware/cmfive:latest
# database connection
ENV RDS_HOSTNAME=localhost RDS_USERNAME=admin RDS_PASSWORD=admin RDS_DB_NAME=cmfive STARTUP_SQL=/install.sql
# site config
ADD config.php /var/www/cmfive/config.php

# skip main setup
# RUN touch /cmfive_install_complete
# OR just skip databases import
# RUN touch /cmfive_install_db_complete

# deployment key for 2picrm
ADD id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa; 
RUN touch /root/.ssh/known_hosts; 
RUN ssh-keyscan -T 60 bitbucket.org >> /root/.ssh/known_hosts
# clone 2picrm
RUN git clone --depth=1 git@bitbucket.org:2pisoftware/2picrm.git /opt/2picrm 
RUN cp -a /opt/2picrm/modules/crm /var/www/cmfive/modules  
RUN cp -a /opt/2picrm/modules/staff /var/www/cmfive/modules

# COMPOSER UPDATE FOR NEW MODULES (migrations are run on first boot)
RUN  export HOME=/var/www; cd /var/www/cmfive; chmod 755 /var/www/cmfive/system/composer.json; php -f /updatecomposer.php; cat /var/www/cmfive/system/composer.json; cd /var/www/cmfive/system; php composer.phar update; 

# persist between reboots
VOLUMES ['/data','/var/lib/mysql']

# REQUIRED !!!
EXPOSE 80 443
# from phusion/baseimage init script
CMD ["/sbin/my_init"]
```




### For private repositories

- generate key pair
- upload public key to bitbucket or github as a deployment key.
- include the private key in the webhooks config file.







## Install Instructions for the CI server (code.2pisoftware.com)


### AWS Install

Create an AWS user that will be used for autonomous deployments.
Ensure the user has access policies for EC2 and EB.
Download the security credentials for this user and create a file in /root/.aws/config.yml that includes these details.

```
[profile eb-cli]
aws_access_key_id = AKIAJV65WUVB36MHEHUA
aws_secret_access_key = jFIcUj5lyy7K18RasdfasdfqM3esUi3wSC07Two8vUqKoPAq05

```


Install eb-cli


#### Registry Server

After installing the registry on the server and adding a user as described below.
- login to the registry `docker login code.2pisoftware.com:5000`
- Upload a (modified to remove auth key) version of the newly created auth config file to AWS S3.
- Create an IAM security role named 2pi_docker_registry with S3 RO access and an inline policy to enable getObject on the uploaded file (arn:aws:s3::::codeserver/config.json).
- Use the security role in combination with the eb create command  `eb create -ip 2pi_docker_registry` in developing deployment scripts.
- See [Use Private Docker Repositories with AWS Elastic Beanstalk](https://www.youtube.com/watch?v=pLw6MLqwmew)




### Server Install
```
# Install docker  OR choose an Amazon instance type that includes docker
# apt-get install docker-engine

#Install nginx-proxy image for virtual hosting
docker run -d -p 80:80 --restart=always -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy

#Install and build and run webhooks image. 
cd /tmp
git clone https://2pisoftware@bitbucket.org/steve_ryan/webhooks_deploy.git
cd webhooks_deploy;
docker stop webhooks; docker rm webhooks; docker run -d -P --restart=always --name=webhooks -e VIRTUAL_HOST=webhook.code.2pisoftware.com -v /opt/webhooks_deploy/src/webhooks/www:/var/www/cmfive/ -v /opt/webhooks_deploy/jobs:/var/www/cmfive/jobs  2pisoftware/webhooks

#Install plain webserver at code.2pisoftware.com with host volume to /var/www
docker stop code.2pisoftware.com; docker rm code.2pisoftware.com ; docker run --name code.2pisoftware.com -v /var/www:/usr/share/nginx/html -d -P -e VIRTUAL_HOST=code.2pisoftware.com nginx
```
For the cronjob add the line `* *     * * *   root    /opt/webhooks_deploy/src/webhooks/cronjob.sh >> /dev/null 2>&1`

and 
`chmod +x /opt/webhooks_deploy/src/webhooks/cronjob.sh`

#### Registry Server
The 2pisoftware docker registry server is available at `code.2pisoftware.com:5000`

It hosts images for 2pisoftware/cmfive, 2pisoftware/cmfive-dev, 2pisoftware/2picrm and 2pisoftware/2picrm-dev.

A username and password is required to access the registry. Details on how to add a user are below.

##### Install SSL Certificates

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
/opt/certbot/certbot-auto certonly -a webroot --webroot-path=/var/www -d code.2pisoftware.com
```

##### Install registry

```
# grab the code
# copy the certificates
mkdir -p /opt/registry_deploy/certs/
cp /etc/letsencrypt/live/code.2pisoftware.com/* /opt/registry_deploy/certs/
# run the registry with host volume mappings
cd /opt/registry_deploy
docker stop registry; docker rm registry; docker run -d -p 5000:5000 --restart=always --name registry -v `pwd`/data:/var/lib/registry -v `pwd`/auth:/auth -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=2pi Docker Registry" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd  -v `pwd`/certs:/certs  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/fullchain.pem -e REGISTRY_HTTP_TLS_KEY=/certs/privkey.pem  registry:2
```

##### Auto renew SSL certificates

Add a cron job twice a day as root to generate certs and copy to docker registry

`18 1,14 * * *   root     /home/ubuntu/certbot-auto renew --quiet --no-self-upgrade; cp /etc/letsencrypt/live/code.2pisoftware.com/* /opt/docker-cmfive/registry/certs/`

##### Maintain user access to the registry

To add users 

`docker run --entrypoint htpasswd registry:2 -Bbn USERXXX  PASSXXX > auth/htpasswd`
  
Edit the file to remove users.


#### Ssh keys

ssh deployment keys are required for automated access to private repositories.

To create a key run  `ssh-keygen -t rsa -b 4096` then copy the contents of the private key file to the settings for deployment keys in github or bitbucket. 

!!! Be careful to choose a unique name for your keys so you don't override the default keys  in ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub. A good convention is to store the keys in the /root/.ssh/<sameNameAsRepository>

1. Deployment repositories may contain deployment keys. For example 2picrm_deploy includes the deployment keys to the 2picrm repository. See the Dockerfile for an example of using a deployment key.

It is essential that deployment repositories that contain keys are private repositories themselves to protect the private key.

2. Private deployment repositories will require their own ssh keys so that webhook tag requests can autonomously checkout the latest version onto the code server.

Copy the contents of the private deployment key to a section matching the repository URL of the config file /opt/docker-cmfive/webhooks/www/config.php 
eg
 
```
			'git@bitbucket.org:2pisoftware/crm_2pisoftware_deploy.git' => [
		'deploymentkey' =>'Lzr3tbddDCiEcXkt767EaGKZnPHNDew8ot5wdEV5prUIKhJcs5l6WKN6ZFBTTJ88N82ik6Fg2lRDDJuMZfU5PWjapLb0u5m/AfFzoBfC2IHZLQYHdYxSF4FMkdK7c+9Z0mAXLcNVBPWTiuogeuoD9EU/ENInmc/qYgSmpQb84brlNv5Ci/CNijP6WGT8Ic3NDw5jKY5uzGHleDgA9XICPPop7iIdl5',
		'triggers' => [
			'tag' =>'',
			'push' => [
				'master'=>''
			]
		]
	],

```



## Security

Autonomously triggering deployment processes clearly needs strong protection.

Github offers authentication based on a shared secret.
Bitbucket offers IP ranges.

The deployment process requires the use of encryption keys which are in some cases stored in (private) repositories.
Developers must be vigilant not to leave keys lying around.





-==========================================================

## Presentation

###  Amazon Web Services (AWS) Deployment Using Docker

An overview of the 2pisoftware continuous integration (CI) services.

Pushing code to our GIT repositories configured for our CI process triggers actions on the code server. 

The actions taken are customisable per repository and git action (push/tag/pull request) and can include
- building a docker image and pushing it to a registry server.
- running a docker image on the code server and running tests on it
- deploying to AWS based on an image on our registry server.


GIT (bitbucket or github)
	---->	CI Server (code.2pisoftware.com)
		--->	Registry Server  (docker images code.2pisoftware.com:5000)
			----> AWS Elastic Beanstalk (EB) hosting

### WHY

Access to docker images including up to date source code.
Stability in the deployment process. Rollback.
Consistency between development and production environments.
Testing becomes part of our workflow. Code must pass tests before images can be built.
Access to AWB EB features including clustered scaling and monitoring.

### Repositories

Source repositories involved in our CI process include

- Application Repositories including `cmfive`, `2picrm`, `wiki`, `webdav` and `hosting` that provide application components.
- Deployment Repositories including `crm_2pisoftware_deploy`, `webhooks_deploy`, `cmfive_deploy`, `cmfive-dev_deploy`, 	`2picrm_deploy`, `2picrm-dev_deploy` which include a Dockerfile (and resources) for building an image and optionally a Dockerrun.aws for deployment to AWS.
- Management Repositories including software to drive the CI process.  The `webhooks_deploy` repository includes software for managing the webhook request and triggering actions. All software to assist with running tests is in the `testrunner` repository


### GIT Triggers

To initiate triggers for a repository add http://webhook.code.2pisoftware.com using the bitbucket or github web UI.

We have recently discussed taking up GIT flow as a process. 

In doing so, the `develop` branch becomes our new main point of activity.  
New features are developed on a branch of the `develop` branch and merged back to `develop`

The CI system can be configured to trigger arbitrary scripts based on the repository and trigger event.


Current scenarios include 

- push on `testrepository_bitbucket` master branch
	- use the `testrepository_bitbucket` repository to build the `testrepository_bitbucket` image.
	- push the image to our registry server.

- tag on `testrepository_bitbucket_deploy`
	- use AWS `eb-cli`  to deploy to AWS elastic beanstalk using a Dockerfile from `testrepository_bitbucket_deploy` with customisations based on the `testrepository_bitbucket` image.


Production scenarios will include

- push on cmfive develop branch
	- use the cmfive-dev_deploy repository to build the 2pisoftware/cmfive-dev image
	- run the image on the CI server and run the test suite with email notification.
	- if the tests all pass, push the 2pisoftware/cmfive-dev image to our registry server.
	
- push on the cmfive master branch
	- use the cmfive_deploy repository to build the 2pisoftware/cmfive image
	- run the image on the CI server and run the test suite with email notification.
	- if the tests all pass, push the 2pisoftware/cmfive image to our registry server.
	
- similarly for 2picrm


### Deployment Repositories

A deployment repository is created for each client project that is part of our CI framework.

The deployment repository includes a top level Dockerfile that typically extends our hosted cmfive or crm image, customising the config file and adding modules like the wiki.

```
FROM 2pisoftware/cmfive:latest
# database connection
ENV RDS_HOSTNAME=localhost RDS_USERNAME=admin RDS_PASSWORD=admin RDS_DB_NAME=cmfive STARTUP_SQL=/install.sql
# site config
ADD config.php /var/www/cmfive/config.php

# skip main setup
# RUN touch /cmfive_install_complete
# OR just skip databases import
# RUN touch /cmfive_install_db_complete

# deployment key for 2picrm
ADD id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa; 
RUN touch /root/.ssh/known_hosts; 
RUN ssh-keyscan -T 60 bitbucket.org >> /root/.ssh/known_hosts
# clone 2picrm
RUN git clone --depth=1 git@bitbucket.org:2pisoftware/2picrm.git /opt/2picrm 
RUN cp -a /opt/2picrm/modules/crm /var/www/cmfive/modules  
RUN cp -a /opt/2picrm/modules/staff /var/www/cmfive/modules

# COMPOSER UPDATE FOR NEW MODULES (migrations are run on first boot)
RUN  export HOME=/var/www; cd /var/www/cmfive; chmod 755 /var/www/cmfive/system/composer.json; php -f /updatecomposer.php; cat /var/www/cmfive/system/composer.json; cd /var/www/cmfive/system; php composer.phar update; 

# REQUIRED !!!
EXPOSE 80 443
# from phusion/baseimage init script
CMD ["/sbin/my_init"]
```

Where a repository is intended for a specific deployment scenario, the convention of appending `_deploy` to the repository name clearly identifies such repositories.

To enable autonomous deployment to AWS EB, a repository must follow a number of other conventions.

- include standard Dockerrun.aws file
- EXPOSE a port and specify a CMD in the Dockerfile
- run eb init in the repository root folder


### Demo
1. Build an image
Show that there are no images on the code server
Commit to testrepository_bitbucket
Show that there is now an image

2. Deploy to AWS
Show AWS EB console with no applications.
Tag testrepository_bitbucket_deploy.
Show AWS EB console with deployed application.
Show website.


### Related Services

#### Relational Database Service  (RDS)

The cmfive based images provide mysql server baked in. This is convenient for single image test deployments but care must be taken to create a volume for the database files and ensure that it is backed up in live deployments. This approach does not support clustering.

For greater convenience and security and scalability, the database layer can be provided by an AWS RDS mysql instance.

By setting appropriate environment variables a database server can be provisioned automatically as the image is deployed.

To minimise costs, a single preconfigured AWS RDS instance could contain many databases for many clients.


The cmfive based images include scripts to run migrations and potentially import SQL at boot based on environment variables.


#### Elastic File System (EFS)

Docker volumes can be created for elements of the deployed file system which can be backed up and persist reboots.

For greater security, AWS EFS provides an nfs mountable file system which can be automatically deployed with an image.


### More Detail

For more detail about AWS deployment see our [CI technical documentation].
For more detail about [working with the cmfive and 2picrm base images].


-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------


## Test/Development Scripts

```
# test push on testrepository_bitbucket
cd /tmp
rm -rf testrepository_bitbucket
git clone --depth=1 https://steve_ryan@bitbucket.org/2pisoftware/testrepository_bitbucket.git
rm /opt/webhooks_deploy/jobs/pending/*
docker stop registry; rm -rf /opt/registry_deploy/data/docker/; docker start registry
cd /tmp/testrepository_bitbucket/
echo "more stuff"  >> readme.txt
git add readme.txt
git commit -m "add to readme"
git push && sleep 15 && /opt/webhooks_deploy/src/webhooks/cronjob.sh


# test tag on testrepository_bitbucket_deploy
tag=1.9; cd /tmp && rm -rf testrepository_bitbucket_deploy && git clone --depth=1 https://steve_ryan@bitbucket.org/2pisoftware/testrepository_bitbucket_deploy.git && cd /tmp/testrepository_bitbucket_deploy/ && git tag $tag && git push --tags && sleep 15 && /opt/webhooks_deploy/src/webhooks/cronjob.sh



# CRON BUILD

# test image
 rm -rf /tmp/testrepository_bitbucket && cd /tmp && git clone --depth 1 https://git@bitbucket.org/2pisoftware/testrepository_bitbucket.git /tmp/testrepository_bitbucket && cd /tmp/testrepository_bitbucket && docker build -t 2pisoftware/testrepository_bitbucket . && rm -rf /tmp/testrepository_bitbucket && docker tag -f 2pisoftware/testrepository_bitbucket code.2pisoftware.com:5000/2pisoftware/testrepository_bitbucket:latest && docker push code.2pisoftware.com:5000/2pisoftware/testrepository_bitbucket:latest


# test deploy
env=development && rm -rf /tmp/testrepository_bitbucket_deploy && cd /tmp && git clone https://git@bitbucket.org/2pisoftware/testrepository_bitbucket_deploy.git && cd /tmp/testrepository_bitbucket_deploy &&	eb init --profile=eb-cli -r us-west-2 -k syntithenaicmfive --platform="Docker 1.11.1"  && if [ ` eb list|grep $env|wc -w` -gt 0 ]; then echo "eb deploy"; eb deploy; else	echo "eb create -ip code.2pisoftware.com_registry $env"; eb create -ip code.2pisoftware.com_registry $env ; fi



```
