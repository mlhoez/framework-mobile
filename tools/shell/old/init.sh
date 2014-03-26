clear
# Dossier de destination des librairies
destPath="/Users/Maxime/1. Dev Mobile/Libs/"

echo "Toutes les librairies vont être clonées dans le dossier : $destPath\nTaper o pour confirmer"
read reponse

if [ "$reponse" == "o" ]; then

mkdir "$destPath"
cd "$destPath"

echo "\n\n######################################################################"
echo "#"
echo "#			CLONING STARLING"
echo "#"
echo "######################################################################"
git clone "https://github.com/PrimaryFeather/Starling-Framework.git" "Starling"

echo "\n\n######################################################################"
echo "#"
echo "#			CLONING GRAPHICS"
echo "#"
echo "######################################################################"
git clone "https://github.com/StarlingGraphics/Starling-Extension-Graphics.git" "Graphics"

echo "\n\n######################################################################"
echo "#"
echo "#			CLONING PARTICLES"
echo "#"
echo "######################################################################"
git clone "https://github.com/PrimaryFeather/Starling-Extension-Particle-System.git" "Particles"

echo "\n\n######################################################################"
echo "#"
echo "#			CLONING FLOX"
echo "#"
echo "######################################################################"
git clone "https://github.com/Gamua/Flox-AS3.git" "Flox"

echo "\n\n######################################################################"
echo "#"
echo "#			CLONING TWEEN MAX"
echo "#"
echo "######################################################################"
git clone "https://github.com/greensock/GreenSock-AS3.git" "TweenMax"

echo "\n\n######################################################################"
echo "#"
echo "#			CLONING FEATHERS MAX"
echo "#"
echo "######################################################################"
git clone "https://github.com/Jerril/feathers.git" "FeathersMax"

else
	echo "Annulé !\nPour éditer le chemin de copie des clones, éditer directement le script."
fi