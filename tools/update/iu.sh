#!/bin/sh

# !!! ARCHIVE CAR INUTILISE MAINTENANT !!!

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
	git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
fi

# Reading config files
source ./build.config

cloneRepo ()
{
	# $1 = where to clone the repository
	# $2 = repository
	# $3 = repository name
	# $4 = upstream repository (if defined)
	
	echo "\n\n${cyan}######################################################################"
	echo "#"
	echo "#			$3"
	echo "#"
	echo "######################################################################${nc}"
	
	if [ ! -d "$1" ]
	then
		echo "${red}$1 doesn't exist, creating folder...${nc}"
		mkdir "$1";
	fi
	cd "$1"
	
	if [ ! -d "$1$3" ]
	then
		echo "${yel}Respository doesn't exist, cloning repository${nc}"
		git clone "$2" "$3" # clone repository
		cd "$1$3"
		
		# Add upstream source if the upstream repo is defined
		if [ ! -z "$4" ] # true if variable unset
		then
			echo "${cyan}Adding upstream repository...${nc}"
			git remote add upstream "$4" # add upstream source
		fi
	fi
	
	echo "${cyan}Updating repository...${nc}"
	cd "$1$3"
	git fetch --all # Fetches all commits from all branchs (origin AND upstream) 
	
	if [ ! -z "$4" ]
	then
		git lg master..upstream/master # difference between local et upstream commits (to see what's missing)
		git pull upstream master
		#git merge upstream/master
		git push origin master # when we have pulled upstream commits, we need to push them after the local branch being rebased / merged
	fi
	
	git lg master..origin/master
	git pull --all --quiet # Pull all branchs visible with "git show-ref" / --quiet : don't show executed git commands / --all est utilisé que pour le fetch exécuté par le pull, il ne merge pas tout
	
}

echo "${blue}Cloning / Updating libraries...${nc}"

cloneRepo "$libs_path" "$lib_starling_repo" "$lib_starling_name" "$lib_starling_us"
cloneRepo "$libs_path" "$lib_graphics_repo" "$lib_graphics_name"
cloneRepo "$libs_path" "$lib_particles_repo" "$lib_particles_name"
cloneRepo "$libs_path" "$lib_flox_repo" "$lib_flox_name"
cloneRepo "$libs_path" "$lib_gs_repo" "$lib_gs_name"
cloneRepo "$libs_path" "$lib_feathers_repo" "$lib_feathers_name" "$lib_feathers_us"
cloneRepo "$libs_path" "$lib_pixel_mask_repo" "$lib_pixel_mask_name"
cloneRepo "$libs_path" "$lib_android_device_info_repo" "$lib_android_device_info_name"

echo "${blue}Cloning / Updating ANEs...${nc}"

cloneRepo "$anes_path" "$ane_network_info_repo" "$ane_network_info_name" "$ane_network_info_us"
cloneRepo "$anes_path" "$ane_address_book_repo" "$ane_address_book_name" "$ane_address_book_us"
cloneRepo "$anes_path" "$ane_contact_editor_repo" "$ane_contact_editor_name" "$ane_contact_editor_us"
cloneRepo "$anes_path" "$ane_device_id_repo" "$ane_device_id_name" "$ane_device_id_us"
cloneRepo "$anes_path" "$ane_push_notifications_repo" "$ane_push_notifications_name" "$ane_push_notifications_us"
cloneRepo "$anes_path" "$ane_can_open_url_repo" "$ane_can_open_url_name" "$ane_can_open_url_us"
cloneRepo "$anes_path" "$ane_native_dialogs_repo" "$ane_native_dialogs_name" "$ane_native_dialogs_us"
cloneRepo "$anes_path" "$ane_google_analytics_repo" "$ane_google_analytics_name" "$ane_google_analytics_us"
cloneRepo "$anes_path" "$ane_mat_repo" "$ane_mat_name" "$ane_mat_us"