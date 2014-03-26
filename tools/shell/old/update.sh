
# git diff --stat master@{1} master : permet de montrer tous les changements depuis le dernier pull
# Afficher les derniers commits récupérés : git log @{1}..
# @{1} notation means "the commit the branch pointed to just before it last got updated".

# Updatings repos :

librariesPath="/Users/Maxime/1. Dev Mobile/1. Librairies"

starling="$librariesPath/Starling"
graphics="$librariesPath/Graphics"
particles="$librariesPath/Particles"
tweenMax="$librariesPath/TweenMax"
flox="$librariesPath/Flox"
feathersMax="$librariesPath/FeathersMax"

echo "\n\n######################################################################"
echo "#"
echo "#			UPDATING STARLING"
echo "#"
echo "######################################################################"
cd "$starling"
git pull --rebase
git log @{1}..

echo "\n\n######################################################################"
echo "#"
echo "#			UPDATING GRAPHICS"
echo "#"
echo "######################################################################"
cd "$graphics"
git pull --rebase
git log @{1}..

echo "\n\n######################################################################"
echo "#"
echo "#			UPDATING PARTICLES"
echo "#"
echo "######################################################################"
cd "$particles"
git pull --rebase
git log @{1}..

echo "\n\n######################################################################"
echo "#"
echo "#			UPDATING FLOX"
echo "#"
echo "######################################################################"
cd "$flox"
git pull --rebase
git log @{1}..

echo "\n\n######################################################################"
echo "#"
echo "#			UPDATING TWEENMAX"
echo "#"
echo "######################################################################"
cd "$tweenMax"
git pull --rebase
git log @{1}..

echo "\n\n######################################################################"
echo "#"
echo "#			UPDATING FEATHERS MAX"
echo "#"
echo "######################################################################"
cd "$feathersMax"
git remote add upstream https://github.com/joshtynjala/feathers.git
git pull upstream master
git log @{1}..
# si merge : "i" puis écrire le message du commit, et faire "echap" ":wq"

# Updating ANEs :










