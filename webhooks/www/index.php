<?php
/**
 * This file handles a github or bitbucket webhook callback
 * If the callback specifies a tag on the master branch a docker build is triggered
 * If the callback specifies a build on the development branch test are run and the committer is notified
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
		file_put_contents($this->jobsFolder.$a.".txt",$command.'	'.$content."\n");
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
		$this->writeJob('log',$content);
		
		// TAG ON MASTER BRANCH - BUILD CMFIVE IMAGE
		if (array_key_exists('X-Github-Event',$h) && $h['X-Github-Event']==='create' && $b->ref_type=="tag") {
			$content=$b->repository->full_name." ".$b->ref;
			$this->writeJob('build',$content);
		// PUSH - RUN TESTS
		} else if (array_key_exists('X-Github-Event',$h) && $h['X-Github-Event']==='push') {
			$repo=$b->repository->name;
			$user=$b->pusher->email;
			$gitId=$b->after;
			
		} else if (array_key_exists('X-Event-Key',$h) &&  $h['X-Event-Key']==='repo:push') {
			$repo=$b->repository->name;
			$user=''; //syntithenai@gmail.com';
			if (!empty($b) &&  !empty($b->push) && is_array($b->push->changes)) {
				foreach ($b->push->changes as $change) {
					foreach ($change->commits as $commit) {
						$user=$commit->author->raw;
					}
				}
			}
		} else { 
			echo "Invalid Request";
		}   
	}
}


$w=new WebHookHandler();
$w->run();
