#!/bin/bash
VHOST_ROOT_DOMAIN=code.2pisoftware.com
DIR=`dirname $0`
  for i in `ls -d -1  $DIR/jobs/* 2> /dev/null | sort`; do
    action=`cat $i|cut --delimiter=' '  -f 1`
    repo=`cat $i|cut --delimiter=' '  -f 2`
    tag=`cat $i|cut  --delimiter=' '  -f 3`
    #commit=`cat $i|cut  -f 4`
    #user=`cat $i|cut  -f 5`
    #echo "action $action "
    if [ "$action" == "tag" ]
    then
		echo "got tag";
		#test
		#if [ "$repo" == "https://bitbucket.org/steve_ryan/testrepository_bitbucket.git" ]  
		#then
			# build an image from the repo
			repoName=`echo $repo| rev| cut -d/ -f 1| rev| cut -d. -f 1`
			echo "REPO $repo"
			repoDir=${repo////_}
			repoDir=${repoDir/:/}
			repoDir=${repoDir/ /}
			
			tag=${tag/ /}
			repoDir=${repoDir/git/$tag}
			folder="$DIR/build/${repoDir}"
			rm -rf $folder
			mkdir -p $folder
			cd $folder
			dockerTag=${repoName}:${tag}
			dockerTagDot=${repoName}.${tag}
			git clone --depth=1 $repo 
			cd $repoName
			if [ -e Dockerfile ] 
			then
				docker build -t $dockerTag .
				#docker tag $dockerTag localhost:5000/$dockerTag
				#docker push localhost:5000/$dockerTag
				docker run -d -P -e VIRTUAL_HOST=$dockerTagDot.$VHOST_ROOT_DOMAIN $dockerTag &
				#echo  "CREATED HOST $dockerTagDot.$VHOST_ROOT_DOMAIN";
			fi
			
		#fi 
		#cmfive
		#if [ $repo == "https://bitbucket.org/steve_ryan/testrepository_bitbucket.git" ]  
		
		#fi
		
	fi	
    rm $i;
  done
#echo "DONE";


