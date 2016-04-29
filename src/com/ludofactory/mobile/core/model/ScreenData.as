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
		private static var _instance:ScreenData;
		
		/**
		 * The game mode. */
		private var _gameMode:int;
		/**
		 * The game data. */
		private var _gameData:GameData;
		/**
		 * Temporary Facebook data stored only if the "email" field is missing when Facebook returns the data.
		 * http://stackoverflow.com/questions/9347104/register-with-facebook-sometimes-doesnt-provide-email
		 */
		private var _tempFacebookData:Object;
		
		public function ScreenData(sk:SecurityKey)
		{
			if(sk == null)
				throw new Error("Erreur : Echec de l'instanciation : Utiliser ScreenData.getInstance() au lieu de new.");
			
			_gameData = new GameData()
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		public function purgeData():void
		{
			_gameMode = 0;
			_gameData = new GameData();
			_tempFacebookData = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/**
		 * The game mode. */
		public function get gameMode():int { return _gameMode; }
		public function set gameMode(value:int):void { _gameMode = value; }
		
		/**
		 * The game data. */
		public function get gameData():GameData { return _gameData; }
		public function set gameData(value:GameData):void { _gameData = value; }
		
		/**
		 * Temporary Facebook data stored only if the "email" field is missing when Facebook returns the data.
		 * http://stackoverflow.com/questions/9347104/register-with-facebook-sometimes-doesnt-provide-email
		 */
		public function get tempFacebookData():Object { return _tempFacebookData; }
		public function set tempFacebookData(value:Object):void { _tempFacebookData = value; }
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
		
		public static function getInstance():ScreenData
		{
			if(_instance == null)
				_instance = new ScreenData(new SecurityKey());
			return _instance;
		}
		
	}
}

internal class SecurityKey{}