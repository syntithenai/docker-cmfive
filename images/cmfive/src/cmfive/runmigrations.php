<?php
if (php_sapi_name() === 'cli')  {
	
	$host=getenv("RDS_HOSTNAME");
	if (strlen(trim($host))==0) {
		$user=getenv("MYSQL_USER");
		$host="localhost";
		$pass=getenv("MYSQL_PASS");
		$db=getenv("ON_CREATE_DB");
	} else {
		$host=getenv("RDS_HOSTNAME");
		$user=getenv("RDS_USERNAME");
		$pass=getenv("RDS_PASSWORD");
		$db=getenv("RDS_DB_NAME");
	}
	if (strlen(trim($db))==0) {
		$db='cmfive';
	}
	
	$cmFivePath="/var/www/cmfive";
	$_SERVER['DOCUMENT_ROOT']=$cmFivePath;
	chdir($cmFivePath);
	require_once('system/db.php');
	require_once('system/web.php');
	require_once('system/modules/admin/models/MigrationService.php');
	require_once('system/modules/admin/models/Migration.php');
	require_once('system/modules/auth/models/User.php');
	require_once "system/composer/vendor/autoload.php";

	$database = array(
		"hostname"  => $host,
		"username"  => $user,
		"password"  => $pass,
		"database"  => $db,
		"driver"    => 'mysql'
	);
	$w = new Web();
	$w->db = new DbPDO($database);

	try {
		// Run migrations
		$w->Migration->installInitialMigration();
	} catch (\Exception $e) {
		echo 'initial migrations error: ' . $e->getMessage();
	}
	try {
		$w->Migration->runMigrations("all");
	} catch (\Exception $e) {
		echo 'migrations error: ' . $e->getMessage();
	}

}
