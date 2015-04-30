/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 4 sept. 2013
*/
package com.ludofactory.mobile.navigation.vip
{
	public class VipData
	{
		/**
		 * The rank id. */		
		private var _id:int;
		
		/**
		 * The access value. */		
		private var _accessValue:int;
		
		/**
		 * The condition. */		
		private var _condition:String;
		
		/**
		 * The rank translation key. */		
		private var _rankName:String;
		
		/**
		 * Only for the first rank. */		
		private var _presentation:String;
		
		/**
		 * The array of privileges. */		
		private var _content:Vector.<VipPrivilegeData>;
		
		public function VipData(data:Object = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			// The object will be juste fine after, like it was saved in the SharedObject, so
			// this is weird but works juste fine.
			if( !data ) return;
			
			_id = int(data.rang);
			_accessValue = int(data.acces);
			_condition = data.condition;
			_rankName = data.nom_rang;
			_presentation = data.presentation;
			
			_content = new Vector.<VipPrivilegeData>();
			for(var i:int = 0; i < data.tab_privileges.length; i++)
				_content.push( new VipPrivilegeData(data.tab_privileges[i]) );
		}
		
		public function get id():int { return _id; }
		public function set id(val:int):void { _id = val; }
		
		public function get accessValue():int { return _accessValue; }
		public function set accessValue(val:int):void { _accessValue = val; }
		
		public function get presentation():String { return _presentation; }
		public function set presentation(val:String):void { _presentation = val; }
		
		public function get rankName():String { return _rankName; }
		public function set rankName(val:String):void { _rankName = val; }
		
		public function get condition():String { return _condition; }
		public function set condition(val:String):void { _condition = val; }
		
		public function get content():Vector.<VipPrivilegeData> { return _content; }
		public function set content(val:Vector.<VipPrivilegeData>):void { _content = val; }
	}
}