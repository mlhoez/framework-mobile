/**
 * Created by Maxime on 28/04/16.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.common.encryption.Base64;
	import com.ludofactory.common.utils.logs.log;
	
	import flash.utils.ByteArray;
	
	public class GameActionsRecorder
	{
		/**
		 * All he records. */
		private var _record:Array = [];
		
		public function GameActionsRecorder()
		{
			
		}
		
		/**
		 * Adds a record for a score that have been updated.
		 * 
		 * Adds an object with structure :
		 * {
		 *    t: the time stamp
		 *    s: the score associated
		 * }
		 * 
		 * Note that the timestamp is in reverse order, for example if you add 100 at 2:59 while the
		 * main time is 3:00, the timestamp will be in second and equal 179.
		 * 
		 * @param timeStamp
		 * @param value
		 */
		public function add(timeStamp:int, value:int):void
		{
			if(_record.length > 0 && _record[_record.length-1].t == timeStamp) _record[_record.length-1].s += value;
			else _record.push( { t:timeStamp, s:value } )
		}
		
		/**
		 * 
		 */
		public function getFinal():String
		{
			log("Records :");
			log(JSON.stringify(_record));
			
			// String transformé en ByteArray, compressé puis encodé en Base64
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(JSON.stringify(_record));
			ba.position = 0;
			ba.deflate();
			
			// encode it in Base64
			var encoded:String = Base64.encodeByteArray(ba);
			// then make a safer String
			encoded = encoded.replace(/\//ig, "_"); // replaces any "/" by "_"
			encoded = encoded.replace(/\+/ig, "-"); // replaces any "+" by "-"
			encoded = encoded.replace(/=/ig, "*");  // replaces any "=" by "*"
			
			_record = [];
			
			return encoded;
		}
		
	}
}