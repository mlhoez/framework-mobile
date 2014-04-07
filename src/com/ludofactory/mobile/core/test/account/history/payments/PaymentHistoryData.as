/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.core.test.account.history.payments
{
	import com.ludofactory.common.utils.Utility;

	public class PaymentHistoryData
	{
		/**
		 * The payment type. */		
		private var _type:String;
		
		/**
		 * The payment date. */		
		private var _date:String;
		
		/**
		 * The offer. */		
		private var _offer:String;
		
		public function PaymentHistoryData(data:Object)
		{
			_type = data.type;
			_date = data.date;
			_offer = Utility.replaceCurrency(data.offre);
		}
		
		public function get type():String { return _type; }
		public function get date():String { return _date; }
		public function get offer():String { return _offer; }
	}
}