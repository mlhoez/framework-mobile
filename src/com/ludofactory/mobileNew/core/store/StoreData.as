/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 20 sept. 2013
*/
package com.ludofactory.mobileNew.core.store
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
		 * The base id that will be used to generate the correct in-app purchase id. */		
		private var _id:String;
		
		/**
		 * The generated product id. This is something like "game_name.id" registered on
		 * both Google Play and iTunes Connect. */		
		private var _generatedId:String;
		
		/**
		 * The payment code used to identify the type of payment (whether android, ios, paypal, etc.). */		
		private var _paymentCode:String;
		
		/**
		 * The localized price (only updated with Apple / Android / Amazon fetched data. */		
		private var _localizedPrice:String;
		
		/**
		 * The StoreData is created from an id fetched from our server. Then, we need to build the correct
		 * in-app purchase id that will be used by the Store to retreive the associated product detail.
		 */		
		public function StoreData(data:Object)
		{
			if("id_offre" in data && data.id_offre != null)
				_databaseOfferId = int( data.id_offre);
			
			if("store_id" in data && data.store_id != null)
				_id = String( data.store_id);
			
			if("code_paiement" in data && data.code_paiement != null)
				_paymentCode = data.code_paiement;
			
			_generatedId = AbstractGameInfo.PRODUCT_ID_PREFIX + "." + _id;
		}
		
		public function update(data:Object):void
		{
			if("id_offre" in data && data.id_offre != null)
				_databaseOfferId = int( data.id_offre);
			
			if("store_id" in data && data.store_id != null)
				_id = String( data.store_id);
			
			if("code_paiement" in data && data.code_paiement != null)
				_paymentCode = data.code_paiement;
			
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
		public function get id():String { return _id; }
		public function get generatedId():String { return _generatedId; }
		public function get localizedPrice():String { return _localizedPrice; }
		public function get paymentCode():String { return _paymentCode; }
	}
}