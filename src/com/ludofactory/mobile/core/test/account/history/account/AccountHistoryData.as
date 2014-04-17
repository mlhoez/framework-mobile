/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.core.test.account.history.account
{
	import com.ludofactory.common.utils.Utilities;

	public class AccountHistoryData
	{
		/**
		 * The date. */		
		private var _date:String;
		
		/**
		 * The message. */		
		private var _text:String;
		
		public function AccountHistoryData(data:Object)
		{
			_date = data.date;
			_text = Utilities.replaceCurrency(data.txt);
		}
		
		public function get date():String { return _date; }
		public function get text():String { return _text; }
	}
}