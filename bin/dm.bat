@echo off
php -f %~dp0\index.php selfupdate
php -f %~dp0\index.php %*
