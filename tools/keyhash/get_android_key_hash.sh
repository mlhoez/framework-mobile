#!/bin/sh

# -------------------------------------------
# Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
# Framework mobile
# Author  : Maxime Lhoez
# Created : 10 avril 2013
#
# This is a script used to retrieve the two KeyHash
# of an Android application :
# 	- The first is for the debug mode of the app
#	- The second is for the release mode of the app
#
# -------------------------------------------

# Reading config files
source ./build.config

# Développement
echo "Key Hash de développement"
keytool -export -alias 1 -keystore "${debug_cert_path}" -storetype pkcs12 -storepass "${debug_cert_password}" | openssl sha1 -binary | openssl enc -a -e

# Production
echo "Key Hash de production :"
keytool -export -alias 1 -keystore "${prod_cert_path}" -storetype pkcs12 -storepass "${prod_cert_password}" | openssl sha1 -binary | openssl enc -a -e

###########################################################
# Sauvegarde

# /!\ Lorsqu'on utilise une variable avec des espaces, il faut la stocker entre simple quote ' puis quando n l'utilise, la mettre entre double quote "
# Dans le echo, utiliser l'argument -e pour prendre en compte les sauts de ligne "\n"
# | permet en quelque sorte d'utiliser le résultat de la commande précédente dans la commande suivante (après le pipe donc)
# rm fichier.extension pour supprimer un fichier

# Pour exécuter le script via le terminal :
# cd "/Users/Maxime/1. Dev Mobile/Pyramides/certificates/"
# bash get_android_key_hash.sh

# Listing des données d'un certificat
# keytool -v -list -keystore nom_certificat.p12 -storetype pkcs12

# Development
# Emplacement par défaut du certificat de débug utilisé par Flash Builder /Applications/Adobe Flash Builder 4.7/eclipse/plugins/com.adobe.flexide.multiplatform.android_4.7.0.349722/resources/debug-certificate-android.p12
# debug_cert_location='/Applications/Adobe Flash Builder 4.7/eclipse/plugins/com.adobe.flexide.multiplatform.android_4.7.0.349722/resources/debug-certificate-android.p12'
# debug_password='debug'

# Production
# prod_cert_location='/Users/Maxime/1. Dev Mobile/Pyramides/certificates/cert_android.p12'
# prod_password='-LudoMobile2014-'

# echo -e "\nKey Hash de développement"
# keytool -export -alias 1 -keystore "$debug_cert_location" -storetype pkcs12 -storepass "$debug_password" | openssl sha1 -binary | openssl enc -a -e

# echo -e "\nKey Hash de production :"
# keytool -export -alias 1 -keystore "$prod_cert_location" -storetype pkcs12 -storepass "$prod_password" | openssl sha1 -binary | openssl enc -a -e

# echo ""