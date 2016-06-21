<?php
/**
 * This file handles a github or bitbucket webhook callback
 * The callback writes job files which are handled by a cron process (with appropriate permissions)
 * The files are written in the format shown by examples below
 * `tag [cloneurl] [tag]`
 * `push [email] [cloneurl] [commitId] 
 **/


class WebHookHandler {
	
	var $jobsFolder='../jobs/';

	function getAllHeaders() { 
		$headers = ''; 
		foreach ($_SERVER as $name => $value) { 
			if (substr($name, 0, 5) == 'HTTP_')  { 
				$headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value; 
			} 
		} 
		return $headers; 
	}
	
	function writeJob($command,$content) {
		$a=time();
		sleep(2);
		//file_put_contents($this->jobsFolder.$a.".txt",'test	'.$repo.'	'.$gitId.'	'.$user."\n");
		if (!is_dir($this->jobsFolder)) mkdir($this->jobsFolder,  0777, true);
		file_put_contents($this->jobsFolder.$a.".txt",$command.' '.$content."\n");
	}
	
	function run() {
		// DECODE THE BODY AND HEADERS FROM THE WEBHOOK
		$repo='';
		$user='';
		$gitId='';
		$b=json_decode(@file_get_contents('php://input'));
		$h=$this->getAllHeaders();
		ob_start();
		print_r($h);
		print_r($b);
		$content=ob_get_contents();
		ob_end_clean();
		//$this->writeJob('log',$content);
		
		// TAG GITHUB
		if (array_key_exists('X-Github-Event',$h) && $h['X-Github-Event']==='create' && $b->ref_type=="tag") {
			$content=$b->repository->html_url.".git ".$b->ref;
			$this->writeJob('tag',$content);
		// PUSH GITHUB
		} else if (array_key_exists('X-Github-Event',$h) && $h['X-Github-Event']==='push') {
			$repo=$b->repository->name;
			$user=$b->pusher->email;
			// just the email
			if (strpos($user,'<')!==false) {
				$parts=explode("<",$user);
				$user=substr($parts[1],0,-1);
			} 
			$gitId=$b->after;
			$branch='master';
			$branchParts=explode("/",$b->ref);
			if (count($branchParts)==3)  {
				$branch=$branchParts[2];
			}
			$content=$b->repository->html_url.".git "." ".$branch.' '.$gitId.' '.$user;
			$this->writeJob('push',$content);
		// BITBUCKET
		} else if (array_key_exists('X-Event-Key',$h) &&  $h['X-Event-Key']==='repo:push') {
			$repo=$b->repository->full_name;
			$user=''; //syntithenai@gmail.com';
			$tagCount=0;
			$commitCount=0;
			$branch='master';
			if (!empty($b) &&  !empty($b->push) && is_array($b->push->changes)) {
				// TAG
				foreach ($b->push->changes as $change) {
					if (!empty($change->new))  {
						if ($change->new->type=="tag") {
							$this->writeJob('tag','https://bitbucket.org/'.$repo.".git ".$change->new->name);
							$tagCount++;
						} else if ($change->new->type=="branch") {
							$commitCount++;
							$branch=$change->new->name;
						}
					} 
				}
				// if there are commits, also write a push
				$commitId='';
				if ($commitCount>0) {
					foreach ($b->push->changes as $change) {
						// last values of array
						foreach ($change->commits as $commit) {
							$user=$commit->author->raw;
							$commitId=$commit->hash;
						}
					}
					// just the email
					if (strpos($user,'<')!==false) {
						$parts=explode("<",$user);
						$user=substr($parts[1],0,-1);
					} 
					
					// git clone https://steve_ryan@bitbucket.org/steve_ryan/testrepository_bitbucket.git
					$this->writeJob('push ',' http://bitbucket.org/'.$repo.'.git '.$branch.' '.$commitId.' '.$user);
				}
			}
			
			//$content=$user.' '.$repo;
			//$this->writeJob('push',$content);
		} else { 
			echo "Invalid Request";
		}   
	}
}


$w=new WebHookHandler();
$w->run();
