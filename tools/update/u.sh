#!/bin/sh

# -------------------------------------------
# Copyright © 2006-2014 Ludo Factory
# Framework mobile
# Author  : Maxime Lhoez
# Created : 9 avril 2013
#
# This is a script used to automate the creation
# and update of all git repositories (libraries
# and ANEs) - whether from remote and upstream
# sources - related to the mobile development.
#
# -------------------------------------------

# ----------------------------------------------------------------------------------------
#
# 									HOW TO USE THE SCRIPT ?
#
# Open the Terminal and navigate to the folder where this script is located.
#
# Before running the script, duplicate the file "sdks.config.example" whithin the "config/" folder
# and replace the actual paths by the ones matching your computer and rename to file for 'sdks.config'.
#
# Then run the script by typing "sh iu.sh" in the Terminal.
#
# Enjoy !
#
# ----------------------------------------------------------------------------------------

clear

if ! git config --global --get alias.lg --quiet
then
	# Add global alias used to display incoming commits when fetching
	# git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
	git config --global alias.lg "log --color --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit"
fi

# git config --global --unset alias.lg

# Reading config files
source ./build.config

# $libs_path = where to clone the repository
# $1 = repository
# $2 = repository name
# $3 = upstream repository (if defined)

# echo "\n\n${cyan}######################################################################"
# echo "#"
# echo "#			$2"
# echo "#"
# echo "######################################################################${nc}"

echo "######################################################################"
echo "#"
echo "#			$2"
echo "#"
echo "######################################################################"

if [ ! -d "$libs_path" ]
then
	# echo "${red}$libs_path doesn't exist, creating folder...${nc}"
	# echo "$libs_path doesn't exist, creating folder..."
	mkdir "$libs_path";
fi
cd "$libs_path"

if [ ! -d "$libs_path$2" ]
then
	# echo "${yel}Respository doesn't exist, cloning repository${nc}"
	echo "Respository doesn't exist, cloning repository"
	git clone "$1" "$2" # clone repository
	cd "$libs_path$2"
	
	# Add upstream source if the upstream repo is defined
	if [ ! -z "$3" ] # true if variable unset
	then
		# echo "${cyan}Adding upstream repository...${nc}"
		echo "Adding upstream repository..."
		git remote add upstream "$3" # add upstream source
	fi
fi

# echo "${cyan}Updating repository...${nc}"
# echo "Updating repository..."
cd "$libs_path$2"
git fetch --all # Fetches all commits from all branchs (origin AND upstream) 

if [ ! -z "$3" ]
then
	git lg master..upstream/master # difference between local et upstream commits (to see what's missing)
	git pull upstream master
	# git merge upstream/master
	git push origin master # when we have pulled upstream commits, we need to push them after the local branch being rebased / merged
fi

git lg master..origin/master
git pull --all --quiet # Pull all branchs visible with "git show-ref" / --quiet : don't show executed git commands / --all est utilisé que pour le fetch exécuté par le pull, il ne merge pas tout