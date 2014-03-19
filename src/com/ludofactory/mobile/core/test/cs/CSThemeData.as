/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 29 août 2013
*/
package com.ludofactory.mobile.core.test.cs
{
	import com.ludofactory.mobile.core.Localizer;
	
	/**
	 * This class represent a type of data saved in the EncrytedLocalStore and updated
	 * when the remote function "init" is called at the launch of the application.
	 * 
	 * <p>It contains a theme id, a translation key (used by Localizer to get the
	 * theme translation) and an index (ignored at the moment) that can be useful
	 * to sort the themes.</p>
	 */	
	public class CSThemeData
	{
		/**
		 * The theme id. */		
		private var _id:int;
		
		/**
		 * The translation key used to translate the theme name. */		
		private var _translationKey:String;
		
		/**
		 * The theme index (order in the list). */		
		private var _index:int;
		
		public function CSThemeData(data:Object = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			// The object will be juste fine after, like it was saved in the SharedObject, so
			// this is weird but works juste fine.
			if( !data ) return;
			
			_id = data.id;
			_translationKey = data.key;
			_index = data.index;
		}
		
		public function get id():int { return _id; }
		public function set id(val:int):void { _id = val; }
		
		public function get translationKey():String { return _translationKey; }
		public function set translationKey(val:String):void { _translationKey = val; }
		
		public function get index():int { return _index; }
		public function set index(val:int):void { _index = val; }
		
		public function toString():String
		{
			return Localizer.getInstance().translate(_translationKey);
		}
	}
}