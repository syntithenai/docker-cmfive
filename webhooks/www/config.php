<?php
/** Repositories Config
 * HTTP Requests to webhooks will be ignored if they do not define a webhook request to a repository on this list
 * The configuration includes 
 * - triggers with keys that are run with root permission from crontab
 * 		- tag - bash commands to run when a tag is pushed to git on this repository 
 * 		- push (with subkeys branch names) with bash commands 
 * 		- pull_request (PENDING)
 * 		- branch (PENDING)
 * !! Bash commands are run in a context that includes the following environment variables (that can be used in your configured scripts)
 
 * 		- WEBHOOKBUILD_URL - repository url (array key)
 * 		- WEBHOOKBUILD_NAME - extracted repository name
 * 		- WEBHOOKBUILD_FOLDER - build folder
 * 		- WEBHOOKBUILD_CONTAINERNAME - name of docker container
 * 		- WEBHOOKBUILD_DOMAINNAME - vhost domain name
 * 		- WEBHOOKBUILD_TAG - tag (eg 1.4)
 */ 
$webHookConfig=[];
$webHookConfig['repositories']=[
	# cmfive 
	'git@github.com:2pisoftware/cmfive.git' =>[
		'triggers' => [
			'dtag' => ['
				# use cmfive_deploy repository to build image
				git clone git@bitbucket.org:steve_ryan/cmfive_deploy.git $WEBHOOKBUILD_FOLDER
				cd $WEBHOOKBUILD_FOLDER
				docker build -t $WEBHOOKBUILD_NAME .
				rm -rf $WEBHOOKBUILD_FOLDER
				docker stop $WEBHOOKBUILD_CONTAINERNAME
				docker rm $WEBHOOKBUILD_CONTAINERNAME
				docker run --name=$WEBHOOKBUILD_CONTAINERNAME -d -P -e VIRTUAL_HOST=$WEBHOOKBUILD_DOMAINNAME $WEBHOOKBUILD_TAG &
				# sleep 3600 && docker stop tag_$dockerTagUS && docker rm tag_$dockerTagUS
			'],
			//'build','push:code.2pisoftware.com','deploy:code.2pisoftware.com',],
			'dpush' => [
				'development' => ['
					
				'],
				'master' => []
			],
			'pull_request' => [
			
			]
		]
	],
	'git@bitbucket.org:steve_ryan/cmfive_deploy.git' => [
		'triggers' => [
			'tag' =>'',
			'push' => [
				'master'=>''
			]
		]
	],
	# 2picrm
	'git@bitbucket.org:2pisoftware/2picrm.git' => [
		'triggers' => [
			'tag' =>'',
			'push' => [
				'master'=>''
			]
		]
	],
	'git@bitbucket.org:steve_ryan/crm_2pisoftware_deploy.git' => [
		'deploymentkey' =>'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZCOPdhCvqsBqoke37Kfk/9uoMYEt0J8987yENfPqAdxiQl+ZqVGhiIr2IgmBxPhkU+T8zJ/ZqytviR75HRoN/PFpSuBBN9AHjPvOlu0j/9BRexd0qx+5xMyLzr3tbddDCiEcXkt767EaGKZnPHNDew8ot5wdEV5prUIKhJcs5l6WKN6ZFBTTJ88N82ik6Fg2lRDDJuMZfU5PWjapLb0u5m/AfFzoBfC2IHZLQYHdYxSF4FMkdK7c+9Z0mAXLcNVBPWTiuogeuoD9EU/ENInmc/qYgSmpQb84brlNv5Ci/CNijP6WGT8Ic3NDw5jKY5uzGHleDgA9XICPPop7iIdl5 ubuntu@ip-172-31-15-105',
		'triggers' => [
			'tag' =>'',
			'push' => [
				'master'=>''
			]
		]
	],
	
	
];

