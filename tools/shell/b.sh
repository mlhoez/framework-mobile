#!/bin/sh

# Builds all SWC ANEs

clear

# Reading config files
source ./config/init.config
source ./config/repos.config
source ./config/sdks.config

buildSwcAne ()
{
	# $1 = location of the ANEs
	# $2 = repository name

	echo "\n\n${cyan}######################################################################"
	echo "#"
	echo "#			$2"
	echo "#"
	echo "######################################################################${nc}"
	
	cd "$1$2"
	
	echo "${cyan}Building SWC...${nc}"
	cd "custom" # go to the custom build folder
	# Update path of sdks in ant config file
	# -i.bak result of the sed in the same file, and backup the old one
	sed -e "s!flex.sdk=.*!flex.sdk=${air_sdk_path}!g; s!android.sdk=.*!android.sdk=${android_sdk_path}!g; s!android.platformtools=.*!android.platformtools=${android_platformtools_path}!g;" example.build.config > build.config
	if ! ant
	then
		echo "${red}Error buling SWC file of $2${nc}"
	else
		echo "${green}SWC $2 successfully generated${nc}"
		
		# Copy / move swf to the framework
		if ! cp ../temp/swc/* "$fk_swc_path"
		then
			echo "${red}The SWC could not be copied to $fk_swc_path${nc}"
		else
			echo "${green}SWC successfully copied to $fk_swc_path${nc}"
		fi
	fi

}

echo "${blue}Building SWC ANEs...${nc}"

buildSwcAne "$anes_path" "$ane_network_info_name"
buildSwcAne "$anes_path" "$ane_address_book_name"
buildSwcAne "$anes_path" "$ane_contact_editor_name"
buildSwcAne "$anes_path" "$ane_device_id_name"
buildSwcAne "$anes_path" "$ane_push_notifications_name"
buildSwcAne "$anes_path" "$ane_can_open_url_name"
buildSwcAne "$anes_path" "$ane_native_dialogs_name"
buildSwcAne "$anes_path" "$ane_google_analytics_name"
buildSwcAne "$anes_path" "$ane_mat_name"