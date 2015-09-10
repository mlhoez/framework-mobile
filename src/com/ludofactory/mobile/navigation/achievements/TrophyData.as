/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.navigation.achievements
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
		 * The translated title. */		
		private var _title:String;
		
		/**
		 * The trophy description. */		
		private var _description:String;
		
		/**
		 * The trophy reward description. */		
		private var _reward:String;
		
		/**
		 * The values used in the code to trigger the trophy. */		
		private var _values:Array;
		
		/**
		 * The texture name : is empty we pick up the embedeed texture ("trophyX"),
		 * oherwise if it's an url, we replace */		
		private var _textureName:String;
		
		/**
		 * For progressive trophies, this value is used to know the progress of the player on this trophy.*/
		private var _currentValue:Number;
		
		/**
		 * Whether the trophy is progressive. */
		private var _isProgressive:Boolean = false;
		
		public function TrophyData(data:Object = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			if( !data ) return;
			
			_id = int(data.id);
			_title = data.title;
			_description = data.description;
			_reward = data.reward;
			_values = data.values;
			_textureName = (data.textureName && textureName != "") ? data.textureName : ("trophy" + _id);
			_currentValue = (data.currentValue != null) ? Number(data.currentValue) : 0;
			_isProgressive = (data.isProgressive != null) ? Boolean(data.isProgressive) : false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get id():int { return _id; }
		public function set id(val:int):void { _id = val; }
		
		public function get title():String { return _title; }
		public function set title(val:String):void { _title = val; }
		
		public function get description():String { return _description; }
		public function set description(val:String):void { _description = val; }
		
		public function get reward():String { return _reward; }
		public function set reward(val:String):void { _reward = val; }
		
		public function get values():Array { return _values; }
		public function set values(val:Array):void { _values = val; }
		
		public function get textureName():String { return _textureName; }
		public function set textureName(val:String):void { _textureName = val; }
		
		public function get currentValue():Number { return _currentValue; }
		public function set currentValue(value:Number):void { _currentValue = value; }
		
		public function get isProgressive():Boolean { return _isProgressive; }
		public function set isProgressive(value:Boolean):void { _isProgressive = value; }
	}
}