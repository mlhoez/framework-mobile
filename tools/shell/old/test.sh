#!/bin/sh

clear

if ! git config --global --get alias.lg --quiet
then
# Add global alias used to display incoming commits when fetching
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
fi

# Reading config file
source ./build.config

echo "${blue}Pulling all ANEs...${nc}"

# If the path of the ANEs dosn't exist, we create it
if [ ! -d "$anes_path" ]
then
	echo "${red}$anes_path doesn't exist, creating folder...${nc}"
	mkdir "$anes_path";
fi

cloneAndBuildRepo ()
{

	echo "\n\n${cyan}######################################################################"
	echo "#"
	echo "#			$3"
	echo "#"
	echo "######################################################################${nc}"
	
	cd "$anes_path"
	if [ ! -d "$anes_path$3" ]
	then
		echo "${yel}Respository doesn't exist, cloning repository${nc}"
		git clone $1 "$3" # clone forked repo
		cd "$anes_path$3" 
		git remote add upstream $2 # add upstream source
	fi
	
	echo "${cyan}Updating repository...${nc}"
	cd "$anes_path$3"
	git fetch --all # Fetches all commits from all branchs (origin AND upstream) 
	git lg master..upstream/master
	git lg master..origin/master
	git pull --all --quiet # Pull all branchs visible with "git show-ref" / --quiet : don't show executed git commands
	
	echo "${cyan}Now building SWC...${nc}"
	cd "custom" # go to the custom build folder
	# Update path of sdks in ant config file
	# -i.bak result of the sed in the same file, and backup the old one
	sed -e "s!flex.sdk=.*!flex.sdk=${air_sdk_path}!g; s!android.sdk=.*!android.sdk=${android_sdk_path}!g; s!android.platformtools=.*!android.platformtools=${android_platformtools_path}!g;" example.build.config > build.config
	if ! ant
	then
		echo "${red}Error buling SWC file of Network Info${nc}"
	else
		echo "${green}SWC Network Info successfully generated${nc}"
		
		# Copy / move swf to the framework
		if ! cp ../temp/swc/* "$fk_path"
		then
			echo "${red}The SWC could not be copied to $fk_path${nc}"
		else
			echo "${green}SWC successfully copied to $fk_path${nc}"
		fi
	fi

}

# Cloning, updating and building each ANE

# ANE Network Info
#cloneAndBuildRepo $ane_network_info_fork $ane_network_info_upstream $ane_network_info_name

# ANE Address Book
#cloneAndBuildRepo $ane_address_book_fork $ane_address_book_upstream $ane_address_book_name

# ANE Contact Editor
# A terminer !!
#cloneAndBuildRepo $ane_contact_editor_fork $ane_contact_editor_upstream $ane_contact_editor_name

# ANE Device Id
#cloneAndBuildRepo $ane_device_id_fork $ane_device_id_upstream $ane_device_id_name

# ANE Push Notifications
#cloneAndBuildRepo $ane_push_notifications_fork $ane_push_notifications_upstream $ane_push_notifications_name

# ANE Can Open Url
#cloneAndBuildRepo $ane_can_open_url_fork $ane_can_open_url_upstream $ane_can_open_url_name

# ANE MAT
cloneAndBuildRepo $ane_mat_fork $ane_mat_upstream $ane_mat_name





