/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.navigation.account.history.gifts
{
	public class GiftHistoryData
	{
		/**
		 * The date. */		
		private var _hour:String;
		
		/**
		 * The description. */		
		private var _description:String;
		
		/**
		 * If the gift was sent. */		
		private var _status:String;
		
		/**
		 * The gift id. */		
		private var _giftId:int;
		/**
		 * The gift id. */		
		private var _tableType:String;
		
		/**
		 * The game name. */		
		private var _category:String;
		
		/**
		 * Whether the gift is exchangeable with cheque. */		
		private var _exchangeableWithCheque:String;
		
		/**
		 * Whether the gift is exchangeable with points. */		
		private var _exchangeableWithPoints:String;
		
		public function GiftHistoryData(data:Object)
		{
			_hour = data.heure;
			_description = data.description;
			_category = data.rubrique;
			_status = data.statut;
			_giftId = data.echange.param_idgain;
			_tableType = data.echange.param_typetable;
			_exchangeableWithCheque = data.echange.cheque;
			_exchangeableWithPoints = data.echange.points;
		}
		
		public function get hour():String { return _hour; }
		public function get description():String { return _description; }
		public function get status():String { return _status; }
		public function get giftId():int { return _giftId; }
		public function get tableType():String { return _tableType; }
		public function get category():String { return _category; }
		public function get exchangeableWithCheque():String { return _exchangeableWithCheque; }
		public function get exchangeableWithPoints():String { return _exchangeableWithPoints; }
	}
}