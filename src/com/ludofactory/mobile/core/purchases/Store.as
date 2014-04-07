/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 22 sept. 2013
*/
package com.ludofactory.mobile.core.purchases
{
	import com.amazon.nativeextensions.android.AmazonPurchase;
	import com.amazon.nativeextensions.android.AmazonPurchaseReceipt;
	import com.amazon.nativeextensions.android.events.AmazonPurchaseEvent;
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.store.StoreData;
	import com.milkmangames.nativeextensions.android.AndroidIAB;
	import com.milkmangames.nativeextensions.android.AndroidItemDetails;
	import com.milkmangames.nativeextensions.android.events.AndroidBillingErrorEvent;
	import com.milkmangames.nativeextensions.android.events.AndroidBillingErrorID;
	import com.milkmangames.nativeextensions.android.events.AndroidBillingEvent;
	import com.milkmangames.nativeextensions.ios.StoreKit;
	import com.milkmangames.nativeextensions.ios.events.StoreKitErrorEvent;
	import com.milkmangames.nativeextensions.ios.events.StoreKitEvent;
	
	import starling.events.EventDispatcher;
	
	public class Store extends EventDispatcher
	{
		/**
		 * Whether the user can make purchases : if the store is available
		 * on this platform and also if the user have the rights to make
		 * purchases. */		
		private var _available:Boolean = false;
		
		private var _temporaryItemDetails:Vector.<AndroidItemDetails>;
		
		private var _androidInitialized:Boolean = false;
		
		private var _currentProductData:StoreData;
		private var _currentRequest:Object;
		
		private var _isInitialized:Boolean = false;
		
		public function Store()
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												COMMON API
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Initialize the store depending on the os the game is running on.
		 * 
		 * <p>At the end of the initialization, an event of type LudoEventType
		 * STORE_INITIALIZED will be dispatched so that the store screen can
		 * know if it can request the product details or not.</p>
		 * 
		 * <p>If the user in not on one of the two os, no store will
		 * be available.</p>
		 */		
		public function initialize():void
		{
			log("Amazon supported ? " + AmazonPurchase.isSupported() );
			
			if( GlobalConfig.android )
			{
				if( GlobalConfig.amazon )
				{
					log("[Store] Running Amazon Store.");
					initializeAmazon();
				}
				else
				{
					log("[Store] Running Android Store.");
					initializeAndroid();
				}
			}
			else if ( GlobalConfig.ios )
			{
				log("[Store] Running Apple Store.");
				initializeApple();
			}
			else
			{
				log("[Store] No store is available on this platform.");
				dispatchEventWith(LudoEventType.STORE_INITIALIZED);
			}
			
			_isInitialized = true;
		}
		
		/**
		 * Request the product details.
		 * 
		 * <p>In any cases, the Store will dispatch an event of
		 * type LudoEventType.STORE_PRODUCTS_LOADED.</p>
		 * 
		 * <p>If the products could be loaded, the event data won't be
		 * null and will contains a vector of product details.<br />
		 * Depending on the os, the vector will contain objects
		 * of type <code>AndroidItemDetails</code> if we are on
		 * Android and objects of type <code>StoreKitProduct</code>
		 * if we are on iOS.</p>
		 */		
		public function requestProductDetails( productDetails:Vector.<String> ):void
		{
			if( _available )
			{
				if( GlobalConfig.android )
				{
					if( GlobalConfig.amazon )
					{
						var productDetailsArray:Array = [];
						for(var i:int = 0; i < productDetails.length; i++)
							productDetailsArray.push( productDetails[i] );
						productDetailsArray.pop();
						//TweenMax.delayedCall(10, AmazonPurchase.amazonPurchase.loadItemData, [ productDetailsArray ]);
						AmazonPurchase.amazonPurchase.loadItemData(productDetailsArray);
					}
					else
					{
						AndroidIAB.androidIAB.loadPlayerInventory(true, productDetails);
					}
				}
				else if( GlobalConfig.ios )
				{
					StoreKit.storeKit.loadProductDetails( productDetails );
				}
			}
		}
		
		/**
		 * Request purchase
		 * 
		 * save current product id
		 */		
		public function requestPurchase(productData:StoreData):void
		{
			log("[Store] Creating request for " + productData.generatedId);
			InfoManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
			_currentProductData = productData;
			Remote.getInstance().createRequest( _currentProductData.databaseOfferId, onRequestPurchaseSuccess, onRequestPurchaseFailure, onRequestPurchaseFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
		/**
		 * The request have been created, now we can allow the user to buy the item.
		 */		
		private function onRequestPurchaseSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 1: // ok
				{
					log("[Store] Request created for " + _currentProductData.generatedId);
					_currentRequest = result.demande;
					purchaseItem(_currentProductData.generatedId);
					break;
				}
					
				default:
				{
					onRequestPurchaseFailure();
					break;
				}
			}
		}
		
		/**
		 * The request could not be created.
		 */		
		private function onRequestPurchaseFailure(error:Object = null):void
		{
			log("[Store] Could not create request for " + _currentProductData.generatedId);
			InfoManager.hide(Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), InfoContent.ICON_CROSS, 5);
			_currentProductData = null;  
			
		}
		
		/**
		 * Purchase a product by its id.
		 * 
		 * <p>On android, when the purchase is done we need to
		 * "consume" the item or the user won't be able to
		 * purchase it again. If consume is done, we can
		 * </p>
		 * 
		 * @param productId Id of the product to purchase.
		 */		
		private function purchaseItem(productId:String):void
		{
			if( _available )
			{
				if( GlobalConfig.android )
				{
					if( GlobalConfig.amazon )
					{
						log("[Store] Making Amazon purchase of " + productId);
						AmazonPurchase.amazonPurchase.purchaseItem( productId );
					}
					else
					{
						log("[Store] Making Android purchase of " + productId);
						AndroidIAB.androidIAB.purchaseItem( productId );
					}
				}
				else if( GlobalConfig.ios )
				{
					log("[Store] Making iOS purchase of " + productId);
					StoreKit.storeKit.purchaseProduct( productId );
				}
			}
			else
			{
				log("[Store] No store is available or initialization in not yet complete.");
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Success handlers
		
		/**
		 * When a request is validated, we need to update the request
		 * state in the database (if possible).
		 * 
		 * result is the result from ios or android, always stringified
		 * as a JSON.
		 */		
		private function validateRequest( result:Object ):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Remote.getInstance().validateRequest(_currentProductData, GlobalConfig.amazon ? result : JSON.stringify(result), _currentRequest, onValidatePurchaseSuccess, onValidatePurchaseFailure, onValidatePurchaseFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				onValidatePurchaseFailure();
			}
		}
		
		private function onValidatePurchaseSuccess(result:Object = null):void
		{
			log("[Store] Request " + _currentRequest.id + " validated");
			onPurchaseSuccess( _currentProductData.generatedId, result.nb_credits_ajouter, result.txt, int(result.changement_rang) == 1 ? true : false );
		}
		
		private function onValidatePurchaseFailure(error:Object = null):void
		{
			log("[Store]  Request " + _currentRequest.id + " NOT validated");
			onPurchaseFail( _currentProductData.generatedId );
		}
		
		/**
		 * Item successfully purchased.
		 */		
		private function onPurchaseSuccess(itemId:String, numCreditsBought:int, textValue:String, newRank:Boolean):void
		{
			log("[Store] Item purchased : " + itemId);
			
			Flox.logEvent("Achats du pack [" + itemId+ "]", {Etat:"Valide", Total:"Total"});
			
			_currentProductData = null;
			_currentRequest = null;
			
			dispatchEventWith(LudoEventType.STORE_PURCHASE_SUCCESS, false, { value:numCreditsBought, id:itemId, txt:textValue, newRank:newRank });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Cancel handlers
		
		/**
		 * When a request is cancelled, we need to update the request
		 * state in the database (if possible).
		 */		
		private function cancelRequest():void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Remote.getInstance().changeRequestState(_currentProductData, _currentRequest, 2, onChangeRequestStateCanceledSuccess, onChangeRequestStateCanceledFailure, onChangeRequestStateCanceledFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				onChangeRequestStateCanceledFailure();
			}
		}
		
		/**
		 * The request state have been successfully updated.
		 */		
		private function onChangeRequestStateCanceledSuccess(result:Object = null):void
		{
			onPurchaseCancelled( _currentProductData.generatedId );
		}
		
		/**
		 * The request state could not be updated.
		 */		
		private function onChangeRequestStateCanceledFailure(error:Object = null):void
		{
			onPurchaseCancelled( _currentProductData.generatedId );
		}
		
		/**
		 * Purchase was cancelled.
		 */		
		private function onPurchaseCancelled(itemId:String):void
		{
			log("[Store] Item purchase cancelled : " + itemId);
			
			Flox.logEvent("Achats du pack [" + itemId+ "]", {Etat:"Annule", Total:"Total"});
			
			_currentProductData = null;
			_currentRequest = null;
			
			InfoManager.hide(Localizer.getInstance().translate("STORE.PURCHASE_CANCELLED"), InfoContent.ICON_CROSS, 2);
			dispatchEventWith(LudoEventType.STORE_PURCHASE_CANCELLED, false, itemId);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Failure handlers
		
		/**
		 * When a request is cancelled, we need to update the request
		 * state in the database (if possible).
		 */		
		private function failRequest():void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Remote.getInstance().changeRequestState(_currentProductData, _currentRequest, 0, onChangeRequestStateFailedSuccess, onChangeRequestStateFailedFailure, onChangeRequestStateFailedFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				onChangeRequestStateFailedFailure();
			}
		}
		
		/**
		 * The request state have been successfully updated.
		 */		
		private function onChangeRequestStateFailedSuccess(result:Object):void
		{
			onPurchaseFail( _currentProductData.generatedId );
		}
		
		/**
		 * The request state could not be updated.
		 */		
		private function onChangeRequestStateFailedFailure(error:Object = null):void
		{
			onPurchaseFail( _currentProductData.generatedId );
		}
		
		/**
		 * Item unsuccessfully purchased.
		 */		
		private function onPurchaseFail(itemId:String):void
		{
			log("[Store] Item not purchased : " + itemId);
			
			Flox.logEvent("Achats du pack [" + itemId+ "]", {Etat:"Echec", Total:"Total"});
			
			_currentProductData = null;
			_currentRequest = null;
			
			InfoManager.hide(Localizer.getInstance().translate("STORE.PURCHASE_FAILURE"), InfoContent.ICON_CROSS, 2);
			dispatchEventWith(LudoEventType.STORE_PURCHASE_FAILURE, false, itemId);
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//													ANDROID
//
//
//
//------------------------------------------------------------------------------------------------------------
		
//------------------------------------------------------------------------------------------------------------
//	Initialization
		
		/**
		 * Initialize Android billing service.
		 */		
		private function initializeAndroid():void
		{
			if( !AndroidIAB.isSupported() )
			{
				log("[Store] Android store is not available on this platform.");
				_available = false;
				dispatchEventWith(LudoEventType.STORE_INITIALIZED);
				return;
			}
			
			try
			{
				AndroidIAB.create();
			} 
			catch(error:Error) 
			{
				// Android billing instance was already created.
			}
			
			AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.SERVICE_READY, onServiceReady);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.SERVICE_NOT_SUPPORTED, onServiceUnsupported);
			AndroidIAB.androidIAB.startBillingService( AbstractGameInfo.GOOGLE_PLAY_ID );
		}
		
		/**
		 * Android billing service is ready. Before making any purchase, we need
		 * to load the product details so that we can display the correct currency
		 * to the user in the store screen list.
		 * 
		 * <p>If the products could not be loaded, we display the default currency
		 * which is the dollar.</p>
		 */		
		private function onServiceReady(event:AndroidBillingEvent):void
		{
			log("[Store] Android billing service started.");
			
			_available = true;
			
			AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.INVENTORY_LOADED, onInventoryLoaded);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingErrorEvent.LOAD_INVENTORY_FAILED, onInventoryNotLoaded);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.CONSUME_SUCCEEDED, onItemConsumed);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingErrorEvent.CONSUME_FAILED, onConsumeFailed);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.PURCHASE_SUCCEEDED, onGooglePurchaseSuccess);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingErrorEvent.PURCHASE_FAILED, onGooglePurchaseFail);
			
			dispatchEventWith(LudoEventType.STORE_INITIALIZED);
		}
		
		/**
		 * Android billing service was not started because it is unsupported on this platform.
		 */		
		private function onServiceUnsupported(event:AndroidBillingEvent):void
		{
			log("[Store] Android billing service is not supported on this platform.");
			
			_available = false;
			
			dispatchEventWith(LudoEventType.STORE_INITIALIZED);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Loading products - Consuming
		
		/**
		 * The inventory have been loaded with product details if requested
		 * (we request them after the android billing service is ready).
		 * 
		 * <p>This function should be called after the service is ready, before
		 * and after a purchase. We absolutly need to do that because we need
		 * to handle the fact that items could have been purchased but for some
		 * reason, not consumed. Also because consuming an item is not enough
		 * to refresh the inventory in Google side and if we don't do that, the
		 * user won't be able to purchase items again.</p>
		 * 
		 * <p>This function will check if the user currently owns some items. If
		 * so, we will consume each item and then reload the inventory again to
		 * refresh the inventory state in Google Side (it will be called after
		 * the consume is done).
		 */		
		private function onInventoryLoaded(event:AndroidBillingEvent):void
		{
			log("[Store] inventory loaded - there are [" + event.itemDetails.length + "] items loaded.");
			
			if( event.itemDetails.length > 0 )
				_temporaryItemDetails = event.itemDetails;
			
			if( event.purchases.length > 0 )
			{
				log("[Store] " + event.purchases.length + " items to consume.");
				// while there are items to consume, we consume them
				consumeItem( event.purchases[0].itemId );
			}
			else
			{
				log("[Store] NO item to consume.");
				if( !_androidInitialized )
				{
					// everything have been consumed, now we can really start
					// the store (because all items are now available for purchase).
					log("[Store] Every item have been consumed, now making the store available.");
					dispatchEventWith(LudoEventType.STORE_PRODUCTS_LOADED, false, _temporaryItemDetails);
					_androidInitialized = true;
				}
				else
				{
					log("[Store] Every item have been consumed and nothing to do now.");
				}
			}
		}
		
		/**
		 * The inventory could not be loaded.
		 */		
		private function onInventoryNotLoaded(event:AndroidBillingErrorEvent):void
		{
			log("Inventaire non chargé : " + log(event) );
			if( !_androidInitialized )
			{
				dispatchEventWith(LudoEventType.STORE_PRODUCTS_NOT_LOADED, false, event.text);
				_androidInitialized = true;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Purchases
		
		/**
		 * Item successfully purchased.
		 */		
		private function onGooglePurchaseSuccess(event:AndroidBillingEvent):void
		{
			log("[Store] Android purchase success.");
			// items will be consumed after the inventory is loaded,
			// and if everything is ok, we validate in our side.
			AndroidIAB.androidIAB.loadPlayerInventory();
		}
		
		/**
		 * Item could not be purchased.
		 */		
		private function onGooglePurchaseFail(event:AndroidBillingErrorEvent):void
		{
			log("[Store] Something went wrong with the purchase of " + event.itemId + " : " + event.text);
			
			switch(event.errorID)
			{
				case AndroidBillingErrorID.ITEM_ALREADY_OWNED:
				{
					// because we need to consume an item before being able to purchase it again,
					// we handle the fact that consume item may have not been called right after a
					// purchase. We can do that because all items are consumable items for now,
					// but if we need to handle non-consumable items, it has to be managed there.
					
					// this should not happen since we always consume an item right after the
					// purchase, but in case, we handle this problem here.
					//consumeItem(event.itemId);
					log("[Store] The item trying to be purchased is already owned by the user, it has to be consumed before.");
					AndroidIAB.androidIAB.loadPlayerInventory();
					failRequest();
					break;
				}
					
				case AndroidBillingErrorID.USER_CANCELLED:
				{
					cancelRequest();
					break;
				}
				
				default:
				{
					failRequest();
					break;
				}
			}
		}
		
// Comsume
		
		/**
		 * In Android we need to consume an item before being able to purchase it again.
		 * According to Google's guidelines for in app purchases, it is when the item
		 * have been successfully consumed that we can give the user what he bought (the
		 * credits in our case).
		 * 
		 * <p>Guidelines for InApp Billing API v3 :
		 * http://developer.android.com/training/in-app-billing/purchase-iab-products.html</p>
		 */		
		private function consumeItem(itemId:String):void
		{
			log("Consuming item " + itemId + "..." );
			AndroidIAB.androidIAB.consumeItem( itemId );
		}
		
		/**
		 * The item was consumed, allowing the user to purchase it again.
		 * 
		 * <p>Here we need to validate the payment in our side and if everything is fine
		 * we will give the user the number of credits he bought.</p>
		 */		
		private function onItemConsumed(event:AndroidBillingEvent):void
		{
			log("[Store] The item " + event.itemId + " have been consumed.");
			
			var obj:Object = {};
			obj.itemId = event.itemId;
			obj.jsonData = event.jsonData;
			obj.purchaseTime = event.purchaseTime;
			obj.purchaseToken = event.purchaseToken;
			obj.signature = event.signature;
			
			// we need to reload the player's inventory to update the state of the consumed item in
			// Google side. This is necessary or we won't be able to purchase this item again after.
			validateRequest( obj );
			AndroidIAB.androidIAB.loadPlayerInventory();
		}
		
		/**
		 * Item could not be consumed.
		 */		
		private function onConsumeFailed(event:AndroidBillingErrorEvent):void
		{
			// votre achat a bien été pris en compte mais nous n'avons pas pu blablabla revenez plus tard pour le valider
			log("[Store] Something went wrong consuming " + event.itemId + " : " + event.text);
			failRequest();
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//											A P P L E
//
//
//
//------------------------------------------------------------------------------------------------------------
		
//------------------------------------------------------------------------------------------------------------
//	Initialization
		
		/**
		 * Initialize the iOS store.
		 */	
		private function initializeApple():void
		{
			if( !StoreKit.isSupported() )
			{
				log("[Store] Apple store is not supported on this platform.");
				_available = false;
				dispatchEventWith(LudoEventType.STORE_INITIALIZED);
				return;
			}
			
			try
			{
				StoreKit.create();
			} 
			catch(error:Error) 
			{
				// StoreKit instance was already created.
			}
			
			// check if the specific device will support In-App Purchases. Parental
			// control or other settings can prevent purchases from being made at all.
			if( StoreKit.storeKit.isStoreKitAvailable() )
			{
				_available = true;
				
				StoreKit.storeKit.addEventListener(StoreKitEvent.PRODUCT_DETAILS_LOADED, onAppleProductsLoaded);
				StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PRODUCT_DETAILS_FAILED, onAppleProductsFailed);
				StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_SUCCEEDED, onApplePurchaseSuccess);
				StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_CANCELLED, onApplePurchaseCancelled);
				StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PURCHASE_FAILED, onApplePurchaseFailed);
				
				dispatchEventWith(LudoEventType.STORE_INITIALIZED);
			}
			else
			{
				log("[StoreKitManager] StoreKit is disabled for this device (parental control or other reason).");
				_available = false;
				dispatchEventWith(LudoEventType.STORE_INITIALIZED);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Loading products
		
		/**
		 * Called when the product details are loaded.
		 */		
		private function onAppleProductsLoaded(event:StoreKitEvent):void
		{
			log("[Store] onAppleProductsLoaded - Number of Apple products loaded : " + event.validProducts.length);
			dispatchEventWith(LudoEventType.STORE_PRODUCTS_LOADED, false, event.validProducts);
		}
		
		/**
		 * Called when the product details have not been loaded.
		 */		
		private function onAppleProductsFailed(event:StoreKitErrorEvent):void
		{
			log("[Store] onAppleProductsFailed - Error loading products : " + event.text);
			dispatchEventWith(LudoEventType.STORE_PRODUCTS_NOT_LOADED, false, event.text);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Purchases
		
		/**
		 * The Apple purchase is complete.
		 */		
		private function onApplePurchaseSuccess(event:StoreKitEvent):void
		{
			log("[Store] Purchase ok for " + event.productId);
			log("[Store] Now validating in our server...");
			
			var result:Object = {};
			result.originalErrorId = event.originalErrorId;
			result.originalTransactionId = event.originalTransactionId;
			result.productId = event.productId;
			result.receipt = event.receipt;
			result.transactionId = event.transactionId;
			log(JSON.stringify(result));
			
			validateRequest( result );
		}
		
		/**
		 * The Apple purchase was cancelled by the user.
		 */		
		private function onApplePurchaseCancelled(event:StoreKitEvent):void
		{
			log("[Store] Apple purchase cancelled.");
			cancelRequest();
		}
		
		/**
		 * The Apple purchase has failed, probably because the Apple account
		 * is not a test account (when we are in debug mode), or for some other
		 * reason otherwise.
		 */		
		private function onApplePurchaseFailed(event:StoreKitErrorEvent):void
		{
			log("[Store] Apple purchase failure.");
			failRequest()
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//													A M A Z O N
//
//
//
//------------------------------------------------------------------------------------------------------------
		
//------------------------------------------------------------------------------------------------------------
//	Initialization
		
		private function initializeAmazon():void
		{
			if( !AmazonPurchase.isSupported() )
			{
				log("[Store] Amazon store is not available on this platform.");
				_available = false;
				dispatchEventWith(LudoEventType.STORE_INITIALIZED);
				return;
			}
			
			try
			{
				AmazonPurchase.create();
			} 
			catch(error:Error) 
			{
				// Amazon instance was already created.
			}
			
			_available = true;
			
			AmazonPurchase.amazonPurchase.addEventListener(AmazonPurchaseEvent.SDK_AVAILABLE, onSdkAvailable);
			AmazonPurchase.amazonPurchase.addEventListener(AmazonPurchaseEvent.ITEM_DATA_LOADED, onAmazonProductsLoaded);
			AmazonPurchase.amazonPurchase.addEventListener(AmazonPurchaseEvent.ITEM_DATA_FAILED, onAmazonProductsFailed);
			AmazonPurchase.amazonPurchase.addEventListener(AmazonPurchaseEvent.PURCHASE_SUCCEEDED, onAmazonPurchaseSuccess);
			AmazonPurchase.amazonPurchase.addEventListener(AmazonPurchaseEvent.PURCHASE_FAILED, onAmazonPurchaseFailed);
			
			dispatchEventWith(LudoEventType.STORE_INITIALIZED);
		}
		
		/**
		 * This Event is fired shortly after initialization. The isSandboxMode
		 * property will be "true", if you're in test mode and not the real store.
		 */		
		private function onSdkAvailable(event:AmazonPurchaseEvent):void
		{
			log("Amazon SDK loaded, sandbox mode = " + event.isSandboxMode);
		}
		
		private function onAmazonProductsLoaded(event:AmazonPurchaseEvent):void
		{
			log("[Store] onAmazonProductsLoaded - Number of Amazon products loaded : " + event.itemDatas.length);
			dispatchEventWith(LudoEventType.STORE_PRODUCTS_LOADED, false, event.itemDatas);
		}
		
		/**
		 * Called when the product details have not been loaded.
		 */		
		private function onAmazonProductsFailed(event:AmazonPurchaseEvent):void
		{
			log("[Store] onAmazonProductsFailed - Error loading products : " + log(event));
			dispatchEventWith(LudoEventType.STORE_PRODUCTS_NOT_LOADED, false, event.toString());
		}
		
		/**
		 * The Apple purchase was cancelled by the user.
		 */		
		/*private function onApplePurchaseCancelled(event:StoreKitEvent):void
		{
			log("[Store] Amazon purchase cancelled.");
			cancelRequest();
		}*/
		
		/**
		 * The Apple purchase has failed, probably because the Apple account
		 * is not a test account (when we are in debug mode), or for some other
		 * reason otherwise.
		 */		
		private function onAmazonPurchaseFailed(event:AmazonPurchaseEvent):void
		{
			log("[Store] Amazon purchase failure.");
			// FIXME trouver un moyen de savoir si ça a été annulé ou non
			failRequest()
		}
		
		/**
		 * Dispatched when an item is successfully purchased
		 */		
		private function onAmazonPurchaseSuccess(event:AmazonPurchaseEvent):void
		{
			log("[Store] Purchase ok for " + event.itemSku);
			log("[Store] Now validating in our server...");
			validateRequest( AmazonPurchaseReceipt(event.receipts[0]).purchaseToken );
		}
		
//------------------------------------------------------------------------------------------------------------
//	GET
//------------------------------------------------------------------------------------------------------------
		
		public function get available():Boolean { return _available; }
		public function get isInitialized():Boolean { return _isInitialized; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Dispose the store.
		 */		
		public function dispose():void
		{
			if( GlobalConfig.android )
			{
				if( GlobalConfig.amazon )
				{
					try
					{
						AmazonPurchase.amazonPurchase.removeEventListener(AmazonPurchaseEvent.SDK_AVAILABLE, onSdkAvailable);
						AmazonPurchase.amazonPurchase.removeEventListener(AmazonPurchaseEvent.ITEM_DATA_LOADED, onAmazonProductsLoaded);
						AmazonPurchase.amazonPurchase.removeEventListener(AmazonPurchaseEvent.ITEM_DATA_FAILED, onAmazonProductsFailed);
						AmazonPurchase.amazonPurchase.removeEventListener(AmazonPurchaseEvent.PURCHASE_SUCCEEDED, onAmazonPurchaseSuccess);
						AmazonPurchase.amazonPurchase.removeEventListener(AmazonPurchaseEvent.PURCHASE_FAILED, onAmazonPurchaseFailed);
					} 
					catch(error:Error) 
					{
						// probably because the store was not initialized.
					}
				}
				else
				{
					try
					{
						AndroidIAB.androidIAB.removeEventListener(AndroidBillingEvent.INVENTORY_LOADED, onInventoryLoaded);
						AndroidIAB.androidIAB.removeEventListener(AndroidBillingErrorEvent.LOAD_INVENTORY_FAILED, onInventoryNotLoaded);
						AndroidIAB.androidIAB.removeEventListener(AndroidBillingEvent.SERVICE_READY, onServiceReady);
						AndroidIAB.androidIAB.removeEventListener(AndroidBillingEvent.SERVICE_NOT_SUPPORTED, onServiceUnsupported);
						AndroidIAB.androidIAB.removeEventListener(AndroidBillingEvent.CONSUME_SUCCEEDED, onItemConsumed);
						AndroidIAB.androidIAB.removeEventListener(AndroidBillingErrorEvent.CONSUME_FAILED, onConsumeFailed);
						AndroidIAB.androidIAB.removeEventListener(AndroidBillingEvent.PURCHASE_SUCCEEDED, onGooglePurchaseSuccess);
						AndroidIAB.androidIAB.removeEventListener(AndroidBillingErrorEvent.PURCHASE_FAILED, onGooglePurchaseFail);
						
						AndroidIAB.androidIAB.stopBillingService();
					} 
					catch(error:Error) 
					{
						// probably because the store was not initialized.
					}
				}
			}
			else if( GlobalConfig.ios )
			{
				try
				{
					StoreKit.storeKit.removeEventListener(StoreKitEvent.PRODUCT_DETAILS_LOADED, onAppleProductsLoaded);
					StoreKit.storeKit.removeEventListener(StoreKitErrorEvent.PRODUCT_DETAILS_FAILED, onAppleProductsFailed);
					StoreKit.storeKit.removeEventListener(StoreKitEvent.PURCHASE_SUCCEEDED, onApplePurchaseSuccess);
					StoreKit.storeKit.removeEventListener(StoreKitEvent.PURCHASE_CANCELLED, onApplePurchaseCancelled);
					StoreKit.storeKit.removeEventListener(StoreKitErrorEvent.PURCHASE_FAILED, onApplePurchaseFailed);
					
					StoreKit.storeKit.dispose();
				} 
				catch(error:Error) 
				{
					// probably because the store was not initialized.
				}
			}
		}
		
	}
}