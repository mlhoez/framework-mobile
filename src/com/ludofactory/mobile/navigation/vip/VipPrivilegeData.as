/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 4 sept. 2013
*/
package com.ludofactory.mobile.navigation.vip
{
	public class VipPrivilegeData
	{
		/**
		 * The privilege title. */		
		private var _title:String;
		
		/**
		 * The privilege description. */		
		private var _description:String;
		
		public function VipPrivilegeData(data:Object = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			// The object will be juste fine after, like it was saved in the SharedObject, so
			// this is weird but works juste fine.
			if( !data ) return;
			
			_title = data.titre;
			_description = data.description;
		}
		
		public function get title():String { return _title; }
		public function set title(val:String):void { _title = val; }
		
		public function get description():String { return _description; }
		public function set description(val:String):void { _description = val; }
	}
}