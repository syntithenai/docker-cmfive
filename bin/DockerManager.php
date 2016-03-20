<?php 
//alias dm=/home/ubuntu/projects/docks/docker-cmfive/bin/docker-manager.sh


class DockerManager {
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


	function ensureContainerIsRunning($composerFile,$name,$hostname) {
		// ENSURE CONTAINER IS RUNNING
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
		$containerName='';
		$description='';
		$lines=explode("\n",$output);
		$containerNames=['cmfive'=>'','testrunner'=>'','selenium'=>''];
		foreach ($lines as $line) {
			$parts=explode(' ',$line);
			//print_r($parts);
			if (trim($parts[0])=="Creating" || trim($parts[0])=="Recreating") {
				if (strpos($parts[1],'cmfivecomplete')!==false) {
					$description=$parts[0].' container';
					$containerNames['cmfive']=trim($parts[1]);
				} else if (strpos($parts[1],'testrunner')!==false) {
					$description=$parts[0].' container';
					$containerNames['testrunner']=trim($parts[1]);
				} else if (strpos($parts[1],'selenium')!==false) {
					$description=$parts[0].' container';
					$containerNames['selenium']=trim($parts[1]);
				}
			} else if(count($parts)>2 && trim($parts[1])=="is" && trim($parts[2])=="up-to-date") {
				if (strpos($parts[0],'cmfivecomplete')!==false) {
					$description='Updated container';
					$containerNames['cmfive']=trim($parts[0]);
				} else if (strpos($parts[0],'testrunner')!==false) {
					$description='Updated container';
					$containerNames['testrunner']=trim($parts[0]);
				} else if (strpos($parts[0],'selenium')!==false) {
					$description='Updated container';
					$containerNames['selenium']=trim($parts[0]);
				}
			} else {
				//echo $output;
			}
		}
		//print_r([$parts]); //explode(' ',$output[0]));
		//echo $description."\n";
		echo $output."\n";
		echo "CMFIVE CONTAINER:  ".$containerNames['cmfive']."\n";
		echo "TESTRUNNER CONTAINER:  ".$containerNames['testrunner']."\n";
		echo "SELENIUM CONTAINER:  ".$containerNames['selenium']."\n";
		echo "HOSTNAME:  ".$hostname."\n";
		//echo "\n";
		//die();
		//if ()
		//echo "|".$output."|";
		// GENERATE NGINX CONFIG AND RELOAD
		exec('docker-gen -notify="/etc/init.d/nginx reload" '.dirname(__FILE__).'/nginx.tmpl /etc/nginx/sites-enabled/default');
		//	echo "\n";
		return $containerNames;
	}
						
	function gitUpdates($containerName,$gitUpdates) {
		// GIT CHECKOUT
		echo "GIT UPDATES:".$gitUpdates."\n";
		if (!empty($gitUpdates))  {
			$parts=explode(",",$gitUpdates);
			foreach ($parts as $commitDetails) {
				$subparts=explode('::',$commitDetails);
				if (count($subparts)==2) {
					$folder=$subparts[0];
					$commitId=$subparts[1];
					// check folder exists in /var/www
					$cmd='docker exec '.$containerName.' /bin/ls  /var/www/'.$folder.'/.git';
					$output=[];
					$result=null;
					echo "CMD:".$cmd."\n";
					echo "RESULT:\n";
					echo "\n";
					exec($cmd,$output,$result);	
					//print_r([$output,$result]);
					if ($result==0) {
						$cmd='docker exec '.$containerName.' /usr/bin/git -C /var/www/'.$folder.'  checkout -f '.$commitId;
						$output=[];
						$result=null;
						exec($cmd,$output,$result);	
						//print_r([$output,$result]);
						echo shell_exec('docker exec '.$containerName.' /usr/bin/git -C /var/www/'.$folder.'  pull');
						
					}
					echo "\n";
				}
			}
			
			
			echo $cmd;
			$output=[];
			$result=null;
			//exec($cmd,$output,$result);	
			//print_r([$output,$result]);
			//echo $output;
			//echo "\n";
		}
	}
	
	function downContainer($composerFile,$name) {
		$hostname=$name; //.'.docker.code.2pisoftware.com';
		$nameFlag=' -p '.$name;
		$hostConfig='';
		if (!empty($hostname)) {
			$hostConfig='export VIRTUAL_HOST='.$hostname.'; ';
		}
		$cmd=$hostConfig.'docker-compose -f '.$composerFile.$nameFlag.' down --rmi local -v';
		// capture error output too
		$output=shell_exec($cmd.' 2>&1');
		echo $output;
	}
	
	function runClean() {
		echo exec('docker rm -v $(docker ps -a -q -f status=exited)');
		echo exec('docker rmi $(docker images -f "dangling=true" -q)');
		echo exec("docker volume rm $(docker volume ls| awk '{ print $2; }') ");
	}
						
	function showDiskSpace() {
		// DISK SPACE
		$cmd="df -h |grep \"/dev/xvda1\"|awk  '{ print $5; }'";
		echo "DISK SPACE:"; //.$cmd ;
		echo exec($cmd);
		echo "\n";
	}
	
	function listRunningContainers() {
		echo exec('docker ps');
		//echo file_get_contents('/tmp/docker-manager/activecontainers');
	}

	function run($argv) {						
		$this->showDiskSpace();
		if (count($argv)>1) {
			switch ($argv[1]) {  
				case 'up':
					// handle parameters
					$composerFile='';
					$name='';
					$hostname='';
					$gitUpdates='';
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
						$name=$this->random_pronounceable_word(8);
					}
					if (array_key_exists(4,$argv)) {
						$hostname=$argv[4];
					} else {
						$hostname=$name.'.docker.code.2pisoftware.com';
					}
					if (array_key_exists(5,$argv)) {
						$commitId=$argv[5];
					}
					// start instance
					$containerNames=$this->ensureContainerIsRunning($composerFile,$name,$hostname);
					//echo "\n";
					// git updates ??
					$this->gitUpdates($containerNames['cmfive'],$gitUpdates);
					
					break;
				case 'down':
					$composerFile='';
					$name='';
					$hostname='';
					$commitId='';
					// handle parameters
					$composerFile='';
					$name='';
					$hostname='';
					$gitUpdates='';
					$composerFile=$argv[2];
					if (empty($composerFile)) throw new Exception ('No composer file specified');
					if (!empty($composerFile)) {
						$composerFile=dirname(__FILE__).'/../compose/'.$composerFile.'/docker-compose.yml';
						if (!file_exists($composerFile)) {
							throw new Exception ('Invalid composer file specified - '.$composerFile);
						}
					}
					// require a name
					if (strlen(trim($argv[3]))==0) {
						throw new Exception('A name parameter is required for down');
					}
					$name=$argv[3];
					$this->downContainer($composerFile,$name);
					$this->showDiskSpace();
					break;
				case 'killall':
					if ($argv[2]=='reallytruly')  {
						echo exec('docker kill $(docker ps -q)');
					}
					$this->runClean();
					$this->showDiskSpace();
					
					break;
				case 'clean':
					$this->runClean();
					$this->showDiskSpace();
					break;
				
				case 'test':
					// handle parameters
					$composerFile='';
					$name='';
					$hostname='';
					$gitUpdates='';
					$composerFile=$argv[2];
					if (empty($composerFile)) throw new Exception ('No composer file specified');
					if (!empty($composerFile)) {
						$composerFile=dirname(__FILE__).'/../compose/'.$composerFile.'/docker-compose.yml';
						if (!file_exists($composerFile)) {
							throw new Exception ('Invalid composer file specified - '.$composerFile);
						}
					}
					$name='fred'; //$this->random_pronounceable_word(8);
					$hostname=$name.'.docker.code.2pisoftware.com';
					$gitUpdates=$argv[3];
					//echo 'C:'.$commitId;
					if (empty($gitUpdates)) throw new Exception('You must provide a commit identifier (branch or sha)');
					// start instance
					//echo "start test run".$hostname;
					$containerNames=$this->ensureContainerIsRunning($composerFile,$name,$hostname);
					print_r($containerNames);
					echo "\n";
					// git updates ??
					//echo "git updates ".$gitUpdates;
					$this->gitUpdates($containerNames['cmfive'],$gitUpdates);
					echo "\n\nUPDATE TESTRUNNER:";
					$cmd='docker exec '.$containerNames['testrunner'].' /usr/bin/git -C /var/www/testrunner  checkout -f master';
					$cmd='docker exec '.$containerNames['testrunner'].' /usr/bin/git -C /var/www/testrunner  pull';
					echo $cmd."\n";
					echo exec($cmd);
					// allow db to start
					//echo "sleep ".$hostname;
					sleep(15);
					echo "test ".$containerNames['cmfive'];
					// RUN TESTS
					$cmd='docker exec '.$containerNames['testrunner'].' /runtests.sh';
					echo $cmd;
					$output=[];
					$result=null;
					exec($cmd,$output,$result);	
					print_r([$output,$result]);
					//echo $output;
					//echo "\n";
					//$this->downContainer($composerFile,$name);
					break;
			}
		} else { 
			$this->listRunningContainers();
		}
	}
}


