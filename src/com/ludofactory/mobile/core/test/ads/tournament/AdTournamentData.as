/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 25 nov. 2013
*/
package com.ludofactory.mobile.core.test.ads.tournament
{
	import com.ludofactory.common.utils.Utilities;

	public class AdTournamentData
	{
		/**
		 * The image url of the gift */		
		private var _giftImageUrl:String;
		
		/**
		 * The gift name. */		
		private var _giftName:String;
		
		/**
		 * The button name. */		
		private var _buttonName:String;
		
		public function AdTournamentData( data:Object )
		{
			_giftImageUrl = data.img_lot;
			_giftName = Utilities.replaceCurrency(data.nom_lot);
			_buttonName = data.temps_restant;
		}
		
		public function get giftImageUrl():String { return _giftImageUrl; }
		public function get giftName():String { return _giftName; }
		public function get buttonName():String { return _buttonName; }
	}
}