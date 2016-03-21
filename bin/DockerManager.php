<?php 
//alias dm=/home/ubuntu/projects/docks/docker-cmfive/bin/docker-manager.sh

// FOR WINDOWS TO AVOID SSL ERRORS
//git config --system http.sslverify false


class DockerManager {
	
	
	public $windows = false;  // are we running on ms windows
	
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

	function ensureWebProxy() {
		//echo "ENSURE: PROXY";
		$output=shell_exec('docker ps');
		$found=false;
		//echo $output;
		if (strpos($output,'nginxproxy_nginxproxy')==false) {
			$cmd='docker-compose -f ../nginx-proxy/docker-compose.yml up -d';
			//echo $cmd;
			echo shell_exec($cmd);
			$found=true;
		}
		if (strpos($output,'nginxgen')==false) {
			exec('docker rm nginxgen');
			sleep(3);
			$cmd='docker run -d --name nginxgen --volumes-from nginxproxy_nginxproxy_1  -t jwilder/docker-gen:0.3.4 -notify-sighup nginx -watch --only-published /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf';
			//echo $cmd;
			shell_exec($cmd);
			$found=true;
		}
		if ($found) echo "Started web proxy\n";
	}

	function ensureContainerIsRunning($composerFile,$name,$hostname) {
		$this->ensureWebProxy();
		// ENSURE CONTAINER IS RUNNING
		$nameFlag='';
		if (!empty($name)) {
			$nameFlag=' -p '.$name;
		}
		$hostConfig='';
		$composerFileContents='';
		$newComposerFileContents='';
		if (!empty($hostname)) {
			if ($this->windows) {
				// UGH manual templateing to avoid environment variables in windows
				$composerFileContents=file_get_contents($composerFile);
				$newComposerFileContents=str_replace('${VIRTUAL_HOST}',trim($hostname),$composerFileContents);
				//echo "NewCONTNTE:".$newComposerFileContents;
			} else {
				$hostConfig='export VIRTUAL_HOST='.$hostname.'; ';
			}
		}
		$cmd=$hostConfig.'docker-compose -f '.$composerFile.$nameFlag.' up -d';
		//echo $cmd;
		$output=[];
		// capture error output too
		file_put_contents($composerFile,$newComposerFileContents);
		$output=shell_exec($cmd.' 2>&1');
		file_put_contents($composerFile,$composerFileContents);
		//echo $output;
		$containerName='';
		$description='';
		$lines=explode("\n",$output);
		$containerNames=['cmfive'=>'','testrunner'=>'','selenium'=>''];
		foreach ($lines as $line) {
			$parts=explode(' ',$line);
			//print_r($parts);
			if (trim($parts[0])=="Creating" || trim($parts[0])=="Recreating"|| trim($parts[0])=="Starting") {
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
		//echo $output."\n";
		echo "CMFIVE CONTAINER:  ".$containerNames['cmfive']."\n";
		echo "TESTRUNNER CONTAINER:  ".$containerNames['testrunner']."\n";
		echo "SELENIUM CONTAINER:  ".$containerNames['selenium']."\n";
		echo "HOSTNAME:  ".$hostname."\n";
		//echo "\n";
		//die();
		//if ()
		//echo "|".$output."|";
		// GENERATE NGINX CONFIG AND RELOAD
		//exec('docker-gen -notify="/etc/init.d/nginx reload" '.dirname(__FILE__).'/nginx.tmpl /etc/nginx/sites-enabled/default');
		//	echo "\n";
		return $containerNames;
	}
	
	function selfUpdate() {
		$gitBin='/usr/bin/git';
		$cmd=$gitBin.' -C '.dirname(__FILE__).'  pull';
		if ($this->windows) {
			 
			$cmd=dirname(__FILE__).'/git.bat  -C '.dirname(__FILE__)."  pull";
		}
		
		//echo $cmd;
		//echo 
		shell_exec($cmd);
	}
	
	function build($repo) {
		
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
	
	
	function getWildCardBaseDomain() {
		if (file_exists(dirname(__FILE__)."/WILDCARD_DOMAIN"))  {
			//return trim(file_get_contents(dirname(__FILE__)."/WILDCARD_DOMAIN"));
			return "docker	";
		} else {
			return "docker.code.2pisoftware.com";
		}
	}
	
	function downContainer($composerFile,$name) {
		$hostname=$name; 
		$nameFlag=' -p '.$name;
		$hostConfig='';
		if (!empty($hostname)) {
			if ($this->windows) {
				$hostConfig='';
			} else {
				 $hostConfig='export VIRTUAL_HOST='.$hostname.'; ';
			}
		}
		
		$cmd=$hostConfig.'docker-compose -f '.$composerFile.$nameFlag.' down --rmi local -v';
		// capture error output too
		$output=shell_exec($cmd.' 2>&1');
		echo $output;
	}
	
	function killAllContainers() {
		$output=[];
		// get a list of running containers
		exec('docker ps ',$output);
		$a=0;  // skip header row
		if (count($output)>1)  {
			foreach ($output as $line) {
				if ($a>0) {
					$parts=explode(' ',$line);
					$id=$parts[0];
					$name=$parts[count($parts)-1];
					$cmd='docker kill '.$id;
					$ioutput=[];
					exec($cmd,$ioutput);
					echo "Killed ".$name."\n";
				}
				$a++;
			}
		} else {
			echo "No running containers to kill";
		}
	}
	
	function runClean() {
		$this->removeStoppedContainers();
		$this->removeDanglingImages();
		$this->removeUnusedVolumes();
	}
	
	function removeStoppedContainers() {
		//echo exec('docker rm -v $(docker ps -a -q -f status=exited)');
		// get a list of running containers
		$output=[];
		exec('docker ps -a -q -f status=exited',$output);
		$a=0;  // skip header row
		if (count($output)>1)  {
			foreach ($output as $line) {
				if ($a>0) {
					$parts=explode(' ',$line);
					$id=$parts[0];
					$name=$parts[count($parts)-1];
					$cmd='docker rm -v  '.$id;
					$ioutput=[];
					exec($cmd,$ioutput);
					echo "Removed ".$name."\n";
				}
				$a++;
			}
		} else {
			echo "No stopped containers to kill";
		}
	}
	
	function removeDanglingImages() {
		//echo exec('docker rmi $(docker images -f "dangling=true" -q)');
		$output=[];
		exec('docker images -f "dangling=true" -q',$output);
		$a=0;  // skip header row
		if (count($output)>1)  {
			foreach ($output as $line) {
				if ($a>0) {
					$parts=explode(' ',$line);
					$id=$parts[0];
					$name=$parts[count($parts)-1];
					$cmd='docker rmi '.$id;
					$ioutput=[];
					exec($cmd,$ioutput);
					echo "Removed images ".$name."\n";
				}
				$a++;
			}
		} else {
			echo "No dangling images to kill";
		}
	}
	
	function removeUnusedVolumes() {
		$output=[];
		$awk="awk  '{ print $2; }'";
		if ($this->windows)  {
			$awk=dirname(__FILE__).'\awk.exe -F: "{echo $2}"';
		}
		//echo exec("docker volume rm $(docker volume ls| awk '{ print $2; }') ");
		$cmd="docker volume ls| ".$awk;
		exec($cmd,$output);
		$a=0;  // skip header row
		if (count($output)>1)  {
			foreach ($output as $line) {
				if ($a>0) {
					$parts=explode(' ',$line);
					$id=$parts[0];
					$name=$parts[count($parts)-1];
					$cmd='docker volume rm '.$id;
					$ioutput=[];
					exec($cmd,$ioutput);
					echo "Removed volumes ".$name."\n";
				}
				$a++;
			}
		} else {
			echo "No unused volumes to kill";
		}
	}
	
	
	
	// DISK SPACE
	function showDiskSpace() {
		if ($this->windows) {
			echo "\n";
			$cmd="wmic logicaldisk get size,freespace,caption";
			echo "DISK USAGE:"; //.$cmd ;
			$output=[];
			exec($cmd,$output);
			$diskSpace='';
			foreach ($output as $line) {
				$parts=explode(' ',$line);
				if ($parts[0]=='C:') {
					$diskSpace=round(100-($parts[7]/$parts[10])*100,2);
				}
			}
			echo $diskSpace;
			echo "%\n";
		} else {
			$cmd="df -h |grep \"/dev/xvda1\"|awk  '{ print $5; }'";
			echo "DISK USAGE:"; //.$cmd ;
			echo exec($cmd);
			echo "\n";
		}
	}
	
	function listRunningContainers() {
		echo shell_exec('docker ps');
		//echo file_get_contents('/tmp/docker-manager/activecontainers');
		echo "\n";
	}

	function run($argv) {						
		$this->showDiskSpace();
		$this->selfUpdate();
		//die();
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
						$hostname=$name.'.'.$this->getWildCardBaseDomain();
					}
					if (array_key_exists(5,$argv)) {
						$commitId=$argv[5];
					}
					// start instance
					
					$containerNames=$this->ensureContainerIsRunning($composerFile,$name,$hostname);
			
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
						$this->killAllContainers();
					} else {
						echo "Failed confirmation check - killall reallytruly";
					}
					//$this->runClean();
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
					$hostname=$name.'.'.$this->getWildCardBaseDomain();
					$gitUpdates=$argv[3];
					//echo 'C:'.$commitId;
					if (empty($gitUpdates)) throw new Exception('You must provide a commit identifier (branch or sha)');
					// start instance
					//echo "start test run".$hostname;
					$containerNames=$this->ensureContainerIsRunning($composerFile,$name,$hostname);
					//print_r($containerNames);
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


