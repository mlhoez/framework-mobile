/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 18 Août 2013
*/
package com.ludofactory.mobile.core.model
{
	

	public class ScreenData
	{
		public var gameType:int;
		
		public var defaultPseudo:String;
		
		public var facebookId:int;
		public var tempFacebookData:Object;
		
		public var tempMemberId:int;
		
		/**
		 * The game data. */		
		public var gameData:GameData = new GameData();
		
		/**
		 * The previous tournement id. */		
		//public var previousTournementId:int;
		
		public var highscoreRankingType:int;
		
		public var displayPopupOnHome:Boolean = false;
		
		//public var indexToDisplayInMyAccount:int = 0;
		
		public function ScreenData()
		{
			
		}
		
		public function purgeData():void
		{
			// bug si on va sur la sélection de mise, puis on se connecte, quand on revient => comme on fait
			// un purgeData au changement d'écran, la push partie merde
			gameType = 0;
			
			defaultPseudo = "";
			
			facebookId = -1;
			tempFacebookData = null;
			
			tempMemberId = -1;
			
			gameData = new GameData();
			
			//previousTournementId = -1;
			
			highscoreRankingType = -1;
			
			//indexToDisplayInMyAccount = 0;
		}
	}
}