#!/bin/bash

# Text color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
txtred=$(tput setaf 1)          #  red
txtgre=$(tput setaf 2)          #  green
txtblu=$(tput setaf 4)          #  blue
bldred=${txtbld}$(tput setaf 1) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

echo $bldblu
echo "*******************************************************************"
echo "*                                                                 *"
echo "*                     Drupal installation script                  *"
echo "*                                                                 *"
echo "*******************************************************************"
echo $txtrst
echo -e $txtred"DISCLAIMER OF WARRANTY\n
The Software is provided \"AS IS\" and \"WITH ALL FAULTS,\"
without warranty of any kind, including without limitation
the warranties of merchantability, fitness for a particular
purpose and non-infringement. The Licensor makes no warranty
that the Software is free of defects or is suitable for any
particular purpose. In no event shall the Licensor be responsible
for loss or damages arising from the installation or use of the
Software, including but not limited to any indirect, punitive,
special, incidental or consequential damages of any character
including, without limitation, damages for loss of goodwill, work
stoppage, computer failure or malfunction, or any and all other
commercial damages or losses. The entire risk as to the quality
and performance of the Software is borne by you. Should the Software
prove defective, you and not the Licensor assume the entire cost of
any service and repair.\n"

command -v drush >/dev/null 2>&1 || { echo >&2 "Drush is required, but it's not installed. Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "wget is required, but it's not installed. Aborting."; exit 1; }

echo -e $txtgre"Start installing the latest version of Drupal\n"$txtrst

echo -n "Enter MySQl username: "
read mysqlusernmae

echo -n "Enter MySQl password: "
read mysqlpassword

echo -n "Enter MySQl host: "
read mysqlhost

echo -n "Enter MySQl database: "
read mysqldatabase

echo -n "Enter a username for Drupal admin: "
read drupaladminusernmae

echo -n "Enter a password for Drupal admin: "
read drupaladminpassword

echo -e $txtgre"\nDownloading the latest version of drupal\n"$txtrst
drush dl drupal --drupal-project-rename drupal
cd drupal

echo -e $txtgre"\nStating the installation of core\n"$txtrst
drush si -y --db-url=mysql://$mysqlusernmae:$mysqlpassword@$mysqlhost/$mysqldatabase --account-name=$drupaladminusernmae --account-pass=$drupaladminpassword

echo -e $txtgre"\nDownload and set admin theme to Adminimal\n"$txtrst
drush dl adminimal_theme
drush variable-set admin_theme adminimal

echo -e $txtgre"\nDisable unusable core modules"$txtrst
drush dis toolbar overlay contextual -y

echo -e $txtgre"\nDownload modules and enable them\n"$txtrst
drush dl ctools devel features entity panels views admin_menu adminimal_admin_menu pathauto strongarm token module_filter link field_group advanced_help libraries
drush en ctools ctools_custom_content page_manager devel features entity entity_token panels panels_mini views views_ui views_content admin_menu adminimal_admin_menu pathauto strongarm token module_filter link field_group advanced_help libraries -y

echo -e $txtgre"\nDownload and install Backup and Migrate module\n"$txtrst
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

echo -e $txtgre"\nFix for Admin menu and Adminimal menu\n"$txtrst 
drush variable-set admin_menu_margin_top 0
drush variable-set adminimal_admin_menu_render "hidden"

echo -e $txtgre"\nInstall jQuery Update\n"$txtrst
drush dl jquery_update-7.x-2.x-dev
drush en jquery_update -y
drush variable-set --format="string" jquery_update_jquery_version "1.10"
drush variable-set --format="string" jquery_update_jquery_admin_version "1.7"
drush variable-set --format="string" jquery_update_jquery_cdn "google"
drush variable-set --format="string" jquery_update_compression_type "min"
drush cc all

echo -e $txtgre"\nInstall Bootstrap theme\n"$txtrst
drush dl bootstrap
drush pm-enable bootstrap -y
drush variable-set theme_default "bootstrap"

echo -e $txtgre"\nDisable unused themes\n"$txtrst
drush pm-disable bartik -y
drush pm-disable seven -y

echo -e $txtgre"\nInstallation is finished\n"$txtrst
echo -e $txtblu"Login information:" 
echo -e $txtgre"Username:$txtred $drupaladminusernmae"
echo -e $txtgre"Password:$txtred $drupaladminpassword"
echo $txtrst