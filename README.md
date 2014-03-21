framework-mobile
================

Framework mobile

Pour l'utilisation des fichiers ANE, il faut inclure dans la librairie ActionScript Mobile tous les fichiers SWC (qui contiennent UNIQUEMENT le code ActionScript), puis dans chaque projet utilisant la librairie, il faut inclure les fichiers ANE dans les propriétés du projet, sinon le contexte de l'extension sera null car le code natif n'aura pas été inclu par le SWC.