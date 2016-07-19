/**
 * Created by Maxime on 26/04/2016.
 */
package com.ludofactory.mobileNew
{
	
	public class StatsData
	{
		/**
		 * The stat title. */
		private var _title:String;
		/**
		 * The stat description. */
		private var _value:String;
		/**
		 * Whether the stat is masked. */
		private var _isMasked:Boolean = true;
		
		public function StatsData(data:Object)
		{
			if( !data ) return;
			
			_title = data.title;
			_value = data.value;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get title():String { return _title; }
		public function set title(val:String):void { _title = val; }
		
		public function get value():String { return _value; }
		public function set value(val:String):void { _value = val; }
		
		public function get isMasked():Boolean { return _isMasked; }
		public function set isMasked(value:Boolean):void { _isMasked = value; }
		
	}
}