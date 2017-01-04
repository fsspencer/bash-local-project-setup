# Setup Local Project

This is a simple bash script that allows you to create a local project according to your needs. 
In this version you have several project types as Magento 1, Magento 2, Laravel, Wordpress, Symfony, but you can add or remove them as you wish and point them to your own project paths.

## Installation

Copy the setup-project.sh to any directory you prefer. For example: **~/.scripts/**.
You should open the script with a text editor and modify the project paths or you can leave it as it.
If you have a different user/group for your apache server, you can reoplace the following line with your user and group:

    sudo chown -R $USER:$USER $projectPath
  
  You can replace it with:
  

    sudo chown -R www-data:www-data $projectPath

## Usage

If you copied the script to **~/.scripts/** you need to open your terminal and execute the following

    sh ~/.scripts/setup-project.sh

Provide code examples and explanations of how to get the project.

## Dependencies 

 - Linux Distribution
 - Apache 2.4
 - Composer
 - Php
 - Git
