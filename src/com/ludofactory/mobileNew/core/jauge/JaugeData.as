/**
 * Created by Maxime on 02/05/16.
 */
package com.ludofactory.mobileNew.core.jauge
{
	
	public class JaugeData
	{
		/**
		 * The time stamp. */
		private var _timestamp:int;
		/**
		 * The associated score. */
		private var _score:int;
		
		public function JaugeData(data:Object)
		{
			if(data)
			{
				_timestamp = data.t;
				_score = data.s;
			}
		}
		
		public function parse(data:Object):void
		{
			_timestamp = data.t;
			_score = data.s;
		}
		
		public function get timestamp():int
		{
			return _timestamp;
		}
		
		public function get score():int
		{
			return _score;
		}
	}
}