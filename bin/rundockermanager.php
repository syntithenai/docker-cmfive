<?php 
include "DockerManager.php";

try {
	// handle CLI arguments
	if (php_sapi_name() == 'cli') {
		$d=new DockerManager();
		if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
			$d->windows=true;
		}
		$d->run($argv);
	}
} catch (Exception $e) {
	echo $e->getMessage();
}	
