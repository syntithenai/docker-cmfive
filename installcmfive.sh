#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#rm -rf $DIR/www

#checkout cmfive and write cmfive config
git clone -b 0-8-0-BRANCH https://github.com/2pisoftware/cmfive.git $DIR/www/cmfive
cp $DIR/src/config.php $DIR/www/cmfive/config.php
cp -a $DIR/src/phpMyAdmin $DIR/www/cmfive/
mkdir $DIR/www/cmfive/storage
mkdir $DIR/www/cmfive/storage/logs
mkdir $DIR/www/cmfive/storage/backups
mkdir $DIR/www/cmfive/storage/session

# update composer libraries now  !!! this should be done in the VM image context
cd $DIR/www/cmfive/system; php composer.phar update; cd -

