/*
 Copyright © 2006-2015 Ludo Factory
 Framework Ludokado - Ludokado
 Author  : Maxime Lhoez
 Created : 17 décembre 2014
*/
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	import com.ludofactory.common.utils.Dimension;
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
		
		/**
		 * Image dimensions.
		 */
		private static var _imageDimensions:Dimension = new Dimension();
		
		/**
		 * Reference width and height of the avatar (to which width they have been designed).
		 * This value is used by the AvatarManager in order to scale the avatar depending on desired png size.
		 */
		private static var _imageRefDimensions:Dimension = new Dimension();
		
		/**
		 * Default animation name. */
		private static var _defaultAnimationName:String = "idle";
		
		public function LKConfigManager()
		{
			super();
			
			_configsByGender = new Dictionary();
			_configsByGender[AvatarGenderType.BOY] = new LKAvatarConfig(AvatarGenderType.BOY);
			_configsByGender[AvatarGenderType.GIRL] = new LKAvatarConfig(AvatarGenderType.GIRL);
			_configsByGender[AvatarGenderType.POTATO] = new LKAvatarConfig(AvatarGenderType.POTATO);
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
			if(flashVars)
			{
				_currentGenderId = flashVars.idGender;
				_imageDimensions.width = "pngWidth" in flashVars ? flashVars.pngWidth : 1;
				_imageDimensions.height = "pngHeight" in flashVars ? flashVars.pngHeight : 1;
				_imageRefDimensions.width = "pngRefWidth" in flashVars ? flashVars.pngRefWidth : 1;
				_imageRefDimensions.height = "pngRefHeight" in flashVars ? flashVars.pngRefHeight : 1;
				if("defaultAnimationName" in flashVars) _defaultAnimationName = flashVars.defaultAnimationName;
				if(_currentGenderId != 0)
					LKAvatarConfig(getConfigByGender(_currentGenderId)).initialize(flashVars);
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
			// reset to user first
			LKAvatarConfig(_configsByGender[genderId]).resetToUser();
			LKAvatarConfig(_configsByGender[genderId]).initialize(config);
		}
		
		/**
		 * This function is called at the launch of the application and when the avatar have been successfully saved.
		 * 
		 * It will store the current gender id (given in the FlashVars) and parse the config for this gender.
		 */
		public static function parseData(flashVars:Object):void
		{
			if(flashVars)
			{
				_currentGenderId = flashVars.idGender;
				if(_currentGenderId != 0)
					LKAvatarConfig(getConfigByGender(_currentGenderId)).parseConfig(flashVars);
			}
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
			LKAvatarConfig(getConfigByGender(_currentGenderId)).resetToUser();
		}
		
		/**
		 * Returns the configuration of the gender whose id is given in parameters.
		 */
		public static function getConfigByGender(genderId:int):LKAvatarConfig
		{
			return LKAvatarConfig(_configsByGender[genderId]);
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
			return _currentGenderId == 0;
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
			return LKAvatarConfig(getConfigByGender(_currentGenderId)).generateTemporaryConfig();
		}
		
		public static function get currentGenderId():int { return _currentGenderId; }
		public static function set currentGenderId(value:int):void { _currentGenderId = value; }
		public static function get currentConfig():LKAvatarConfig { return getConfigByGender(_currentGenderId); }
		public static function get imageDimensions():Dimension { return _imageDimensions; }
		public static function get imageRefDimensions():Dimension { return _imageRefDimensions; }
		public static function get defaultAnimationName():String { return _defaultAnimationName; }
		
	}
}