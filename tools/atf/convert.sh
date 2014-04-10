#!/bin/sh

# -------------------------------------------
# Copyright © 2006-2014 Ludo Factory
# Framework mobile
# Author  : Maxime Lhoez
# Created : 10 avril 2013
#
# This is a script used to automate the creation
# of .atf files from .png files.
#
# -------------------------------------------

# ----------------------------------------------------------------------------------------
#
# 									HOW TO USE THE SCRIPT ?
#
# Open the Terminal and navigate to the folder where this script is located.
#
# Make sure that the two following folders are created where the script is :
# 	- imput -> This is where you place all the files to convert (it must be .png files)
#	- output -> This is where the converted atf files go
#
# If everything is ok, run the script by typing "sh convert.sh"
#
# Enjoy !
#
# ----------------------------------------------------------------------------------------

clear

echo $(uname -s)

# navigate to "input" folder
cd "input"
for i in `ls -a *.*`
do
	# convert all pngs in the folder and output the result in the "output" folder
	echo "Converting ${i%.*}..."
	../png2atf -q 20 -n 0,0 -r -i "${i}" -o "../output/${i%.*}.atf"
done  

#./png2atf -i "toconvert/${file}.png" -o "converted/${file}.atf"

# Bons paramètres :
#./png2atf -q 20 -n 0,0 -r -i gui_1.png -o gui_1.atf

# Compressé format Android, résultat bof bof
#./png2atf -c d,e -n 0,0 -r -i gui_1.png -o gui_1.atf

# Compressé format Apple, résultat bof bof
#./png2atf -c p -n 0,0 -r -i gui_1.png -o gui_1.atf

# Compressé tous formats, résultat bof bof
#./png2atf -c -n 0,0 -r -i gui_1.png -o gui_1.atf