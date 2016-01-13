/*
 Copyright © 2006-2015 Ludo Factory
 Framework Ludokado - Ludokado
 Author  : Maxime Lhoez
 Created : 17 décembre 2014
*/
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	
	import flash.utils.Dictionary;
	
	import starling.events.EventDispatcher;
	
	/**
	 * Manager used to handle all the configurations for the 3 genders.
	 */
	public class LKConfigManager extends EventDispatcher
	{
		/**
		 * All the configurations by gender. */
		private static var _configsByGender:Dictionary;
		
		/**
		 * The current gender id. */
		private static var _currentGenderId:int;
		
		private static var _isInitialized:Boolean = false;
		
		public function LKConfigManager()
		{
			super();
		}
		
		public static function initializeManager():void
		{
			if(!_isInitialized)
			{
				_isInitialized = true;
				
				_configsByGender = new Dictionary();
				_configsByGender[AvatarGenderType.SHADOW] = new LKAvatarConfig();
				LKAvatarConfig(_configsByGender[AvatarGenderType.SHADOW]).gender = AvatarGenderType.SHADOW;
				_configsByGender[AvatarGenderType.BOY] = new LKAvatarConfig();
				LKAvatarConfig(_configsByGender[AvatarGenderType.BOY]).gender = AvatarGenderType.BOY;
				_configsByGender[AvatarGenderType.GIRL] = new LKAvatarConfig();
				LKAvatarConfig(_configsByGender[AvatarGenderType.GIRL]).gender = AvatarGenderType.GIRL;
				_configsByGender[AvatarGenderType.POTATO] = new LKAvatarConfig();
				LKAvatarConfig(_configsByGender[AvatarGenderType.POTATO]).gender = AvatarGenderType.POTATO;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Parse functions
		
		/**
		 * This function is called at the launch of the application.
		 * 
		 * We need a separate one because
		 *
		 * It will store the current gender id (given in the FlashVars) and parse the config for this gender.
		 */
		public static function initialize(flashVars:Object):void
		{
			initializeManager();
			
			if(flashVars)
			{
				_currentGenderId = flashVars.idGender;
				if(_currentGenderId != 0)
					LKAvatarConfig(getConfigByGender(currentGenderId)).initialize(flashVars);
			}
		}
		
		/**
		 * This function is called at the launch of the application and when the avatar have been successfully saved.
		 *
		 * It will store the current gender id (given in the FlashVars) and parse the config for this gender.
		 */
		public static function parseData(flashVars:Object):void
		{
			initializeManager();
			
			if(flashVars)
			{
				_currentGenderId = flashVars.idGender;
				if(_currentGenderId != 0)
					LKAvatarConfig(getConfigByGender(currentGenderId)).parseConfig(flashVars);
			}
		}
		
		/**
		 * This function is called when a call the requestResetAvatar have been made.
		 *
		 * It will parse a configuratioh for a given gender id.
		 *
		 * @param genderId The gender id to parse
		 * @param config The config for this gender
		 */
		public static function initializeConfigForGender(genderId:int, config:Object):void
		{
			initializeManager();
			
			// reset to user first
			LKAvatarConfig(_configsByGender[genderId]).resetToUser();
			LKAvatarConfig(_configsByGender[genderId]).initialize(config);
		}
		
//------------------------------------------------------------------------------------------------------------
//  

		/**
		 * Resets the current display, assigning the <strong>user</strong> values.
		 * 
		 * This function is called when the user click on the "cancel" button.
		 */
		public static function resetToUserConfiguration():void
		{
			LKAvatarConfig(getConfigByGender(currentGenderId)).resetToUser();
		}
		
		/**
		 * Returns the configuration of the gender whose id is given in parameters.
		 */
		public static function getConfigByGender(genderId:int):LKAvatarConfig
		{
			return (genderId in _configsByGender ? LKAvatarConfig(_configsByGender[genderId]) : null);
		}
		
		/**
		 * Returns the configuration of the gender whose id is given in parameters.
		 */
		public static function getBoneConfigByGender(genderId:int, boneName:String):LudokadoBoneConfiguration
		{
			return LudokadoBoneConfiguration(LKAvatarConfig(_configsByGender[genderId])[boneName]);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		/**
		 * Whether it is the default configuration.
		 * 
		 * This is used at the launch of the application in order to determine which screen has to be displayed.
		 */
		public static function isDefaultConfiguration():Boolean
		{
			return currentGenderId == 0;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/**
		 * Returns the current configuration of the avatar.
		 *
		 * It will be all the temporary ids because the original configuration can be changed only when the call to
		 * "saveAvatar" is ok and the configuration updated on the server.
		 */
		public static function getTemporaryConfig():Object
		{
			return LKAvatarConfig(getConfigByGender(currentGenderId)).generateTemporaryConfig();
		}
		
		public static function get currentGenderId():int { return _currentGenderId; }
		public static function set currentGenderId(value:int):void { _currentGenderId = value; }
		public static function get currentConfig():LKAvatarConfig { return getConfigByGender(currentGenderId); }
		
	}
}