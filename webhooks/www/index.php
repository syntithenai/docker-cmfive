<?php
/**
 * This file handles a github or bitbucket webhook callback
*/

require_once(__DIR__.'/config.php');
require_once(__DIR__.'/WebHookRequest.php');
require_once(__DIR__.'/WebHookHandler.php');

$w=new WebHookHandler($webHookConfig);
$w->run();
