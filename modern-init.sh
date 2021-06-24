#!/bin/sh

set -e

echo -e "Checking node version"
if which node > /dev/null
  then
    node_version="$(node --version  | cut -c 2,3)";
    if [[ "$node_version" =~ ^(10|11|12|14|15)$ ]]
      then
        echo -e "Node: OK (v$node_version)"
      else
        echo -e "Your Node.js version isn't supported by this project, you need one of this versions: v10, v11, v12, v13, v14, v15"
        exit 1
    fi
  else
    echo -e "Node.js is not installed or not in your PATH"
    exit 1
fi

echo -e "Checking yarn is installed"
if ! command -v yarn &> /dev/null
then
    echo -e "Yarn is not installed or not in your PATH"
    exit
else
    echo -e "Yarn: OK"
fi

echo -e "Checking composer is installed"

if which composer > /dev/null
  then
    echo -e "Composer: OK"
  else
    echo -e "Composer is not installed or not in your PATH"
    exit 1
fi


DB_FILE=./local/config/database.yml

if test -f "$DB_FILE"; then
    read -p "$(echo -e "Would you like to erase the current database.yml file (y/n)?" erase
    if [ "$erase" != "${erase#[Yy]}" ] ;then
        echo -e "Removing current database.yml"
        rm $DB_FILE
        rm -rf ./cache
        echo -e "database.yml removed"
    fi
fi

echo -e "Installing composer dependencies"
composer install
echo -e "Dependencies installed"

read -p "$(echo -e "Enter a template folder name, (default: modern) it's recommended to change it : ")" TEMPLATE_NAME
TEMPLATE_NAME=${TEMPLATE_NAME:-modern}

if [ "$TEMPLATE_NAME" != "modern" ] ;then
  echo -e "Copying template files to templates/frontOffice/$TEMPLATE_NAME"
  cp -r "templates/frontOffice/modern" "templates/frontOffice/$TEMPLATE_NAME";
  echo -e "template copied"
fi

echo -e "Creating session and media folder"
[ -d local/session ] || mkdir -p local/session
[ -d local/media ] || mkdir -p local/media

chmod -R +w local/session && chmod -R +w local/media
echo -e "Folder created"


echo -e "Installing Thelia"
php Thelia thelia:install
echo -e "Thelia installed"

echo -e "Activating modules"
php Thelia module:refresh
php Thelia module:activate OpenApi
php Thelia module:activate ChoiceFilter
php Thelia module:activate StoreSeo
php Thelia module:activate SmartyRedirection
php Thelia module:activate BestSellers
php Thelia module:deactivate HookAdminHome
php Thelia module:deactivate HookAnalytics
php Thelia module:deactivate HookCart
php Thelia module:deactivate HookCustomer
php Thelia module:deactivate HookSearch
php Thelia module:deactivate HookLang
php Thelia module:deactivate HookCurrency
php Thelia module:deactivate HookNavigation
php Thelia module:deactivate HookProductsNew
php Thelia module:deactivate HookSocial
php Thelia module:deactivate HookNewsletter
php Thelia module:deactivate HookContact
php Thelia module:deactivate HookLinks
php Thelia module:deactivate HookProductsOffer
php Thelia module:deactivate HookProductsOffer
php Thelia module:refresh
echo -e "Modules activated"

echo -e "Changing active template"

php Thelia template:set --name="$TEMPLATE_NAME" --type="frontOffice"

echo -e "Active template changed"

echo -e "Creating an administrator"

php Thelia admin:create --login_name thelia2 --password thelia2 --last_name thelia2 --first_name thelia2 --email thelia2@example.com

echo -e "Administrator created"

TEMPLATE_NAME=modern

if test -f "$DB_FILE"; then
    read -p "$(echo -e "\e[1;37;45m Would you like to install a sample database (y/n)? \e[0m")" sample
    if [ "$sample" != "${sample#[Yy]}" ] ;then
      if test -f local/setup/import.php; then
        php local/setup/import.php
      elif test -f setup/import.php; then
        php setup/import.php
      else
        echo -e "Import script not found"
        exit
      fi
        echo -e "Sample data imported"
    fi
fi

rm -rf ./cache

cd "templates/frontOffice/$TEMPLATE_NAME" || exit

echo -e "Installing dependencies with yarn"
yarn install || exit

echo -e "Building template"
yarn build || exit


cd ../../..

echo -e "Everything is ok, you can now use your Thelia !"

# INIT CONSTANTS
# ------------------------------

exit 1