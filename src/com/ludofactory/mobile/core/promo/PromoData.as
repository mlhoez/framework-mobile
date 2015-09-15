/**
 * Created by Maxime on 14/09/15.
 */
package com.ludofactory.mobile.core.promo
{
	
	/**
	 * Object representing a promo data.
	 */
	public class PromoData
	{
		/**
		 * Promo percent (ex: +30%) displayed in the drop.
		 * Ex : +30<font size='#size#'>%</font> 
		 * Ex : <textformat leading='-6'>+30<font size='#size#'>%</font>\n<font size='#size#'>offerts</font></textformat> */
		private var _percent:String = "";
		
		/**
		 * The title. */
		private var _title:String = "";
		
		/**
		 * The message to display below the title in non-compact display mode.
		 * Ex : 30<font size='14'>%</font> de Crédits offerts */
		private var _message:String = "";
		
		/**
		 * The remaining time until the ned of the promotion (in seconds). */
		private var _timeLeft:int = 0;
		
		public function PromoData(data:Object)
		{
			if("percent" in data && data.percent)
				_percent = String(data.percent);
			
			if("title" in data && data.title)
				_title = String(data.title);
			
			if("message" in data && data.message)
				_message = String(data.message);
			
			if("timeLeft" in data && data.timeLeft)
				_timeLeft = int(data.timeLeft);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get
		
		public function get percent():String { return _percent; }
		public function get title():String { return _title; }
		public function get message():String { return _message; }
		public function get timeLeft():int { return _timeLeft; }
		
	}
}