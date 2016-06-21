DIR=`dirname $0`
php -f $DIR/index.php selfupdate
php -f $DIR/index.php $@
