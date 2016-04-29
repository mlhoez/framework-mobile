/**
 * Created by Maxime on 26/04/2016.
 */
package com.ludofactory.newClasses
{
	
	public class StatsData
	{
		/**
		 * The stat title. */
		private var _title:String;
		/**
		 * The stat description. */
		private var _value:String;
		
		public function StatsData(data:Object)
		{
			if( !data ) return;
			
			_title = data.title;
			_value = data.value;
		}
		
		public function get title():String { return _title; }
		public function set title(val:String):void { _title = val; }
		
		public function get value():String { return _value; }
		public function set value(val:String):void { _value = val; }
	}
}