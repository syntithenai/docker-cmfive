<?php 

$VHOST_ROOT_DOMAIN=code.2pisoftware.com
$DIR=__DIR__;
mkdir($DIR.'/jobs',0777,true);
mkdir($DIR.'/jobscomplete',0777,true);
mkdir($DIR.'/jobspending',0777,true);
mkdir($DIR.'/jobsignored',0777,true);

foreach (glob($DIR."/jobs/*.txt") as $filename) {
	$content = json_decode(file_get_contents($filename));
	$request = new WebHookRequest($content['headers'],$content['body']);
	echo "<hr>";
	print_r($content);
	echo "<hr>";
	print_r([$request->isActionable(),$request->getRepositoryName(),$request->getRepositoryUrl(),$request->action(),$request->branch(),$request->version(),$request->tag()]);
}


exit;

/*
STARTDIR=`pwd`
  for i in `ls -d -1  $DIR/jobs/*.txt 2> /dev/null | sort`; do
    action=`cat $i|cut --delimiter=' '  -f 1`
    repo=`cat $i|cut --delimiter=' '  -f 2`
    tag=`cat $i|cut  --delimiter=' '  -f 3`
    filename=`basename $i`
    mv $i $DIR/jobspending/
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
			repoLabel=${repo/_deploy/}
			
			tag=${tag/ /}
			repoDir=${repoDir/git/$tag}
			folder="$DIR/build/${repoDir}"
			rm -rf $folder
			mkdir -p $folder
			cd $folder
			dockerTag=${repoName}:${tag}
			dockerTagDot=${repoName}.${tag}
			dockerTagUS=${repoName}_${tag}
			git clone --depth=1 $repo 
			cd $repoName
			if [ -e Dockerfile ] 
			then
				echo "Build"
				docker build --no-cache -t $dockerTag .
				#docker tag $dockerTag localhost:5000/$dockerTag
				#docker push localhost:5000/$dockerTag
				echo "Run"
				docker stop tag_$dockerTagUS
				docker rm tag_$dockerTagUS
				docker run --name=tag_$dockerTagUS -d -P -e VIRTUAL_HOST=$dockerTagDot.$VHOST_ROOT_DOMAIN $dockerTag &
				# sleep 3600 && docker stop tag_$dockerTagUS && docker rm tag_$dockerTagUS
				# sep thread
				echo  "CREATED HOST $dockerTagDot.$VHOST_ROOT_DOMAIN";
				mv $STARTDIR/jobspending/$filename $STARTDIR/jobscomplete/
			else 
				mv $STARTDIR/jobspending/$filename $STARTDIR/jobsignored/
			fi
			
		#fi 
		#cmfive
		#if [ $repo == "https://bitbucket.org/steve_ryan/testrepository_bitbucket.git" ]  
		
		#fi
	else
		mv $STARTDIR/jobspending/$filename $STARTDIR/jobsignored/
	fi	
    
  done
echo "DONE";



*/
