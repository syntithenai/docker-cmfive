<?php 
//alias dm=/home/ubuntu/projects/docks/docker-cmfive/bin/docker-manager.sh

//export PATH=$PATH:/var/www/projects/testrunner/dev

// FOR WINDOWS TO AVOID SSL ERRORS
//git config --system http.sslverify false


class DockerManager {
	
<<<<<<< HEAD
	public $windows = false;  // are we running on ms windows
	
	public $images=[
		// master branch minimum install nginx,php,mysql,cmfive
		'cmfive' => ['tag' => '2pisoftware/cmfive'],
		// dev branch full install, selenium, wiki, ...
		'cmfive-dev' => ['tag' => '2pisoftware/cmfive-dev'],
		// master branch crm and cmfive installed
		'crm' => ['tag' => '2pisoftware/crm'],
		// nginx, php
		'webserver' => ['tag' => '2pisoftware/cmfive'],
		// apache webdav
		'webdav' => ['tag' => '2pisoftware/cmfive'],
	];

	function createSwapDrive($container) {
		echo exec('fallocate -l 2048M /swapfile');
		echo exec('dd if=/dev/zero of=/swapfile bs=1M count=2048');
		echo exec('chmod 600 /swapfile');
		echo exec('mkswap /swapfile');
		echo exec('swapon /swapfile');
	}
	
	function killSwapDrive($container) {
		echo exec('swapoff /swapfile');
		echo exec('rm /swapfile');
	}
	
	function buildImage($image,$version='') {
		$buildPath='';
		$tag='';
		if ($image=='cmfive') {
			$buildPath=dirname(__FILE__).'/../';
			$tag='2pisoftware/cmfive';
			if (strlen(trim($version))>0) $tag.=":".$version;
		} else if (file_exists(dirname(__FILE__).'/../compose/'.$image."/Dockerfile"))  {
			$buildPath=dirname(__FILE__).'/../compose/'.$image."/";
			$tag='2pisoftware/'.$image;
		} else if ($image=='2picrm') {
			throw new Exception('2picrm build not implemented');
		} else {
			throw new Exception ('No valid build specified');
=======
	public $conf={
		'images':{
			'2pisoftware/cmfive' : {
				'repository': 'https://github.com/2pisoftware/cmfive.git',
				'dockerFile': 'Dockerfile',
				'composerFile': 'docker-compose.yml',
			}
>>>>>>> master
		}
	};
	
	public $windows = false;  // are we running on ms windows
	
	
	function run($argv) {		
<<<<<<< HEAD
		//if (strlen(trim(getenv('DOCKERMANAGER_WEB_ROOT')))==0) {
			//echo "\nYou must set an environment variable for your web root\n";
			//echo "For windows powershell ->\n \$env:DOCKERMANAGER_WEB_ROOT=\"/path/to/your/web/folder\" \nor relative to compose/project ie \n\$env:DOCKERMANAGER_WEB_ROOT=\"../../web\" \n";
=======
		if (false && strlen(trim(getenv('DOCKERMANAGER_WEB_ROOT')))==0) {
			echo "\nYou must set an environment variable for your web root\n";
			echo "For windows powershell ->\n \$env:DOCKERMANAGER_WEB_ROOT=\"/path/to/your/web/folder\" \nor relative to compose/project ie \n\$env:DOCKERMANAGER_WEB_ROOT=\"../../web\" \n";
>>>>>>> master
						
			//echo "For bash ->\n export DOCKERMANAGER_WEB_ROOT=/path/to/your/web/folder\n\n";
			//die();
		//}
						
		if (count($argv)>1) {
			switch ($argv[1]) {  
				case 'proxy' :
					$this->ensureWebProxy();
					break;
				case 'selfupdate' :
					$this->selfUpdate();
					break;
				case 'build' :	
					$this->buildImage($argv[2]);
					
					break;
				case 'up':
					$this->showDiskSpace();
					// handle parameters
					$image=$argv[2];
					$composerFile='';
					$name='';
					$hostname='';
					//$gitUpdates='';
					$composerFile='';
					if (empty($composerFile)) throw new Exception ('No composer file specified');
					if (!empty($composerFile)) {
						$composerFile=dirname(__FILE__).'/../compose/'.$composerFile.'/docker-compose.yml';
						if (!file_exists($composerFile)) {
							throw new Exception ('Invalid composer file specified - '.$argv[2]);
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
					//if (array_key_exists(5,$argv)) {
					///	$commitId=$argv[5];
					//}
	
					// start instance
					$containerNames=$this->ensureContainerIsRunning($composerFile,$name,$hostname);
					//$this->showCmfivePorts($containerNames['cmfivecomplete'],$hostname);
					//$this->showSeleniumPorts($containerNames['selenium'],$hostname);
					
					// git updates ??
					//$this->gitUpdates($containerNames['cmfivecomplete'],$gitUpdates);
					//$this->gitUpdates($containerNames['testrunner'],$gitUpdates);
					$this->showDiskSpace();
		
					break;
				case 'down':
					$this->showDiskSpace();
					
					// handle parameters
					$composerFile='';
					$name='';
					$hostname='';
					$commitId='';
					$gitUpdates='';
					$composerFile=$argv[2];
					if (empty($composerFile)) throw new Exception ('No composer file specified');
					if (!empty($composerFile)) {
						$composerFile=dirname(__FILE__).'/../compose/'.$composerFile.'/docker-compose.yml';
						if (!file_exists($composerFile)) {
							throw new Exception ('Invalid composer file specified - '.$argv[2]);
						}
					}
					// require a name
					if (strlen(trim($argv[3]))==0) {
						throw new Exception('A name parameter is required for down');
					}
					$name=$argv[3];
					
					// stop and remove containers using composer down
					$this->downContainer($composerFile,$name);
					
					$this->showDiskSpace();
					break;
				case 'killall':
					$this->showDiskSpace();
					if ($argv[2]=='reallytruly')  {
						$this->killAllContainers();
					} else {
						echo "Failed confirmation check - killall reallytruly\n";
					}
					$this->runClean();
					$this->showDiskSpace();
					
					break;
				case 'clean':
					$this->showDiskSpace();
					$this->runClean();
					$this->showDiskSpace();
					break;
				
				case 'test':
					$this->showDiskSpace();
					
					// handle parameters
					$composerFile=$argv[2];
					if ($composerFile=="cmfive") {
						//$this->buildImage($argv[2]);
					}	
					
					if (empty($composerFile)) throw new Exception ('No composer file specified');
					if (!empty($composerFile)) {
						$composerFile=dirname(__FILE__).'/../compose/'.$composerFile.'/docker-compose.yml';
						if (!file_exists($composerFile)) {
							throw new Exception ('Invalid composer file specified - '.$argv[2]);
						}
					}
					$gitUpdates='';
					if (array_key_exists(3,$argv)) {
						$gitUpdates=$argv[3];
					}
					//if (empty($gitUpdates)) throw new Exception('You must provide a commit identifier (branch or sha)');
					
					// assign name and domain for this test run
					$name='fred'; //$this->random_pronounceable_word(8);
					$hostname=$name.'.'.$this->getWildCardBaseDomain();
					
					// start instance
					$containerNames=$this->ensureContainerIsRunning($composerFile,$name,$hostname);
					$this->showCmfivePorts($containerNames['cmfivecomplete'],$hostname);
					$this->showSeleniumPorts($containerNames['selenium'],$hostname);
					
					$this->gitUpdates($containerNames['cmfivecomplete'],$gitUpdates);
					$this->gitUpdates($containerNames['testrunner'],$gitUpdates);
					
					echo "\nGIT update testrunner:\n";
					$cmd='docker exec '.$containerNames['testrunner'].' /usr/bin/git -C /var/www/testrunner  pull';
					echo exec($cmd);
					// allow db to start
					sleep(15);
					echo "\n";
					// RUN TESTS
					echo "RUN TESTS: ".$containerNames['cmfive']."\n";
					echo "==============================================\n";
					$cmd='docker exec '.$containerNames['testrunner'].' /runtests.sh'."\n";
					echo $cmd;
					echo "==============================================\n";
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
			$this->showDiskSpace();
			$this->listRunningContainers();
		}
	}
	
	function createSwapDrive($container) {
		echo exec('fallocate -l 2048M /swapfile');
		echo exec('dd if=/dev/zero of=/swapfile bs=1M count=2048');
		echo exec('chmod 600 /swapfile');
		echo exec('mkswap /swapfile');
		echo exec('swapon /swapfile');
	}
	
	function killSwapDrive($container) {
		echo exec('swapoff /swapfile');
		echo exec('rm /swapfile');
	}
	
	function buildImage($image,$version='') {
		$buildPath='';
		$tag='';
		if ($image=='cmfive') {
			$buildPath=dirname(__FILE__).'/../';
			$tag='2pisoftware/cmfive';
			if (strlen(trim($version))>0) $tag.=":".$version;
		} else if (file_exists(dirname(__FILE__).'/../compose/'.$image."/Dockerfile"))  {
			$buildPath=dirname(__FILE__).'/../compose/'.$image."/";
			$tag='2pisoftware/'.$image;
		} else if ($image=='2picrm') {
			throw new Exception('2picrm build not implemented');
		} else {
			throw new Exception ('No valid build specified');
		}
		
		$cmd='docker build -t '.$tag.' '.$buildPath;
		//echo $cmd;
		echo "Build image ".$image;
		echo exec($cmd);
	}
	
	function showCmfivePorts($container,$domain) {
		$output=[];
		echo "WEB:  ";
		exec("docker port ".$container." 80",$output);
		$parts=explode(':',$output[0]);
		$subdomain=implode('.',array_slice(explode('.',$domain),1));
		echo 'http://'.$domain." OR http://master.".$subdomain.':'.$parts[1];
		echo "\n";
		echo "SSH:  ";
		exec("docker port ".$container." 22",$output);
		$parts=explode(':',$output[0]);
		echo $domain.':'.$parts[1];
		echo "\n";
		echo "MYSQL:  ";
		exec("docker port ".$container." 3306",$output);
		$parts=explode(':',$output[0]);
		echo $domain.':'.$parts[1];
		echo "\n";
	}
	
	function showSeleniumPorts($container,$domain) {
		echo "VNC:  ";
		exec("docker port ".$container." 5900",$output);
		$parts=explode(':',$output[0]);
		echo $domain.'::'.$parts[1];
		echo "\n";
	}
					
	function ensureWebProxy() {
		echo "\n";
		$output=shell_exec('docker ps');
		$found=0;
		$result='';
		$output=[];
		if (strpos($output,'nginxproxy_nginxproxy')==false) {
			$path=realpath(dirname(__FILE__).'/../nginx-proxy/docker-compose.yml');
			$cmd='docker-compose -f '.$path.' up -d 2>&1';
			exec($cmd,$output,$result);
			if ($result==0) {
				$found=1;
			} else {
				$found=-1;
			}
		}
		if (strpos($output,'nginxgen')==false) {
			// cleanup before run
			shell_exec('docker kill nginxgen 2>&1');
			shell_exec('docker rm nginxgen 2>&1');
			sleep(3);
			$cmd='docker run -d --name nginxgen --volumes-from nginxproxy_nginxproxy_1  -t jwilder/docker-gen:0.3.4 -notify-sighup nginx -watch --only-published /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf';
			exec($cmd,$output,$result);
			if ($result==0) {
				$found=1;
			} else {
				$found=-1;
			}
		}
		if ($found==1) {
			echo "Started web proxy\n";
		} else if ($found==1) {
			echo "Failed to start web proxy\n";
		}
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
				// templating to avoid environment variables in windows
				$composerFileContents=file_get_contents($composerFile);
				$newComposerFileContents=str_replace('${VIRTUAL_HOST}',trim($hostname),$composerFileContents);
				//echo "NewCONTNTE:".$newComposerFileContents;
			}
		}
		// write templated version of composer file
		file_put_contents($composerFile,$newComposerFileContents);
		
		// run the composer up script and capture error output too
		$cmd=$hostConfig.'docker-compose -f '.$composerFile.$nameFlag.' up -d';
		$output=[];
		$output=shell_exec($cmd.' 2>&1');
		
		// restore the composer file as a template
		file_put_contents($composerFile,$composerFileContents);
		
		// process output
		$containerName='';
		$description='';
		$lines=explode("\n",$output);
		$containerNames=['cmfive'=>'','testrunner'=>'','selenium'=>''];
		foreach ($lines as $line) {
			$parts=explode(' ',$line);
			//print_r($parts);
			if (trim($parts[0])=="Creating" || trim($parts[0])=="Recreating"|| trim($parts[0])=="Starting") {
				$description=$parts[0].' container '.$parts[1];
				$iparts=explode('_',$parts[1]);
				if (count($iparts)>1 && strlen(trim($iparts[1]))>0) {
					$containerNames[$iparts[1]]=trim($parts[1]);
				}
			} else if(count($parts)>2 && trim($parts[1])=="is" && trim($parts[2])=="up-to-date") {
				$description='Container '.$parts[0].' is up to date';
				$iparts=explode('_',$parts[0]);
				if (count($iparts)>1 && strlen(trim($iparts[1]))>0) {
					$containerNames[$iparts[1]]=trim($parts[0]);
				}
			}
			echo $description."\n";
		}
		if (array_key_exists('cmfive',$containerNames)) echo "CMFIVE CONTAINER:  ".$containerNames['cmfivecomplete']."\n";
		if (array_key_exists('testrunner',$containerNames)) echo "TESTRUNNER CONTAINER:  ".$containerNames['testrunner']."\n";
		if (array_key_exists('selenium',$containerNames)) echo "SELENIUM CONTAINER:  ".$containerNames['selenium']."\n";
		echo "HOSTNAME:  ".$hostname."\n";
		return $containerNames;
	}
	
	function selfUpdate() {
		$path=realpath(dirname(__FILE__).'../');
		$gitBin='/usr/bin/git';
		$cmd=$gitBin.' -C '.$path.' pull';
		if ($this->windows) {
			$cmd='git.bat  -C "'.$path.'" pull';
		}
		
		//echo $cmd;
		//echo 
		shell_exec($cmd);
	}
/*	
						
	function gitUpdates($containerName,$gitUpdates) {
		// GIT CHECKOUT
		echo "GIT UPDATES TO ".$containerName." - ".$gitUpdates."\n";
		if (!empty($gitUpdates))  {
			$parts=explode(",",$gitUpdates);
			foreach ($parts as $commitDetails) {
				$subparts=explode(':',$commitDetails);
				if (count($subparts)==2) {
					$folder=$subparts[0];
					$commitId=$subparts[1];
					// check folder exists in /var/www
					$cmd='docker exec '.$containerName.' /bin/ls  /var/www/'.$folder.'/.git';
					$output=[];
					$result=null;
					exec($cmd,$output,$result);	
					//print_r([$cmd,$output,$result]);
					if ($result==0) {
						echo "Force checkout of ".$folder." to ".$commitId."\n";
						$cmd='docker exec '.$containerName.' /usr/bin/git -C /var/www/'.$folder.'  checkout -f '.$commitId;
						$output=[];
						$result=null;
						exec($cmd,$output,$result);	
						//print_r([$output,$result]);
						echo "Pull latest changes\n";
						echo shell_exec('docker exec '.$containerName.' /usr/bin/git -C /var/www/'.$folder.'  pull');
						
					}
					echo "\n";
				}
			}
		}
	}
	*/
	
	function getWildCardBaseDomain() {
		if (file_exists(dirname(__FILE__)."/WILDCARD_DOMAIN"))  {
			//return trim(file_get_contents(dirname(__FILE__)."/WILDCARD_DOMAIN"));
			return "docker";
		} else {
			return "docker";
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
			echo "No running containers to kill\n";
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
			echo "No stopped containers to kill\n";
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
			echo "No dangling images to kill\n";
		}
	}
	
	function removeUnusedVolumes() {
		$output=[];
		$cmd="docker volume ls -q";
		exec($cmd,$output);
		$result='';
		$a=0;  // skip header row
		$found=false;
		if (count($output)>1)  {
			foreach ($output as $id) {
				if ($a>0) {
					$cmd='docker volume rm '.$id.' 2>&1' ;
					$ioutput=[];
					exec($cmd,$ioutput,$result);
					if (!$result) {
						echo "Removed volume ".$id."\n";
						$found=true;
					}
				}
				$a++;
			}
		}
		if (!$found) {
			echo "No unused volumes to kill\n";
		}
	}
	
	
	
	// DISK SPACE
	function showDiskSpace() {
		return;
		if ($this->windows) {
			echo "\n";
			$cmd="wmic logicaldisk get size,freespace,caption";
			echo "DISK USAGE:"; //.$cmd ;
			$output=[];
			exec($cmd,$output);
			//print_r($output);
			$diskSpace='';
			foreach ($output as $line) {
				$parts=explode(' ',$line);
				if ($parts[0]=='C:') {
					$used=0;
					$size=0;
					foreach (array_slice($parts,1) as $part) {
						if ($part>0) {
							if ($used>0) {
								$size=$part;
							} else {
								$used=$part;
							}
						}
					}
					$diskSpace=round(100-($used/$size)*100,2);
					//print_r([$used,$size,$diskSpace]);
					
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



}


