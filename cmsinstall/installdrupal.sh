#!/bin/bash
set -x
u=drupal
p=drupal
d=drupal
url=http://localhost
path=/home/velofille/www/
DRUPALVER=6.17
MYSQLROOTPASS=069rerror
apacheuser=www-data:www-data
     echo Installing drupal
      cd /tmp
      # install cron 45 * * * * /usr/bin/wget -O - -q http://localhost/drupal/cron.php > /dev/null 2>&1
      wget --quiet http://ftp.drupal.org/files/projects/drupal-${DRUPALVER}.tar.gz
      tar zxf drupal-${DRUPALVER}.tar.gz
      cp -a drupal-${DRUPALVER}/* $path/
      cp -a drupal-${DRUPALVER}/.htaccess $path/
      cd $path/
      #newdburl="\$db_url = 'mysql://${u}:${p}\@localhost\\/${d}';"

      #cat sites/default/default.settings.php |sed s/^\$db_url.*/"$newdburl"/g > sites/default/settings.php 
      cp sites/default/default.settings.php sites/default/settings.php 
      chmod 666 sites/default/settings.php
      #surl=$(echo $url | sed s/http\:\\/\\/// )
      #sed -i s/\#\ \$cookie_domain\ =\ \'example.com\'\;/\$cookie_domain\ =\ \'$surl\'\;/ sites/default/settings.php  # saves having to use cookies
      chown -R $apacheuser $path # change this to check what user apache runs as
	find $path -type d | while read pathdirs ; do chmod 775 "$pathdirs" ; done
	find $path -type f | while read pathfiles ; do chmod 664 "$pathfiles" ; done

      curl -L -c ~/cookies.txt  "$url/install.php?profile=default&op=do_nojs&id=1" >~/errors/page1.html  
      #sed -i s/\#\ \$cookie_domain\ =\ \'example.com\'\;/\$cookie_domain\ =\ \'$surl\'\;/ sites/default/settings.php  # saves having to use cookies

      curl -L -c ~/cookies.txt "$url/install.php?profile=default&locale=en&op=do_nojs&id=1" >~/errors/page2.html 
      #sed -i s/\#\ \$cookie_domain\ =\ \'example.com\'\;/\$cookie_domain\ =\ \'$surl\'\;/ sites/default/settings.php  # saves having to use cookies

      form_build_id=form-$(cat ~/errors/page2.html |grep form_build_id | sed 's/.* value=\"form-\([a-f0-9]*\)\".*/\1/g')
      curl -L -c ~/cookies.txt  -d "db_type=mysqli&db_path=$d&db_user=$u&db_pass=$p&db_host=localhost&db_port=&db_prefix=&op=Save and continue&form_build_id=${form_build_id}&form_id=install_settings_form" "$url/install.php?profile=default&locale=en&op=do_nojs&id=1"  >~/errors/page3.html  
	read
      sed -i s/\#\ \$cookie_domain\ =\ \'example.com\'\;/\$cookie_domain\ =\ \'$surl\'\;/ sites/default/settings.php  # saves having to use cookies
curl -L -c ~/cookies.txt "$url/install.php?profile=default&locale=en&op=finished&id=1"
      #unset form_field_id
      form_build_id=form-$(cat ~/errors/page3.html |grep form_build_id | sed 's/.* value=\"form-\([a-f0-9]*\)\".*/\1/g')
      #if [ -z $form_field_id ];then echo "Oh dear, something unexpected went wrong with the install" ; fi
      curl -L -c ~/cookies.txt -d "site_name=$url&site_mail=$adminmail&account[name]=admin&account[mail]=$adminmail&account[pass][pass1]=$p&account[pass][pass2]=$p&clean_url=0&date_default_timezone=-39600&update_status_module[1]=1&op=Save%20and%20continue&form_id=install_configure_form&form_build_id=${form_build_id}" "$url/install.php?profile=default&locale=en&op=do_nojs&id=1" >~/error.html 

      chmod 444 sites/default/settings.php
      #rm -rf /tmp/dbconfpage.tmp /tmp/dbconfpage2.tmp /tmp/drupal-${DRUPALVER}/
      echo You can now open $url in your browser and login with the username admin and password $p
