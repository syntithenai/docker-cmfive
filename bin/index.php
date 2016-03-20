<?php 
include "DockerManager.php";

try {
	// handle CLI arguments
	if (php_sapi_name() == 'cli') {
		$d=new DockerManager();
		$d->run($argv);
	} else {
		$d=new DockerManager();
		if (array_key_exists('action',$_POST) && $_POST['action']=="up")  {
			//if ($_POST['']) 
		} else {
			$d=new DockerManager();
			echo "<b>";
			$d->showDiskSpace();
			echo "</b>";
			echo "<table>";
			echo "<tr><th>Container</th><th>Image</th><th>Age</th></tr>";
			$activeContainers= file_get_contents('/tmp/docker-manager/activecontainers');
			foreach (explode("\n",$activeContainers) as $containerRow) {
				echo "<tr>";
				$parts=explode(" ",$containerRow);
				$finalParts=[];
				foreach ($parts as $part) {
					if (strlen(trim($part))>0) {
						$finalParts[]=$part;
					}
				}
				$meta['containerName']=$finalParts[13];
				$meta['image']=$finalParts[1];
				$meta['age']=$finalParts[7].' '.$finalParts[8];
				echo "<td>".$meta['containerName']."</td>";
				echo "<td>".$meta['image']."</td>";
				echo "<td>".$meta['age']."</td>";
				echo "<tr>";
			}
			echo "</table>";
		}
	}
} catch (Exception $e) {
	echo $e->getMessage();
}	
