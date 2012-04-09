#!/bin/bash
# you need zip/unzip installed for this to work
#
# args are path and http://domain/path
# if you set your mysql root pass this will not be requested during the install
set -x
# either set this or do it on the commandline before running with 'export MYSQLROOTPASS=
MYSQLROOTPASS=069rerror


# version number variables for each changes when upgrades are available :)
DRUPALVER=6.17
SILVERSVER=v2.4.0
MAGENTOVER=1.4.1.0

# set this to the user you want to own the files (ie www-data:www-data 
# it defaults to the standard debian/redhat users otherwise depending on distro
# only required if you have a custom setup
APACHEUSER=

function precheck {
  echo Checking things work ..
  checkdistro
  checkforarray="zip tar gunzip curl mysql sed cut mysql wget sed uuencode "
  for checkfor in $checkforarray ; do checkinstalled $checkfor ; done
  PHPVER=$(php -v | sed "2,3d" | awk '{print $2}' | cut -c-5 )

}
function checkinstalled {
  echo -n "check for $checkfor "
  if [ -z `whereis $checkfor | awk '{print $2}'` ];then
      echo not found 
      if [ $distro == "redhat" ];then
	yum update
	yum install $checkfor
      elif [ $distro == "debian" ]; then
	apt-get update
	apt-get install $checkfor
      else
	echo Unable to detect OS to install this - manual intervention needed
	exit 0
      fi
  else
    echo installed
  fi
}
function checkdistro {
    if [ -e /etc/debian_version ];then
	echo Detected a debian/ubuntu distro
	distro=debian
	if [ -z ${APACHEUSER} ] ;then
	   apacheuser=www-data:www-data
	fi
	# apache2ctl -M |grep rewrite_module
    elif [ -e /etc/redhat-release || -e /etc/redhat_version ];then
	echo Detected a redhat/centos distro
	distro=redhat
	#install sharutils-4.6.1-2.i386/uuencode
	if [ -z ${APACHEUSER} ] ;then
	   apacheuser=www-data:www-data
	fi
    else
      echo "Cant figure out if this is redhat or debian based - this may break some things"
    fi
#Novell SuSE---> /etc/SuSE-release 
#Red Hat--->/etc/redhat-release, /etc/redhat_version
#Fedora-->/etc/fedora-release
#Slackware--->/etc/slackware-release, /etc/slackware-version
#Debian--->/etc/debian_release, /etc/debian_version
#Mandrake--->/etc/mandrake-release
#Yellow dog-->/etc/yellowdog-release
#Sun JDS--->/etc/sun-release 
#Solaris/Sparc--->/etc/release 
#Gentoo--->/etc/gentoo-release
}

function install_wordpress {
	echo "Installing wordpress"

	# clean previously installed stuff  
	# perhaps ask ?

	
	cd /tmp
	wget --quiet -O latest.tar.gz http://wordpress.org/latest.tar.gz
	tar zxf latest.tar.gz
	mkdir -p ${path}/
	cp -a wordpress/* ${path}/
	

	cd ${path}
	
	cat wp-config-sample.php | sed -e "s/_NAME.*$/_NAME\', \'$d\'\);/" | \
    	sed -e "s/_USER.*$/_USER\', \'$u\'\);/" | \
    	sed -e "s/_PASSWORD.*$/_PASSWORD\', \'$p\'\);/" > wp-config.php
	/bin/chown -R $apacheuser $path # change this to check what user apache runs as
      # install wordpress (a few curls)
      curl -q $url/wp-admin/install.php?step=1 > /dev/null 2>&1
      curl --data "admin_email=$adminmail&weblog_title=$url" $url/wp-admin/install.php?step=2 > /dev/null 2>&1
# id like to automate more here when i get a chance - auto install wp-supercache and enable?
# left this here in case anyone wants to automate other things
#cat <<EOF | mysql -u root -p${MYQLROOTPASS}
#USE $d;
#UPDATE wp_users SET user_pass = MD5( 'admin' ) , user_firstname = 'FirstName', user_lastname = 'LastName', user_email = '${adminmail}' WHERE ID = '1';
#UPDATE wp_options SET option_value = '$adminmail' where option_name = 'admin_email';
#UPDATE wp_options SET option_value = '/categories' where option_name = 'category_base';
#UPDATE wp_options SET option_value = '$url' where option_name = 'blogname';
#UPDATE wp_options SET option_value = 'j.m.Y' where option_name = 'date_format';
#UPDATE wp_options SET option_value = 'H:i' where option_name = 'time_format';
#UPDATE wp_options SET option_value = '/archives/%year%/%monthnum%/%day%/%postname%/' where option_name = 'permalink_structure';
#UPDATE wp_options SET option_value = 'http://rpc.technorati.com/rpc/ping\nhttp://rpc.pingomatic.com/\nhttp://www.weblogues.com/RPC/\nhttp://topicexchange.com/RPC2' where option_name = 'ping_sites';
#INSERT INTO wp_options ( option_id , blog_id , option_name , option_can_override , option_type , option_value , option_width , option_height , option_description , option_admin_level , autoload )
#VALUES (
#'', '0', 'active_plugins', 'Y', '1', 'a:8:{i:0;s:0:"";i:1;s:27:"SK2/spam_karma_2_plugin.php";i:2;s:17:"backuprestore.php";i:3;s:14:"bunny-tags.php";i:4;s:12:"markdown.php";i:5;s:24:"wp-plugin-mgr-plugin.php";i:6;s:16:"wp-theme-mgr.php";i:7;s:19:"wp_freeze_users.php";}', '20', '8', '', '1', 'yes'
#);
#EOF

}

function install_drupal {
   echo Installing drupal
      cd /tmp
      # install cron 45 * * * * /usr/bin/wget -O - -q http://localhost/drupal/cron.php > /dev/null 2>&1
      wget --quiet http://ftp.drupal.org/files/projects/drupal-${DRUPALVER}.tar.gz
      tar zxf drupal-${DRUPALVER}.tar.gz
      cp -a drupal-${DRUPALVER}/* $path/
      cp -a drupal-${DRUPALVER}/.htaccess $path/
      cd $path/
      chmod 666 sites/default/settings.php
      chown -R $apacheuser $path # change this to check what user apache runs as
# this shit is so messed up. Relying on cookies and multiple passes to install things without javascript
curl -L -c ~/cookies.txt -d "db_path=$d&db_user=$u&db_pass=$p&db_host=localhost&db_prefix=&db_port=&op=Save+and+continue&form_id=install_settings_form" "http://localhost/install.php?profile=default&locale=en"
# second pass this time with cookies
curl -L -c ~/cookies.txt -b ~/cookies.txt -d "db_path=$d&db_user=$u&db_pass=$p&db_host=localhost&db_prefix=&db_port=&op=Save+and+continue&form_id=install_settings_form" "http://localhost/install.php?profile=default&locale=en"
# three passes on this one for database install/setup (20% 80% etc)
curl -L -c ~/cookies.txt -b ~/cookies.txt "http://localhost/install.php?profile=default&locale=en&op=do_nojs&id=1"
curl -L -c ~/cookies.txt -b ~/cookies.txt "http://localhost/install.php?profile=default&locale=en&op=do_nojs&id=1"
curl -L -c ~/cookies.txt -b ~/cookies.txt "http://localhost/install.php?profile=default&locale=en&op=finished&id=1"
# final setup to finish
curl -L -c ~/cookies.txt -b ~/cookies.txt -d "site_name=site_name&site_mail=$adminmail&account[name]=admin&account[mail]=$adminmail&account[pass][pass1]=$p&account[pass][pass2]=$p&date_default_timezone=-39600&clean_url=1&form_id=install_configure_form&update_status_module[1]=1" "http://localhost/install.php?profile=default&locale=en"


      
      chmod 444 sites/default/settings.php
      #rm -rf /tmp/dbconfpage.tmp /tmp/dbconfpage2.tmp /tmp/drupal-${DRUPALVER}/
      echo You can now open $url in your browser and login with the username admin and password $p
}    



function install_silverstripe {
  echo Installing Silverstripe
      # props go out to Simon_w and the silverstripe crew for helping me with this one superfast!
      cd /tmp
      wget --quiet http://www.silverstripe.org/assets/downloads/SilverStripe-${SILVERSVER}.tar.gz
      tar zxf SilverStripe-${SILVERSVER}.tar.gz
      cp -a silverstripe-${SILVERSVER}/* $path/
      cp -a silverstripe-${SILVERSVER}/.htaccess $path/
      cd $path/

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
# applying a patch to fix a bug in ubuntu 10.04 (next release wont need this) 
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
      chown -R $apacheuser $path 
if which sake > /dev/null
then
	sake dev/build
else
	php sapphire/cli-script.php dev/build 
fi


      echo "Because silverstripe is slightly more fussy about its install and conditions I wont remove the install files. Check that its working fine, then go to  $url/home/deleteinstallfiles to remove these"
}
function install_xoops {
cd /tmp
wget xoops.zip
curl -d "lang=english" $url/install.index.php
curl $url/install/page_start.php
/install/page_modcheck.php
/install/page_pathsettings.php
curl -d "root=${path}&data=${path}/xoops_data&lib=${path}/xoops_lib&URL=$url" $url/install/page_pathsettings.php
curl -d "DB_TYPE=mysql&DB_HOST=localhost&DB_USER=$u&DB_PASS=$p" $url/install/page_dbconnection.php
curl -d "DB_NAME=$d&DB_PREFIX=xa9b&DB_CHARSET=utf8&DB_COLLATION=utf8_general_ci" $url/install/page_dbsettings.php
curl $url/install/page_configsave.php
curl $url/install/page_tablescreate.php
curl $url/install/page_siteinit.php 
curl -d "adminname=admin&adminmail=$adminmail&adminpass=admin&adminpass2=admin" $url/install/page_siteinit.php
curl $url/install/page_tablesfill.php
curl -d "sitename=$url&slogan=editme&meta_keywords=xoops&meta_description=editme&meta_author=Xoops&meta_copyright=$url&allow_register=1" $url/install/page_configsite.php
curl $url/install/page_theme.php
curl -d "theme_set=zetagenesis" $url/install/page_theme.php
curl $url/page_moduleinstaller.php
curl -d "modules[pm]=1&modules[profile]=1&modules[protector]=1" $url/install/page_moduleinstaller.php
curl $url/install/page_end.php
}

function install_magento {
# need to check for PHP 5.2 - also need to fix simpleXML which is broken
 sed -i s/"memory_limit = 32M"/"memory_limit = 128M"/g /etc/php.ini
  # yum install php-cli
      cd /tmp
      wget -q  http://www.magentocommerce.com/downloads/assets/${MAGENTOVER}/magento-downloader-${MAGENTOVER}.tar.gz
      tar -zxvf magento-downloader-${MAGENTOVER}.tar.gz
      cp -a magento/*   "$path/"
      cp magento/.htaccess  "$path/"
      cd "$path"
      chmod -R o+w media
      ./pear mage-setup .
      ./pear install magento-core/Mage_All_Latest-stable
      chmod o+w var var/.htaccess app/etc
      rm -rf downloader/pearlib/cache/* downloader/pearlib/download/*
      #rm -rf magento/ magento-downloader-${MAGENTOVER}.tar.gz
      chown -R $apacheuser $path 
      # php-cgi/php-cli ?
      php-cgi -f install.php -- \
      --license_agreement_accepted "yes" \
      --locale "en_US" \
      --timezone "America/Los_Angeles" \
      --default_currency "USD" \
      --db_host "localhost" \
      --db_name "$d" \
      --db_user "$u" \
      --db_pass "$p" \
      --url "$url" \
      --use_rewrites "yes" \
      --use_secure "no" \
      --secure_base_url "" \
      --use_secure_admin "no" \
      --admin_firstname "Administrator" \
      --admin_lastname "Changeme" \
      --admin_email "$adminmail" \
      --admin_username "admin" \
      --admin_password "admin"
#http://www.magentocommerce.com/getmagento/1.4.1.0/magento-1.4.1.0.tar.gz

}


if [ $2 ];then
  path=$1
  url=$2
  name=$3
  d=$4
  u=$5
  sname=$(echo $url | sed s@http://@@ | sed s/\\.//g | cut -c1-12)

if [ $(whoami) != "root" ]
then
  echo "You need to run this script as root."
  exit 1
fi

if [ ! -z ${d}  ];then
	  echo -n "No database provided - generating one "
	  d=$sname
fi
if [ ! -z ${u}  ];then
	  echo -n "Please provide the password for the database user $u "
	  read $u
	  u=$(head -c 10 /dev/random | uuencode -m - |grep  [:alphanum:] | tail -n 2 | head -n 1 |  sed 's/[^a-zA-Z0-9]//g' )
fi


 precheck

  echo -n "Please provide admin email to send the admin details to "
  read adminmail

  if [ -z ${name} ]; then
  PS3="Choose (1-5):"
  select name in wordpress drupal silverstripe joomla oscommerce
  do
        break
  done
  fi

		
if [ -z ${d} ];then
    d=${sname}
    u=${sname}
    p=$(head -c 10 /dev/random | uuencode -m - | tail -n 2 | head -n 1 | sed 's/[^a-zA-Z0-9]//g')
fi

if [ -z ${MYSQLROOTPASS} ];then
	echo I see you did not set your mysql root password as a variable - you will be prompted for it now as i setup databases and users
fi
      echo CREATE DATABASE IF NOT EXISTS $d CHARACTER SET = utf8 COLLATE = utf8_unicode_ci\;| mysql -u root -p${MYSQLROOTPASS}
      echo GRANT ALL PRIVILEGES ON $d.\* to \'$u\'@\'localhost\' IDENTIFIED BY \'$p\' WITH GRANT OPTION\; | mysql -u root -p${MYSQLROOTPASS}
      echo FLUSH PRIVILEGES\;| mysql -u root -p${MYSQLROOTPASS}

  install_$name

else
  echo "usage: $0 /path/to/docroot http://url.com/blog [wordpress|silverstripe|drupal|joomla|oscommerce] database databaseuser"
  echo "Database & Database user are optional, and should never be the root user"
fi
