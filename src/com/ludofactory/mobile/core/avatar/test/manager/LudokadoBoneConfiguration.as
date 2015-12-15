/*
 Copyright © 2006-2015 Ludo Factory
 Framework Ludokado - Globbies
 Author  : Maxime Lhoez
 Created : 17 décembre 2014
*/
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	import com.ludofactory.common.utils.hasProperty;
	
	
	/**
	 * Bone configuration for Ludokado avatars.
	 */
	public class LudokadoBoneConfiguration
	{
		
	// ---------- User values (i.e. user configuration)
		
		/**
		 * The item id in database. */
		private var _id:int;
		/**
		 * Linkage name of the asset within the FLA. */
		private var _linkageName:String = "";
		/**
		 * Frame to go. */
		private var _frameName:String = "";

	// ---------- Temporary values (i.e. temprary configuration)
		
		/**
		 * Temporary id updated when the user is playing with the editor. */
		private var _tempId:int;
		/**
		 * Temporary linkage name updated when the user is playing with the editor. */
		private var _tempLinkageName:String;
		/**
		 * Temporary behavior name updated when the user is playing with the editor. */
		private var _tempFrameName:String;
		
		/**
		 * Boolean used to tell the php to buy or not this item. */
		private var _isCheckedInCart:Boolean = false;
		
		/**
		 * Note : This class could handle some more properties such as offsets, scale, etc.
		 */
		public function LudokadoBoneConfiguration()
		{
			resetToDefaults();
		}
		
		/**
		 * Resets to user configuration (when the cancel button is called within the editor).
		 */
		public function resetToUser():void
		{
			_tempId = _id;
			_tempLinkageName = _linkageName;
			_tempFrameName = _frameName;
			_isCheckedInCart = false;
		}
		
		/**
		 * Resets the bone configuration with default values (when a section in the config could not be found).
		 */
		private function resetToDefaults():void
		{
			_id = _tempId = 0;
			_linkageName = _tempLinkageName = "";
			_frameName = _tempFrameName = "";
			_isCheckedInCart = false;
		}

//------------------------------------------------------------------------------------------------------------
//	Utils
		
		/**
		 * Initializes the config.
		 */
		public function initialize(boneConfig:Object):void
		{
			if(boneConfig)
			{
				if( hasProperty("itemId", boneConfig) ) _id = _tempId = boneConfig.itemId;
				if( hasProperty("itemLinkageName", boneConfig) ) _linkageName = _tempLinkageName = boneConfig.itemLinkageName;
				if( hasProperty("frameId", boneConfig) ) _frameName = _tempFrameName = boneConfig.frameId;
			}
		}
		
		/**
		 * Parses the config.
		 */
		public function parse(boneConfig:Object):void
		{
			if(boneConfig)
			{
				if( hasProperty("itemId", boneConfig) ) _id = boneConfig.itemId;
				if( hasProperty("itemLinkageName", boneConfig) ) _linkageName = boneConfig.itemLinkageName;
				if( hasProperty("frameId", boneConfig) ) _frameName = boneConfig.frameId;
			}
		}
		
		/**
		 * Determines if the temprary configuration is the user configuration.
		 */
		public function isUserConfiguration():Boolean
		{
			return (_id == _tempId && _frameName == _tempFrameName && _linkageName == _tempLinkageName);
		}

//------------------------------------------------------------------------------------------------------------
//	Get - Set

		/**
		 * The item id in database. */
		public function get id():int { return _id; }
		/**
		 * Linkage name of the asset within the FLA. */
		public function get linkageName():String { return _linkageName; }
		/**
		 * Behavior to play (if the item is an armature. */
		public function get frameName():String { return _frameName; }
		/**
		 * The flash name. */
		public function get linkageExtractedId():int { return String(_linkageName).split("_")[1]; }
		
		/**
		 * Temporary id updated when the user is playing with the editor. */
		public function get tempId():int { return _tempId; }
		public function set tempId(value:int):void { _tempId = value; }
		/**
		 * Temporary linkage name updated when the user is playing with the editor. */
		public function get tempLinkageName():String { return _tempLinkageName; }
		public function set tempLinkageName(value:String):void { _tempLinkageName = value; }
		/**
		 * Temporary behavior name updated when the user is playing with the editor. */
		public function get tempFrameName():String { return _tempFrameName; }
		public function set tempFrameName(value:String):void { _tempFrameName = value; }
		
		/**
		 * The flash name. */
		public function get tempLinkageExtractedId():int { return String(_tempLinkageName).split("_")[1]; }
		
		/**
		 * Boolean used to tell the php to buy or not this item. */
		public function get isCheckedInCart():Boolean { return _isCheckedInCart; }
		public function set isCheckedInCart(value:Boolean):void { _isCheckedInCart = value; }
		
	}
}