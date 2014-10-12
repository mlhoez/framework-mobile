/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 20 sept. 2013
*/
package com.ludofactory.mobile.core.navigation.store
{
	import com.amazon.nativeextensions.android.AmazonItemData;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.milkmangames.nativeextensions.android.AndroidItemDetails;
	import com.milkmangames.nativeextensions.ios.StoreKitProduct;

	public class StoreData
	{
		/**
		 * The database offer id. */		
		private var _databaseOfferId:int;
		
		/**
		 * The database id that will be used to generate
		 * the correct in-app purchase id. */		
		private var _id:int;
		
		/**
		 * The generated product id. This is something like
		 * "game_name.id" registered on both Google Play and
		 * iTunes Connect. */		
		private var _generatedId:String;
		
		/**
		 * The gain. */		
		private var _gain:String;
		
		/**
		 * The bonus. */		
		private var _promo:int;
		
		/**
		 * The payment code used to identify the type
		 * of payment (whether android, ios, paypal, etc.) */		
		private var _paymentCode:String;
		
		/**
		 * The localized price. */		
		private var _localizedPrice:String;
		
		/**
		 * Whether it's a top offer. */		
		private var _isTopOffer:Boolean = false;
		
		/**
		 * Whether it's the players choice. */		
		private var _isPlayersChoice:Boolean = false;
		
		/**
		 * The StoreData is created from an id fetched from
		 * our server. Then, we need to build the correct
		 * in-app purchase id that will be used by the Store
		 * to retreive the associated product detail.
		 */		
		public function StoreData(data:Object)
		{
			if( data.hasOwnProperty("id_offre") && data.id_offre != null )
				_databaseOfferId = int( data.id_offre);
			
			if( data.hasOwnProperty("store_id") && data.store_id != null )
				_id = int( data.store_id);
			
			if( data.hasOwnProperty("nb_credit") && data.nb_credit != null )
				_gain = data.nb_credit;
			
			if( data.hasOwnProperty("nb_credit_promo") && data.nb_credit_promo != null )
				_promo = int(data.nb_credit_promo);
			
			if( data.hasOwnProperty("code_paiement") && data.code_paiement != null )
				_paymentCode = data.code_paiement;
			
			if( data.hasOwnProperty("top_offre") && data.top_offre != null )
				_isTopOffer = int(data.top_offre) == 1 ? true : false;
			
			if( data.hasOwnProperty("choix_joueur") && data.choix_joueur != null )
				_isPlayersChoice = int(data.choix_joueur) == 1 ? true : false;
			
			_generatedId = AbstractGameInfo.PRODUCT_ID_PREFIX + "." + _id;
		}
		
		public function update(data:Object):void
		{
			if( data.hasOwnProperty("id_offre") && data.id_offre != null )
				_databaseOfferId = int( data.id_offre);
			
			if( data.hasOwnProperty("store_id") && data.store_id != null )
				_id = int( data.store_id);
			
			if( data.hasOwnProperty("nb_credit") && data.nb_credit != null )
				_gain = data.nb_credit;
			
			if( data.hasOwnProperty("nb_credit_promo") && data.nb_credit_promo != null )
				_promo = int(data.nb_credit_promo);
			
			if( data.hasOwnProperty("code_paiement") && data.code_paiement != null )
				_paymentCode = data.code_paiement;
			
			if( data.hasOwnProperty("top_offre") && data.top_offre != null )
				_isTopOffer = int(data.top_offre) == 1 ? true : false;
			
			if( data.hasOwnProperty("choix_joueur") && data.choix_joueur != null )
				_isPlayersChoice = int(data.choix_joueur) == 1 ? true : false;
			
			_generatedId = AbstractGameInfo.PRODUCT_ID_PREFIX + "." + _id;
		}
		
		public function parseIosData(data:StoreKitProduct):void
		{
			_localizedPrice = data.localizedPrice;
		}
		
		public function parseAndroidData(data:AndroidItemDetails):void
		{
			_localizedPrice = data.price;
		}
		
		public function parseAmazonData(data:AmazonItemData):void
		{
			_localizedPrice = data.price;
		}
		
		public function get databaseOfferId():int { return _databaseOfferId; }
		public function get id():int { return _id; }
		public function get generatedId():String { return _generatedId; }
		public function get gain():String { return _gain; }
		public function get localizedPrice():String { return _localizedPrice; }
		public function get paymentCode():String { return _paymentCode; }
		public function get promo():int { return _promo; }
		public function get isTopOffer():Boolean { return _isTopOffer; }
		public function get isPlayersChoice():Boolean { return _isPlayersChoice; }
	}
}