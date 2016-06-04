#!/bin/bash
export params="$@"
. /var/www/testrunner/setenvironment.sh /environment.cmfive.docker.csv
/var/www/testrunner/runtests.sh $params
