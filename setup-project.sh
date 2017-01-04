#!/bin/bash

# Make sure only root can run our script
#if [ "$(id -u)" != "0" ]; then
#   echo "########################################################"
#   echo "IMPORTANT! This script needs to be executed as root user"
#   echo "########################################################"
#   exit 1
#fi
# ...

# User Input
echo "Project name?: (lowercase)"
read projectName

echo "\nProject URL?: (Default: local.$projectName.com)"
read projectURL
if [ -z "$projectURL" ]; then
   projectURL=local.$projectName.com 
fi
# ...

# Select Project Type
echo "\nProjects Path?: [ENTER OPTION NUMBER]"
echo "1: Magento 1"
echo "2: Magento 2"
echo "3: Laravel"
echo "4: Wordpress"
echo "5: Slim"
echo "6: Symfony"
echo "7: PHP"

read projectPathOption

# Set a project path depending on the type selected
if [ $projectPathOption = "1" ]; then
	projectPath=~/Documents/Projects/magento1
fi
if [ $projectPathOption = "2" ]; then
        projectPath=~/Documents/Projects/magento2
fi
if [ $projectPathOption = "3" ]; then
        projectPath=~/Documents/Projects/laravel
fi
if [ $projectPathOption = "4" ]; then
        projectPath=~/Documents/Projects/wordpress
fi
if [ $projectPathOption = "5" ]; then
        projectPath=~/Documents/Projects/slim
fi
if [ $projectPathOption = "6" ]; then
        projectPath=~/Documents/Projects/symfony
fi
if [ $projectPathOption = "7" ]; then
        projectPath=~/Documents/121/Projects/php
fi
echo "\n#### Project Path: $projectPath/$projectName ####"

echo "\n#### Setting up project structure ####"
if [ -d $projectPath ]; then
   rm -rf $projectPath
fi
mkdir -p $projectPath/$projectName/www
mkdir -p $projectPath/$projectName/log
mkdir -p $projectPath/$projectName/assets

echo "\n#### Creating new vhost file ####"
vhostFile="/etc/apache2/sites-available/$projectURL.conf"
if [ -f $vhostFile ]; then
   echo "Removing existing vhost file"
   sudo rm -f $vhostFile
fi

echo "<VirtualHost *:80>" | sudo tee --append $vhostFile > /dev/null
echo "    ServerAdmin webmaster@localhost" | sudo tee --append $vhostFile > /dev/null
echo "    ServerName $projectURL" | sudo tee --append $vhostFile > /dev/null
echo "    DocumentRoot $projectPath/$projectName/www" | sudo tee --append $vhostFile > /dev/null
echo "    ErrorLog $projectPath/$projectName/log/error.log" | sudo tee --append $vhostFile > /dev/null
echo "    CustomLog $projectPath/$projectName/log/access.log combined" | sudo tee --append $vhostFile > /dev/null
echo "    <Directory $projectPath/$projectName/www>" | sudo tee --append $vhostFile > /dev/null
echo "        Order allow,deny" | sudo tee --append $vhostFile > /dev/null
echo "        Allow from all" | sudo tee --append $vhostFile > /dev/null
echo "        Require all granted" | sudo tee --append $vhostFile > /dev/null
echo "    </Directory>" | sudo tee --append $vhostFile > /dev/null
echo "</VirtualHost>" | sudo tee --append $vhostFile > /dev/null

sudo rm /etc/apache2/sites-enabled/$projectURL.conf
sudo ln -s $vhostFile /etc/apache2/sites-enabled/$projectURL.conf

echo "\n#### Creating registry in /etc/hosts ####"
if grep -Fxq "127.0.0.1 $projectURL" /etc/hosts; then
   echo "HOST $projectURL already exists in /etc/hosts"
else
   echo "127.0.0.1 $projectURL" | sudo tee --append /etc/hosts > /dev/null
fi

echo "\nDo you want to setup a GitHub/BitBucket project?: (Y/N)"
read setupProject

if [ $setupProject = "Y" ]; then
   echo "\nEnter the origin repository URL: "
   read repoURL

   echo "\nDo you want to include a remote repository?: (Y/N)"
   read includeRemoteRepo

   if [ $includeRemoteRepo = "Y" ]; then
      echo "\nEnter the remote repository URL:"
      read remoteRepoURL

      echo "\nAlias for remote repository?: (Default: remote)"
      read remoteRepoAlias

      if [ -z "$remoteRepoAlias" ]; then
         remoteRepoAlias="remote"
      fi
   fi

   echo "\nEnter the branch you will work on: (Default: develop)"
   read branchName

   if [ -z "$branchName" ];then
      branchName="develop"
   fi

   cd $projectPath/$projectName/www
   git init
   git remote add origin $repoURL
   git remote add $remoteRepoAlias $remoteRepoURL
   git fetch origin $branchName
   git checkout $branchName

   if [ -f $projectPath/$projectName/www/composer.json ]; then
      composer install
   fi

fi

echo "\n#### Setting up the permissions on the project ####"
sudo chown -R $USER:$USER $projectPath

# Restart the webserver
echo "\n#### Restarting Apache Server ####"
sudo apache2ctl restart

