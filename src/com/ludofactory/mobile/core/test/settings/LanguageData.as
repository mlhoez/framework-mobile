/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 oct. 2013
*/
package com.ludofactory.mobile.core.test.settings
{
	import com.ludofactory.mobile.core.Localizer;

	public class LanguageData
	{
		/**
		 * The language id (same as the one in the database). */		
		private var _id:int;
		
		/**
		 * The language key (fr, en, etc.), used to initialize the Localizer. */		
		private var _key:String;
		
		/**
		 * The language translation key. */		
		private var _translationKey:String;
		
		public function LanguageData(data:Object = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			// The object will be juste fine after, like it was saved in the SharedObject, so
			// this is weird but works juste fine.
			if( !data ) return;
			
			_id = data.id;
			_key = data.key;
			_translationKey = data.translationKey;
		}
		
		public function get id():int { return _id; }
		public function set id(val:int):void { _id = val; }
		
		public function get key():String { return _key; }
		public function set key(val:String):void { _key = val; }
		
		public function get translationKey():String { return _translationKey; }
		public function set translationKey(val:String):void { _translationKey = val; }
		
		public function toString():String
		{
			return Localizer.getInstance().translate( _translationKey );
		}
	}
}