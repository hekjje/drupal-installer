#!/bin/bash

# Text color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

echo $(tput bold)$(tput setaf 4)
echo "*************************************************"
echo "*                                               *"
echo "*          Drupal installation script           *"
echo "*                                               *"
echo "*************************************************"
echo 
echo $(tput setaf 2)Start installing the latest version of Drupal
echo 
echo $(tput sgr0)
echo -e "Enter MySQl username:"
read mysqlusernmae

echo -e "Enter MySQl password:"
read mysqlpassword

echo -e "Enter MySQl host:"
read mysqlhost

echo -e "Enter MySQl database:"
read mysqldatabase

echo -e "Enter a username for Drupal admin:"
read drupaladminusernmae

echo -e "Enter a password for Drupal admin:"
read drupaladminpassword
echo
echo $(tput setaf 2)Downloading the latest version of drupal
echo $(tput sgr0)
drush dl drupal --drupal-project-rename drupal
cd drupal
echo
echo $(tput setaf 2)Stating the installation of core
echo $(tput sgr0)
drush si -y --db-url=mysql://$mysqlusernmae:$mysqlpassword@$mysqlhost/$mysqldatabase --account-name=$drupaladminusernmae --account-pass=$drupaladminpassword

echo
echo $(tput setaf 2)Download and set admin theme to Adminimal
echo $(tput sgr0)
drush dl adminimal_theme
drush variable-set admin_theme adminimal

echo
echo $(tput setaf 2)Disable unusable core modules
echo $(tput sgr0)
drush dis toolbar overlay contextual -y

echo
echo $(tput setaf 2)Download modules and enable them
echo $(tput sgr0)
drush dl ctools devel features entity panels views admin_menu adminimal_admin_menu pathauto strongarm token module_filter link field_group advanced_help libraries
drush en ctools ctools_custom_content page_manager devel features entity entity_token panels panels_mini views views_ui views_content admin_menu adminimal_admin_menu pathauto strongarm token module_filter link field_group advanced_help libraries -y

echo
echo $(tput setaf 2)Download and install Backup and Migrate module
echo $(tput sgr0)
cd sites/all/
mkdir -p "libraries"
cd libraries
mkdir -p "dropbox"
cd ../../../
wget https://github.com/BenTheDesigner/Dropbox/archive/master.zip
tar -xf master.zip
mv "Dropbox-master/Dropbox/" "sites/all/libraries/dropbox"
rm -rf Dropbox-master
rm master.zip
drush dl backup_migrate backup_migrate_files backup_migrate_dropbox
drush en backup_migrate backup_migrate_files backup_migrate_dropbox -y

echo
echo $(tput setaf 2)Fix for Admin menu and Adminimal menu
echo $(tput sgr0)
drush variable-set admin_menu_margin_top 0
drush variable-set adminimal_admin_menu_render "hidden"

echo
echo $(tput setaf 2)Install jQuery Update
echo $(tput sgr0)
drush dl jquery_update-7.x-2.x-dev
drush en jquery_update -y
drush variable-set --format="string" jquery_update_jquery_version "1.10"
drush variable-set --format="string" jquery_update_jquery_admin_version "1.7"
drush variable-set --format="string" jquery_update_jquery_cdn "google"
drush variable-set --format="string" jquery_update_compression_type "min"
drush cc all

echo
echo $(tput setaf 2)Install Bootstrap theme
echo $(tput sgr0)
drush dl bootstrap
drush pm-enable bootstrap -y
drush variable-set theme_default "bootstrap"

echo
echo $(tput setaf 2)Disable unused themes
echo $(tput sgr0)
drush pm-disable bartik -y
drush pm-disable seven -y

echo
echo $(tput setaf 2)Installation is finished
echo $(tput sgr0)
echo $(tput setaf 4)Login information: 
echo $(tput setaf 1)Username: $drupaladminusernmae 
echo $(tput setaf 1)Password: $drupaladminpassword
echo $(tput sgr0)