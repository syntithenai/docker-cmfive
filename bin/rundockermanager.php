<?php 
include "DockerManager.php";

try {
	// handle CLI arguments
	if (php_sapi_name() == 'cli') {
		$d=new DockerManager();
		$d->run($argv);
	}
} catch (Exception $e) {
	echo $e->getMessage();
}	
