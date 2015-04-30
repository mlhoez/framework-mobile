/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 18 Août 2013
*/
package com.ludofactory.mobile.core.model
{
	import com.ludofactory.mobile.navigation.shop.vip.BoutiqueItemData;
	import com.ludofactory.mobile.navigation.cs.display.CSMessageData;

	public class ScreenData
	{
		public var gameType:int;
		public var gamePrice:int;
		
		public var defaultPseudo:String;
		
		public var facebookId:int;
		public var tempFacebookData:Object;
		
		public var tempMemberId:int;
		
		/**
		 * The game data. */		
		public var gameData:GameData = new GameData();
		
		// Boutique
		public var idCategory:int;
		public var categoryName:String;
		public var idSubCategory:int = -1;
		public var selectedItemData:BoutiqueItemData = null;
		
		// Customer Service
		public var thread:CSMessageData;
		
		/**
		 * The sponsor type. */		
		public var sponsorType:String;
		
		/**
		 * The previous tournement id. */		
		public var previousTournementId:int;
		
		public var highscoreRankingType:int;
		
		public var vipScreenInitializedFromStore:Boolean = false;
		
		public var displayPopupOnHome:Boolean = false;
		
		public function ScreenData()
		{
			
		}
		
		public function purgeData():void
		{
			// bug si on va sur la sélection de mise, puis on se connecte, quand on revient => comme on fait
			// un purgeData au changement d'écran, la push partie merde
			gameType = 0;
			gamePrice = 0;
			
			defaultPseudo = "";
			
			facebookId = -1;
			tempFacebookData = null;
			
			tempMemberId = -1;
			
			gameData = new GameData();
			
			idCategory = -1;
			idSubCategory = -1;
			selectedItemData = null;
			
			thread = null;
			
			sponsorType = "";
			
			previousTournementId = -1;
			
			highscoreRankingType = -1;
			
			vipScreenInitializedFromStore = false;
		}
	}
}