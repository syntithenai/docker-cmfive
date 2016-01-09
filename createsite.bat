echo off
echo %~dp0
IF [%1] == [] GOTO NOVHOST

REM IF NOT EXIST %PATH GOTO INVALIDPATH
REM check domain
REM ping -n 2 %1; if [%@] == [False] GOTO NOPING
cd %~dp0
mkdir sites
cd sites
mkdir %1
cd %1
mkdir www
copy -a %~dp0\www\ .\www\
copy %~dp0docker-compose.yml.template docker-compose.yml
%~dp0fart docker-compose.yml __VIRTUAL_HOST__  %1
%~dp0fart docker-compose.yml __WWW_PATH__  .\www
%~dp0fart docker-compose.yml __DATABASE_NAME__  cmfive

docker-compose stop
docker-compose up -d

GOTO END

:NODB
echo "You must provide a database name as the first parameter"
GOTO END
:NOVHOST
echo "You must provide a virtual host domain as the second parameter"
GOTO END
:NOPATH
echo "You must provide a path to the www directory as the third parameter"
GOTO END
:INVALIDPATH
echo "Invalid path "
GOTO END
:NOPING
echo "Could not ping domain %1"
GOTO END
:END
