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
		
		public function ScreenData()
		{
			
		}
		
		public function purgeData():void
		{
			gameType = 0;
			
			defaultPseudo = "";
			
			facebookId = -1;
			tempFacebookData = null;
			
			tempMemberId = -1;
			
			gameData = new GameData();
		}
	}
}