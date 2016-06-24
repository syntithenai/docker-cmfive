<?php
/**
 * Provides a standard interface to github and bitbucket webhook callbacks
 */

class WebHookRequest {
	var $h;  // headers
	var $b;  // body
	
	/** Constructor
	 * @param Array $headers
	 * @param Array $body
	 */
	function __construct($headers,$body) {
		$this->h=$headers;
		$this->b=$body;
	}
	
	/**
	 * Return a string that can be written to file to serialise this job
	 * @return string
	 */
	function asJob() {
		return json_encode(['headers'=>$this->h,'body'=>$this->b]);
	}
	
	/**
	 * Check if this request should be ignored
	 * 	- limit by servers configuration
	 *  - limit by request source
	 *  - limit by secret hash (github only) (PENDING)
	 * @return boolean
	 */
	function isActionable($config) {
		//[HTTP_USER_AGENT] => Bitbucket-Webhooks/2.0
		if (array_key_exists(trim($this->getRepositoryUrl()),$config['repositories'])) {
			$repo=$config['repositories'][trim($this->getRepositoryUrl())];
			// require that the current action matches an available trigger
			if (array_key_exists($this->getAction(),$repo['triggers'])) {
				// allow for push subkey as branch
				if ($this->getAction()=="push") {
					if (array_key_exists($this->getBranch(),$repo['triggers']['push'])) {
						echo "OK";
						return true;
					}
				}
			}
		}
		return false;
	}
	
	/** 
	 * Return the action derived from this request
	 * @return string  push|tag     (PENDING)|pullrequest|branch
	 */
	function getAction() {
		if (!empty($this->getTag()))  {
			return 'tag';
		} else if (!empty($this->getBranch()))  {
			return 'push';
		}
	}
	
	/** 
	 * Return the type of this repository - github or bitbucket
	 * @return string
	 */
	function getRepositoryType() {
		if (array_key_exists('X-Github-Event',$this->h)) {
			return 'github';
		} else if (array_key_exists('X-Event-Key',$this->h)) {
			return 'bitbucket';
		} else {
			throw new Exception('Invalid request');
		}
	}
	
	/**
	 * Return the SSH url for this repository
	 * @return string
	 */
	function getRepositoryUrl() {
		if ($this->getRepositoryType()=='github') {
			return $this->b->repository->git_url;
		} else if ($this->getRepositoryType()=='bitbucket') {
			return 'git@bitbucket.org:'.$this->getRepositoryName().".git";
		}
	}

	/**
	 * Return the name of the repository
	 * @return string
	 */
	function getRepositoryName() {
		return $this->b->repository->full_name;
	}
	
	/** 
	 * Return the tag that was pushed
	 * @return string
	 */
	function getTag() {
		if ($this->getRepositoryType()=='github') {
			if ($this->b->ref_type=="tag") return $this->b->ref;
		} else if ($this->getRepositoryType()=='bitbucket') {
			// only use the last tag
			$tag='';
			foreach ($this->b->push->changes as $change) {
				if (!empty($change->new))  {
					if ($change->new->type=="tag") {
						$tag=$change->new->name;
					}
				} 
			}
		}
	}
	
	/** 
	 * Return the email of the user associated with this push
	 * @return string
	 */
	function getEmail() {
		if ($this->getRepositoryType()=='github') {
			$user=$this->b->pusher->email;
			// just the email
			if (strpos($user,'<')!==false) {
				$parts=explode("<",$user);
				$user=substr($parts[1],0,-1);
			} 
			
		} else if ($this->getRepositoryType()=='bitbucket') {
			foreach ($this->b->push->changes as $change) {
				// last values of array
				foreach ($change->commits as $commit) {
					$user=$commit->author->raw;
				}
			}
			// just the email
			if (strpos($user,'<')!==false) {
				$parts=explode("<",$user);
				$user=substr($parts[1],0,-1);
			} 
		}
	}
	
	/** 
	 * Return the commit hash for the last commit of this push
	 * @return string
	 */
	function getVersion() {
		if ($this->getRepositoryType()=='github') {
			$branch='';
			$branchParts=explode("/",$this->b->ref);
			if (count($branchParts)==3)  {
				$branch=$branchParts[2];
			}
		} else if ($this->getRepositoryType()=='bitbucket') {
			foreach ($this->b->push->changes as $change) {
				if (!empty($change->new))  {
					if ($change->new->type=="branch") {
						$branch=$change->new->name;
					}
				} 
			}
		}
		return $version;
	}
	
	/** 
	 * Return the name of the branch for this push
	 * @return string
	 */
	function getBranch() {
		$branch='';
		if ($this->getRepositoryType()=='github') {
			$branchParts=explode("/",$this->b->ref);
			if (count($branchParts)==3)  {
				$branch=$branchParts[2];
			}
		} else if ($this->getRepositoryType()=='bitbucket') {
			foreach ($this->b->push->changes as $change) {
				if (!empty($change->new))  {
					if ($change->new->type=="branch") {
						$branch=$change->new->name;
					}
				} 
			}
		}
		return $branch;
	}
	
}


