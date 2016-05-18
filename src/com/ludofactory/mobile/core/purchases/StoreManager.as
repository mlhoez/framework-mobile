/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 22 sept. 2013
*/
package com.ludofactory.mobile.core.purchases
{
	
	import com.amazon.nativeextensions.android.AmazonItemData;
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.navigation.store.StoreData;
	import com.milkmangames.nativeextensions.android.AndroidItemDetails;
	import com.milkmangames.nativeextensions.ios.StoreKitProduct;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * Store that handles In-App Purchases for the Android, Amazon and Apple Store.
	 */	
	public class StoreManager extends EventDispatcher
	{
		/**
		 * MemberManager instance. */
		private static var _instance:StoreManager;
		
		/**
		 * Whether the manager have been initialized. */
		private var _isInitialized:Boolean = false;
		
		/**
		 * The store used to make purchases. */
		private var _store:Store;
		/**
		 * Temporary ids used to retreive the product details in the App Store. */
		private var _temporaryProductsIds:Vector.<String>;
		
		private var _productsData:Vector.<StoreData>;
		
		public function StoreManager(sk:SecurityKey)
		{
			if( sk == null)
				throw new Error("[MemberManager] You must call MamberManager.getInstance instead of new.");
		}
		
		public function initialize():void
		{
			if(!_isInitialized)
			{
				_store = new Store();
				_store.addEventListener(MobileEventTypes.STORE_INITIALIZED, onStoreInitialized);
				if(AirNetworkInfo.networkInfo.isConnected())
					_store.initialize();
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * When the store is initialized and if it is available, we need to fetch
		 * the product ids we want to load in the application. Since we want this
		 * to be dynamic and because we need to supply ids to Google or Apple in
		 * order to retreive the correct currency, we need to know the ids we want
		 * to load.
		 *
		 * <p>If in app purchases are not available, we need to display a message
		 * indicating that in app purchases are not available on this phone or
		 * account.</p>
		 */
		private function onStoreInitialized(event:Event):void
		{
			_isInitialized = true;
			
			_store.removeEventListener(MobileEventTypes.STORE_INITIALIZED, onStoreInitialized);
			
			if( !_store.available )
			{
				// the store is not available, we need to inform the user
				// FIXME display info message : _("Impossible d'afficher le magasin car vous ne pouvez pas effectuer d'achats (contrôle parental ou autre raison).");
			}
			else
			{
				//_areProductDetailsLoaded = true;
				
				_productsData = new Vector.<StoreData>();
				_productsData.push(new StoreData({ store_id:"premiumaccess" }));
				
				// supply ids to Google and Apple in order to get the product details, such as localized price and currency
				_temporaryProductsIds = new Vector.<String>();
				_temporaryProductsIds.push("pyramidbattle.premiumaccess"); // TODO a externaliser
				
				_store.addEventListener(MobileEventTypes.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
				_store.addEventListener(MobileEventTypes.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
				_store.requestProductDetails(_temporaryProductsIds); // load products
			}
		}
		
		/**
		 * The product detailshave been loaded from Google or Apple. Now we need
		 * to update the products with the details we got, then populate the list
		 * data provider.
		 */
		private function onProductsDetailsLoaded(event:Event):void
		{
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
			_store.addEventListener(MobileEventTypes.STORE_PURCHASE_SUCCESS, onPurchaseSuccess);
			_store.addEventListener(MobileEventTypes.STORE_PURCHASE_CANCELLED, onPurchaseCancelled);
			_store.addEventListener(MobileEventTypes.STORE_PURCHASE_FAILED, onPurchaseFailure);
			
			if(event.data)
			{
				var storeData:StoreData;
				
				if (GlobalConfig.ios)
				{
					// parse ios specific data
					for each(var storeKitProduct:StoreKitProduct in event.data)
					{
						for each(storeData in _productsData)
						{
							if (storeData.generatedId == storeKitProduct.productId)
								storeData.parseIosData(storeKitProduct);
						}
					}
					
				}
				else if (GlobalConfig.android)
				{
					// parse android specific data
					if (GlobalConfig.amazon)
					{
						// amazon
						for each(var amazonItemDetails:AmazonItemData in event.data)
						{
							for each(storeData in _productsData)
							{
								if (storeData.generatedId == amazonItemDetails.sku)
									storeData.parseAmazonData(amazonItemDetails);
							}
						}
					}
					else
					{
						// android
						for each(var androidItemDetails:AndroidItemDetails in event.data)
						{
							for each(storeData in _productsData)
							{
								if (storeData.generatedId == androidItemDetails.itemId)
									storeData.parseAndroidData(androidItemDetails);
							}
						}
					}
				}
			}
			
			// the user tried to pruchase an item but the store wasn't initialized yet
			// in this case we'll have a saved item that we will try to buy
			if(_savedProductIdToPurchase)
				_store.requestPurchase(_savedProductIdToPurchase);
		}
		
		private function onProductsDetailsNotLoaded(event:Event):void
		{
			// no product details loaded : something is wrong
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
			
			// TODO issue
		}
		
		private var _savedProductIdToPurchase:StoreData;
		/**
		 * When the player wants to buy a pack, we need to create first a request on the
		 * server side, for statistic purpose. Then when the creation is done, we launch
		 * the native window which allows the user to make a purchase.
		 */
		public function purchaseItem(id:String):void
		{
			for (var i:int = 0; i < _productsData.length; i++)
			{
				if(_productsData[i].generatedId == id)
					_savedProductIdToPurchase = _productsData[i];
			}
			
			if(!_isInitialized)
			{
				// is not initialized, we need to initialize first
				
			}
			else
			{
				// purchase item
				_store.requestPurchase(_savedProductIdToPurchase);
				//_canBack = false;
			}
		}
		
		/**
		 * Purchase success.
		 */
		private function onPurchaseSuccess(event:Event):void
		{
			// TODO
			// TODO track purchase
		}
		
		/**
		 * Purchase failed.
		 */
		private function onPurchaseFailure(event:Event):void
		{
			// TODO
			//_canBack = true;
		}
		
		/**
		 * Purchase cancelled.
		 */
		private function onPurchaseCancelled(event:Event):void
		{
			// TODO
			//_canBack = true;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
		
		/**
		 * Return the MemberManager instance.
		 */
		public static function getInstance():StoreManager
		{
			if(_instance == null)
				_instance = new StoreManager( new SecurityKey() );
			return _instance;
		}
		
	}
}

internal class SecurityKey{}