/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 févr. 2014
*/
package com.ludofactory.mobile.core.model
{
	public class ScreenIds
	{
		/** Ecran d'accueil. */		
		public static const HOME_SCREEN:String = "Accueil";
		
//------------------------------------------------------------------------------------------------------------
//	Mon Compte
		
		/** Ecran d'accueil de mon compte. */		
		public static const MY_ACCOUNT_SCREEN:String = "Mon Compte";
		
//------------------------------------------------------------------------------------------------------------
//	Aide
		
		/** Ecran de la FAQ. */		
		public static const FAQ_SCREEN:String = "Aide - FAQ";
		/** Ecran d'accueil de l'aide. */		
		public static const HELP_HOME_SCREEN:String = "Aide - Accueil";
		
//------------------------------------------------------------------------------------------------------------
//	Authentification
		
		/** Ecran de connexion. */		
		public static const LOGIN_SCREEN:String = "Authentification - Connexion";
		/** Ecran d'inscription. */		
		public static const REGISTER_SCREEN:String = "Authentification - Inscription";
		/** Ecran de choix du pseudo. */		
		public static const PSEUDO_CHOICE_SCREEN:String = "Authentification - Choix du pseudo";
		/** Ecran de renseignement de l'id parrain (après une inscription Facebook). */		
		public static const SPONSOR_REGISTER_SCREEN:String = "Authentification - Renseignement du parrain";
		
//------------------------------------------------------------------------------------------------------------
//	Parrainage
		
		/** Ecran d'accueil du parrainage. */		
		public static const SPONSOR_HOME_SCREEN:String = "Parrainage - Accueil";
		/** Ecran d'invitation de parrainage. */		
		public static const SPONSOR_INVITE_SCREEN:String = "Parrainage - Invitation (mail ou sms)";
		/** Ecran de suivi des filleuls. */		
		public static const SPONSOR_FRIENDS_SCREEN:String = "Parrainage - Suivi des filleuls";
		
//------------------------------------------------------------------------------------------------------------
//	Réglages
		
		/** Ecran de réglages. */		
		public static const SETTINGS_SCREEN:String = "Réglages";
		
//------------------------------------------------------------------------------------------------------------
//	Jeu
		
		/** Ecran de jeu. */		
		public static const GAME_SCREEN:String = "Jeu";
		/** Ecran de choix de la mise. */		
		public static const GAME_TYPE_SELECTION_SCREEN:String = "Jeu - Choix de la mise";
		/** Ecran lors d'un nouvel high score. */		
		public static const NEW_HIGH_SCORE_SCREEN:String = "Jeu - Nouveau High Score";
		/** Ecran lors d'un changement de palier en tournoi. */		
		public static const PODIUM_SCREEN:String = "Jeu - Changement de palier en tournoi";
		/** Ecran de fin de jeu libre. */		
		public static const SOLO_END_SCREEN:String = "Jeu - Fin d'une partie en mode solo";
		/** Ecran de fin de tournoi. */		
		public static const TOURNAMENT_END_SCREEN:String = "Jeu - Fin d'une partie en mode tournoi";
		/** Ecran de dépassement de score d'un ami Facebook. */		
		public static const FACEBOOK_END_SCREEN:String = "Jeu - Dépassement d'amis Facebook";
		/** Ecran du classement du tournoi en cours. */		
		public static const TOURNAMENT_RANKING_SCREEN:String = "Tournoi en cours";
		
//------------------------------------------------------------------------------------------------------------
//	HighScores
		
		/** Ecran d'accueil des high scores */		
		public static const HIGH_SCORE_HOME_SCREEN:String = "High Score - Accueil";
		/** Ecran de listing des high scores. */		
		public static const HIGH_SCORE_LIST_SCREEN:String = "High Score - Listing";
		
//------------------------------------------------------------------------------------------------------------
//	Coupes
		
		/** Ecran des coupes. */		
		public static const TROPHY_SCREEN:String = "Coupes";
		
//------------------------------------------------------------------------------------------------------------
//	News
		
		/** Ecran de news. */		
		public static const NEWS_SCREEN:String = "News";
		
		
//------------------------------------------------------------------------------------------------------------
//	Update screen
		
		/** Ecran où l'on indique qu'il est nécessaire de mettre à jour l'application. */		
		public static const UPDATE_SCREEN:String = "Mise à jour nécessaire";
		
//------------------------------------------------------------------------------------------------------------
//	Debug screen
		
		/** The debug screen. */		
		public static const DEBUG_SCREEN:String = "Debug";
		
		// not used as a screen, just a reference in the menu
		public static const LOG_IN_OUT:String = "log_in_out";
		public static const SHOW_MENU:String = "show-menu";
		
		public static const GAME_CHOICE_SCREEN:String = "game-choice-screen";
		
	}
}