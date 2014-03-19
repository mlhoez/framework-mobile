/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.core.test.achievements
{
	/**
	 * This class represent a trophy basic informations.
	 */	
	public class TrophyData
	{
		/**
		 * The trophy id (will be linked to the game / application id). */		
		private var _id:int;
		
		/**
		 * The trophy title translation key. */		
		private var _titleTranslationKey:String;
		
		/**
		 * The trophy description. */		
		private var _descriptionTranslationKey:String;
		
		/**
		 * The trophy reward description. */		
		private var _rewardTranslationKey:String;
		
		/**
		 * The values used in the code to trigger the trophy. */		
		private var _values:Array;
		
		/**
		 * The texture name. */		
		private var _textureName:String;
		
		public function TrophyData(data:Object = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			// The object will be juste fine after, like it was saved in the SharedObject, so
			// this is weird but works juste fine.
			if( !data ) return;
			
			_id = data.id;
			_titleTranslationKey = data.titleKey;
			_descriptionTranslationKey = data.descriptionKey;
			_rewardTranslationKey = data.rewardKey;
			_values = data.values;
			_textureName = data.textureName;
		}
		
		public function get id():int { return _id; }
		public function set id(val:int):void { _id = val; }
		
		public function get titleTranslationKey():String { return _titleTranslationKey; }
		public function set titleTranslationKey(val:String):void { _titleTranslationKey = val; }
		
		public function get descriptionTranslationKey():String { return _descriptionTranslationKey; }
		public function set descriptionTranslationKey(val:String):void { _descriptionTranslationKey = val; }
		
		public function get rewardTranslationKey():String { return _rewardTranslationKey; }
		public function set rewardTranslationKey(val:String):void { _rewardTranslationKey = val; }
		
		public function get values():Array { return _values; }
		public function set values(val:Array):void { _values = val; }
		
		public function get textureName():String { return _textureName; }
		public function set textureName(val:String):void { _textureName = val; }
		
	}
}