#!/bin/bash
set -x
u=drupal
p=drupal
d=drupal
url=http://localhost
path=/home/velofille/www/
MYSQLROOTPASS=069rerror
apacheuser=www-data:www-data

cd $path
mkdir silverstripe-cache
      chown -R $apacheuser $path # change this to check what user apache runs as
	find $path -type d | while read pathdirs ; do chmod 775 "$pathdirs" ; done
	find $path -type f | while read pathfiles ; do chmod 664 "$pathfiles" ; done
cat << EOF > _ss_environment.php
<?php
define('SS_DATABASE_SERVER', 'localhost');
define('SS_DATABASE_USERNAME', '$u');
define('SS_DATABASE_PASSWORD', '$p');
define('SS_DATABASE_PREFIX', '');
define('SS_ENVIRONMENT_TYPE', 'live');
define('SS_DEFAULT_ADMIN_USERNAME', 'admin');
define('SS_DEFAULT_ADMIN_PASSWORD', '$p');
EOF
# applying a patch to fix a bug in the next release
cat << EOP > /tmp/ss.patch
--- sapphire/core/Core.php	2010-03-16 16:56:59.000000000 +1300
+++ sapphire/core/Core.php	2010-07-07 13:46:04.595508191 +1200
@@ -40,7 +40,7 @@
 /**
  * Include _ss_environment.php files
  */
-$envFiles = array('../_ss_environment.php', '../../_ss_environment.php', '../../../_ss_environment.php');
+$envFiles = array('_ss_environment.php', '../_ss_environment.php', '../../_ss_environment.php', '../../../_ss_environment.php');
 foreach($envFiles as $envFile) {
 	if(@file_exists($envFile)) {
 		define('SS_ENVIRONMENT_FILE', $envFile);


EOP
patch sapphire/core/Core.php </tmp/ss.patch
sed -i s/\$database\ =\ \'\'\;/\$database\ =\ \'$d\'\;/ mysite/_config.php
if which sake > /dev/null
then
	sake dev/build >>build.log
else
	php sapphire/cli-script.php dev/build >>build.log
fi



