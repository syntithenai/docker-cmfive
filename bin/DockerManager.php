<?php 
//alias dm=/home/ubuntu/projects/docks/docker-cmfive/bin/docker-manager.sh

/**
 * Generate random pronounceable words
 *
 * @param int $length Word length
 * @return string Random word
 */
function random_pronounceable_word( $length = 6 ) {
    
    // consonant sounds
    $cons = array(
        // single consonants. Beware of Q, it's often awkward in words
        'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm',
        'n', 'p', 'r', 's', 't', 'v', 'w', 'x', 'z',
        // possible combinations excluding those which cannot start a word
        'pt', 'gl', 'gr', 'ch', 'ph', 'ps', 'sh', 'st', 'th', 'wh', 
    );
    
    // consonant combinations that cannot start a word
    $cons_cant_start = array( 
        'ck', 'cm',
        'dr', 'ds',
        'ft',
        'gh', 'gn',
        'kr', 'ks',
        'ls', 'lt', 'lr',
        'mp', 'mt', 'ms',
        'ng', 'ns',
        'rd', 'rg', 'rs', 'rt',
        'ss',
        'ts', 'tch', 
    );
    
    // wovels
    $vows = array(
        // single vowels
        'a', 'e', 'i', 'o', 'u', 'y', 
        // vowel combinations your language allows
        'ee', 'oa', 'oo', 
    );
    
    // start by vowel or consonant ?
    $current = ( mt_rand( 0, 1 ) == '0' ? 'cons' : 'vows' );
    
    $word = '';
        
    while( strlen( $word ) < $length ) {
    
        // After first letter, use all consonant combos
        if( strlen( $word ) == 2 ) 
            $cons = array_merge( $cons, $cons_cant_start );
 
         // random sign from either $cons or $vows
        $rnd = ${$current}[ mt_rand( 0, count( ${$current} ) -1 ) ];
        
        // check if random sign fits in word length
        if( strlen( $word . $rnd ) <= $length ) {
            $word .= $rnd;
            // alternate sounds
            $current = ( $current == 'cons' ? 'vows' : 'cons' );
        }
    }
    
    return $word;
}

function extractCLIArguments($argv,&$composerFile,&$name,&$hostname,&$commitId) {
	$composerFile=$argv[2];
	if (empty($composerFile)) throw new Exception ('No composer file specified');
	if (!empty($composerFile)) {
		$composerFile=dirname(__FILE__).'/../compose/'.$composerFile.'/docker-compose.yml';
		if (!file_exists($composerFile)) {
			throw new Exception ('Invalid composer file specified - '.$composerFile);
		}
	}
	if (array_key_exists(3,$argv)) {
		$name=$argv[3];
	} else {
		$name=random_pronounceable_word(8);
	}
	if (array_key_exists(4,$argv)) {
		$hostname=$argv[4];
	} else {
		$hostname=$name.'.docker.code.2pisoftware.com';
	}
	if (array_key_exists(5,$argv)) {
		$commitId=$argv[5];
	}
}
try {
	// DISK SPACE
	$cmd="df -h |grep \"/dev/xvda1\"|awk  '{ print $5; }'";
	echo "DISK SPACE:"; //.$cmd ;
	echo exec($cmd);
	echo "\n";

	// handle CLI arguments
	if (php_sapi_name() == 'cli') {
		if (count($argv)>1) {
			switch ($argv[1]) {  
				case 'up':
					$composerFile='';
					$name='';
					$hostname='';
					$commitId='';
					extractCLIArguments($argv,$composerFile,$name,$hostname,$commitId);
					$nameFlag='';
					if (!empty($name)) {
						$nameFlag=' -p '.$name;
					}
					$hostConfig='';
					if (!empty($hostname)) {
						$hostConfig='export VIRTUAL_HOST='.$hostname.'; ';
					}
					$cmd=$hostConfig.'docker-compose -f '.$composerFile.$nameFlag.' up -d';
					//echo $cmd;
					$output=[];
					// capture error output too
					$output=shell_exec($cmd.' 2>&1');	
					$parts=explode(' ',$output);
					$containerName='';
					$description='';
					//print_r($parts);
					if (trim($parts[0])=="Creating" || trim($parts[0])=="Recreating") {
						$description=$parts[0].' container';
						$containerName=trim($parts[1]);
					} else if(trim($parts[1])=="is" && trim($parts[2])=="up-to-date") {
						$description='Updated container';
						$containerName=trim($parts[0]);
					}
					//print_r([$parts]); //explode(' ',$output[0]));
					echo $description."\n";
					echo $containerName."\n";
					echo $hostname."\n";
					//echo "\n";
					//die();
					//if ()
					//echo "|".$output."|";
					// GENERATE NGINX CONFIG AND RELOAD
					echo exec('docker-gen -notify="/etc/init.d/nginx reload" '.dirname(__FILE__).'/nginx.tmpl /etc/nginx/sites-enabled/default');
						echo "\n";
				
					echo "\n";
					
					// GIT CHECKOUT
					if (!empty($commitId))  {
						$cmd='docker exec '.$containerName.' "/updategit.sh '.$commitId.'"';
						echo $cmd;
						$output=[];
						$result=null;
						//exec($cmd,$output,$result);	
						//print_r([$output,$result]);
						//echo $output;
						//echo "\n";
					}

					// RUN TESTS
					// if $commitId, do checkout
					if (false && !empty($commitId))  {
						$cmd='docker exec '.$containerName.' /runtests.sh';
						//echo $cmd;
						$output=[];
						$result=null;
						exec($cmd,$output,$result);	
						print_r([$output,$result]);
						//echo $output;
						//echo "\n";
					}
					
					
				
				
					break;
				case 'start':
					break;
				case 'stop':
					break;
				case 'kill':
				
					$composerFile='';
					$name='';
					$hostname='';
					$commitId='';
					extractCLIArguments($argv,$composerFile,$name,$hostname,$commitId);
					$nameFlag='';
					if (!empty($name)) {
						$nameFlag=' -p '.$name;
					}
					$hostConfig='';
					if (!empty($hostname)) {
						$hostConfig='export VIRTUAL_HOST='.$hostname.'; ';
					}
					$cmd=$hostConfig.'docker-compose -f '.$composerFile.$nameFlag.' down --rmi local -v';
					// capture error output too
					$output=shell_exec($cmd.' 2>&1');
					echo $output;
					break;
				case 'killall':
				//docker kill $(docker ps -q)
					break;
				case 'test':
					// what checkout version ??
					// /runtests.sh
					break;
				case 'update':
					// what checkout version ??
					// git
					// composer
					// migrations
					break;
			} 
		} else { 
			echo exec('docker ps');
		}
	}

//echo "DONE";
	// VIRTUAL_HOST=cmfive.docker.code.2pisoftware.com

// CLEANUP
/*
 * 
docker rm -v $(docker ps -a -q -f status=exited)
docker rmi $(docker images -f "dangling=true" -q)
docker volume rm $(docker volume ls| awk '{ print $2; }') 
 * */

echo "\n";

} catch (Exception $e) {
	echo $e->getMessage();
}
