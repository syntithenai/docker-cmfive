<?php
/** 
 * Handle HTTP request by creating a WebHookTrigger and writing it as a job file
 */

class WebHookHandler {
	
	var $jobsFolder=__DIR__.'/../jobs/';
	var $config;
	
	function __construct($config) {
		$this->config=$config;
	}
	
	/**
	 * Extract HTTP_ values from server vars
	 */
	function getAllHeaders() { 
		$headers = ''; 
		foreach ($_SERVER as $name => $value) { 
			if (substr($name, 0, 5) == 'HTTP_')  { 
				$headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value; 
			} 
		} 
		return $headers; 
	}
	
	/**
	 * Write a trigger as a job file
	 */
	function writeJob($trigger) {
		$a=time();
		sleep(2);
		if (!is_dir($this->jobsFolder)) mkdir($this->jobsFolder,  0777, true);
		if ($trigger->isActionable($this->config)) {
			file_put_contents($this->jobsFolder.$a.".txt",$trigger->asJob()."\n");
		}
	}
	
	/**
	 * Handle the request
	 */
	function run() {
		try {
			$b=json_decode(@file_get_contents('php://input'));
			$h=$this->getAllHeaders();
			$trigger = new WebHookRequest($h,$b);
			$this->writeJob($trigger);   
		} catch (Exception $e) {
			echo "Invalid request";
		}
	}
}
