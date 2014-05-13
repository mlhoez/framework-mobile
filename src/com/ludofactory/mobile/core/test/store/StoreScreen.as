/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 20 sept. 2013
*/
package com.ludofactory.mobile.core.test.store
{
	import com.amazon.nativeextensions.android.AmazonItemData;
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.hasoffers.nativeExtensions.MobileAppTracker;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.authentication.NotLoggedInContainer;
	import com.ludofactory.mobile.core.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.purchases.Store;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.ads.store.AdStoreContainer;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.milkmangames.nativeextensions.android.AndroidItemDetails;
	import com.milkmangames.nativeextensions.ios.StoreKitProduct;
	
	import eu.alebianco.air.extensions.analytics.Analytics;
	
	import feathers.controls.List;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.data.ListCollection;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	/**
	 * In-App Purchases ids cannot be shared between two applications. Instead, we
	 * need to define the same offer over each application. On Google Play, everything
	 * is fine because applications can have the same in-app purchase id, but on iTunes
	 * Connect, two applications cannot have the same in-app purchase id.
	 * 
	 * <p>Because of this, we need to add a prefix to each offer to uniquely identify
	 * each in-app purchase over each application. For example, Pyramid will have an
	 * in-app purchase "pyramid.1" and Gold Digger will have an in-app purchase with
	 * id "gold_digger.1".</p>
	 * 
	 * <p>Later, when all the products have been retreived in the StoreScreen, we need
	 * to extract the id of the offer that will match the one set in the database. For
	 * instance, "pyramid.1" will give us the offer id "1".</p>
	 * 
	 * <p>When all the ids have been extracted, we send them to our server to retreive
	 * the number of credits that will be given to the player when he buy this offer.</p>
	 */	
	public class StoreScreen extends AdvancedScreen
	{
		/**
		 * Main container used to scroll the ads
		 * add the list within the same container. */		
		private var _container:ScrollContainer;
		/**
		 * The ad container. */		
		private var _adContainer:AdStoreContainer;
		/**
		 * The items list. */		
		private var _list:List;
		
		/**
		 * The store used to make purchases. */		
		private var _store:Store;
		
		private var _productsData:Vector.<StoreData>;
		
		/**
		 * The authentication container. */		
		private var _authenticationContainer:NotLoggedInContainer;
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		/**
		 * Whether th product details have been loaded. */		
		private var _areProductDetailsLoaded:Boolean = false;
		/**
		 * Temporary ids used to retreive the product details
		 * in the App Store. */		
		private var _temporaryProductsIds:Vector.<String>;
		
		public function StoreScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Acheter des crédits de jeu");
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayout.gap = scaleAndRoundToDpi(20);
			
			_container = new ScrollContainer();
			_container.layout = vlayout;
			_container.visible = false;
			addChild(_container);
			
			_adContainer = new AdStoreContainer();
			_container.addChild(_adContainer);
			
			const listLayout:TiledRowsLayout = new  TiledRowsLayout();
			listLayout.paging = TiledRowsLayout.PAGING_NONE;
			listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.useSquareTiles = false;
			listLayout.manageVisibility = true;
			
			_list = new List();
			_list.paddingBottom = scaleAndRoundToDpi(10);
			_list.layout = listLayout;
			_list.isSelectable = false;
			_list.snapToPages = false;
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.addEventListener(LudoEventType.PURCHASE_ITEM, onPurchaseItem);
			_list.itemRendererType = StoreItemRenderer;
			_container.addChild(_list);
			
			_authenticationContainer = new NotLoggedInContainer();
			_authenticationContainer.visible = false;
			addChild(_authenticationContainer);
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.visible = false;
			addChild(_retryContainer);
			
			_store = new Store();
			_store.addEventListener(LudoEventType.STORE_INITIALIZED, onStoreInitialized);
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_retryContainer.visible = true;
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					TweenMax.delayedCall(1, _store.initialize);
				}
				else
				{
					_retryContainer.loadingMode = false;
				}
			}
			else
			{
				_authenticationContainer.visible = true;
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_container.width = _authenticationContainer.width = _retryContainer.width = actualWidth;
				_container.height = _authenticationContainer.height = _retryContainer.height = actualHeight;
				
				if( _adContainer )
					_adContainer.width = actualWidth;
				
				_list.width = actualWidth * 0.9;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
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
		 * 
		 * <p>Use this code to test in the simulator :</p>
		 * 
		 * <pre>
		 * _loader.visible = false;
		 * _container.visible = true;
		 * 
		 * _productsData = new Vector.<StoreData>();
		 * _productsData.push( new StoreData( { store_id:1, nb_credit:999, nb_credit_promo:50, top_offre:1 } ) );
		 * _productsData.push( new StoreData( { store_id:1, nb_credit:999, nb_credit_promo:50, choix_joueur:1 } ) );
		 * _productsData.push( new StoreData( { store_id:1, nb_credit:999, nb_credit_promo:50 } ) );
		 * _productsData.push( new StoreData( { store_id:1, nb_credit:999, nb_credit_promo:50 } ) );
		 * _productsData.push( new StoreData( { store_id:1, nb_credit:999, nb_credit_promo:50 } ) );
		 * _productsData.push( new StoreData( { store_id:1, nb_credit:999, nb_credit_promo:50 } ) );
		 * 
		 * _list.dataProvider = new ListCollection( _productsData );
		 * _list.validate();
		 * var len:int = (_list.viewPort as ListDataViewPort).numChildren;
		 * var storeItemRenderer:StoreItemRenderer;
		 * for(var i:int = 0; i < len; i++)
		 * {
		 * 		storeItemRenderer = StoreItemRenderer( (_list.viewPort as ListDataViewPort).getChildAt(i) );
		 * 		_container.addEventListener(Event.SCROLL, storeItemRenderer.onScroll);
		 * }
		 * storeItemRenderer = null;
		 * </pre>
		 * 
		 */		
		private function onStoreInitialized():void
		{
			_store.removeEventListener(LudoEventType.STORE_INITIALIZED, onStoreInitialized);
			
			if( !_store.available )
			{
				// the store is not available, we need to inform the user
				_retryContainer.visible = true;
				_retryContainer.singleMessageMode = true;
				_retryContainer.loadingMode = false;
				_retryContainer.message = _("Impossible d'afficher le magasin car vous ne pouvez pas effectuer d'achats (contrôle parental ou autre raison).");
			}
			else
			{
				Remote.getInstance().getProductIds(onGetProductIdsSuccess, onGetProductIdsFailure, onGetProductIdsFailure, 2, advancedOwner.activeScreenID);
			}
		}
		
		/**
		 * The product ids have been successfully fetched from our server.
		 * Now we need to build the correct ids we will supply to Google
		 * or Apple in order to get the product details, such as currency.
		 */		
		private function onGetProductIdsSuccess(result:Object):void
		{
			// FIXME Gérer le cas où il n'y a pas d'offres (code 3)
			_areProductDetailsLoaded = true;
			
			if( _list.dataProvider )
				_list.dataProvider.removeAll();
			
			_productsData = new Vector.<StoreData>();
			var len:int = (result.offres as Array).length;
			var storeData:StoreData;
			_temporaryProductsIds = new Vector.<String>();
			for(var i:int = 0; i < len; i++)
			{
				storeData = new StoreData( result.offres[i] );
				_temporaryProductsIds.push( storeData.generatedId );
				_productsData.push( storeData );
			}
			storeData = null;
			
			if( result.hasOwnProperty("slider") && result.slider != null && (result.slider as Array).length > 0 )
			{
				// we need to caulculate the size of the ad container
				// originalWidth / actualWidth will give us the scale factor
				_adContainer.dataProvider = result.slider;
				_adContainer.height = Number(result.slider[0].imageHeight * (actualWidth / result.slider[0].imageWidth));
				//invalidate( INVALIDATION_FLAG_SIZE );
			}
			else
			{
				_adContainer.height = 0;
			}
			
			_store.addEventListener(LudoEventType.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.addEventListener(LudoEventType.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
			_store.requestProductDetails( _temporaryProductsIds );
		}
		
		/**
		 * There was an error requesting the products ids from our server. In
		 * this case we need to display an error to the user, inviting him
		 * to try again (later).
		 */		
		private function onGetProductIdsFailure(error:Object = null):void
		{
			_areProductDetailsLoaded = false;
			_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
			_retryContainer.loadingMode = false;
		}
		
		/**
		 * The product detailshave been loaded from Google or Apple. Now we need
		 * to update the products with the details we got, then populate the list
		 * data provider.
		 */		
		private function onProductsDetailsLoaded(event:Event):void
		{
			_store.removeEventListener(LudoEventType.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.removeEventListener(LudoEventType.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
			_store.addEventListener(LudoEventType.STORE_PURCHASE_SUCCESS, onPurchaseSuccess);
			_store.addEventListener(LudoEventType.STORE_PURCHASE_CANCELLED, onPurchaseCancelled);
			_store.addEventListener(LudoEventType.STORE_PURCHASE_FAILURE, onPurchaseFailure);
			
			if( event.data )
			{
				var storeData:StoreData;
				
				if( GlobalConfig.ios )
				{
					// parse ios specific data
					
					for each(var storeKitProduct:StoreKitProduct in event.data)
					{
						for each(storeData in _productsData)
						{
							if( storeData.generatedId == storeKitProduct.productId )
								storeData.parseIosData(storeKitProduct);
						}
					}
					
				}
				else if( GlobalConfig.android )
				{
					// parse android specific data
					
					if( GlobalConfig.amazon )
					{
						for each(var amazonItemDetails:AmazonItemData in event.data)
						{
							for each(storeData in _productsData)
							{
								if( storeData.generatedId == amazonItemDetails.sku )
									storeData.parseAmazonData(amazonItemDetails);
							}
						}
					}
					else
					{
						for each(var androidItemDetails:AndroidItemDetails in event.data)
						{
							for each(storeData in _productsData)
							{
								if( storeData.generatedId == androidItemDetails.itemId )
									storeData.parseAndroidData(androidItemDetails);
							}
						}
					}
				}
				
				// the list is ready to be displayed
				
				_retryContainer.visible = false;
				_container.visible = true;
				
				_list.dataProvider = new ListCollection( _productsData );
				_list.validate();
				var len:int = (_list.viewPort as ListDataViewPort).numChildren;
				var storeItemRenderer:StoreItemRenderer;
				for(var i:int = 0; i < len; i++)
				{
					storeItemRenderer = StoreItemRenderer( (_list.viewPort as ListDataViewPort).getChildAt(i) );
					_container.addEventListener(Event.SCROLL, storeItemRenderer.onScroll);
				}
				storeItemRenderer = null;
			}
			else
			{
				// no product details loaded : something is wrong
				_retryContainer.visible = true;
				_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
				_retryContainer.loadingMode = false;
			}
		}
		
		private function onProductsDetailsNotLoaded(event:Event):void
		{
			// no product details loaded : something is wrong
			_store.removeEventListener(LudoEventType.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.removeEventListener(LudoEventType.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
			
			_retryContainer.visible = true;
			_retryContainer.message = String(event.data);
			_retryContainer.loadingMode = false;
		}
		
		/**
		 * When the player wants to buy a pack, we need to create first a request on the
		 * server side, for statistic purpose. Then when the creation is done, we launch
		 * the native window which allows the user to make a purchase.
		 */		
		private function onPurchaseItem(event:Event):void
		{
			_canBack = false;
			_store.requestPurchase( StoreData(event.data) );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Retry
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * If an error occurred while retreiving the product details or if the
		 * user was not connected when this componenent was created, we need to
		 * show a retry button so that he doesn't need to leave and come back to
		 * the view to load the data.
		 */		
		private function onRetry(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				if( !_store.isInitialized )
				{
					_store.initialize();
				}
				else if( !_areProductDetailsLoaded )
				{
					Remote.getInstance().getProductIds(onGetProductIdsSuccess, onGetProductIdsFailure, onGetProductIdsFailure, 2, advancedOwner.activeScreenID);
				}
				else
				{
					_store.addEventListener(LudoEventType.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
					_store.addEventListener(LudoEventType.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
					_store.requestProductDetails(_temporaryProductsIds);
				}
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * Purchase success.
		 */		
		private function onPurchaseSuccess(event:Event):void
		{
			if( Analytics.isSupported() && AbstractEntryPoint.tracker )
				AbstractEntryPoint.tracker.buildEvent("Achat Intégré", "Validé").withLabel(event.data.id).withValue( int(event.data.value) ).track();
			
			try
			{
				MobileAppTracker.instance.trackAction("purchase", event.data.value, "USD", event.data.id);
			} 
			catch(error:Error) 
			{
				
			}
			
			if( Boolean(event.data.newRank) == false )
				Remote.getInstance().getProductIds(onOffersRefreshed, null, null, 1, advancedOwner.activeScreenID);
			InfoManager.hide("", InfoContent.ICON_NOTHING, 4, onAlertClosed, [ event.data.value, event.data.newRank ], new StoreSuccessAnimationComponenent(event.data.txt) );
		}
		
		/**
		 * The animation was closed (manually or automatically), then we
		 * re-enable the navigation or we display the specific screen if
		 * the used changed rank with this purchase.
		 * 
		 * @param value Number of credits earned.
		 * @param newRank Whether the user changed rank with this purchase
		 * 
		 */		
		private function onAlertClosed(value:int, newRank:Boolean):void
		{
			// FIXME Utiliser useFrames pour TweenMax partout dans l'application ?
			advancedOwner.dispatchEventWith(LudoEventType.ANIMATE_SUMMARY, false, { type:GameSession.PRICE_CREDIT, value:value } );
			
			if( newRank == true )
			{
				TweenMax.delayedCall(1.25, advancedOwner.showScreen, [ScreenIds.VIP_UP_SCREEN]);
			}
			else
			{
				_canBack = true;
			}
		}
		
		/**
		 * 
		 */		
		private function onOffersRefreshed(result:Object):void
		{
			if( _list && _list.dataProvider )
			{
				var lenOffers:int = (result.offres as Array).length;
				var lenList:int = _list.dataProvider.length;
				var offer:Object;
				for(var i:int = 0; i < lenOffers; i++)
				{
					offer = result.offres[i];
					// parcours de la liste des offres
					for(var j:int = 0; j < lenList; j++)
					{
						// par sécurité, on recherche la bonne offre dans la liste
						if( StoreData(_list.dataProvider.getItemAt(j)).id == int(offer.store_id) )
						{
							// we found it
							StoreData(_list.dataProvider.getItemAt(j)).update(offer);
							_list.dataProvider.updateItemAt(j);
							break;
						}
					}
				}
			}
			
			if( result.hasOwnProperty("slider") && result.slider != null && (result.slider as Array).length > 0 )
			{
				// we need to caulculate the size of the ad container
				// originalWidth / actualWidth will give us the scale factor
				_adContainer.dataProvider = result.slider;
				_adContainer.height = Number(result.slider[0].imageHeight * (actualWidth / result.slider[0].imageWidth));
			}
			else
			{
				_adContainer.height = 0;
			}
		}
		
		/**
		 * Purchase failed.
		 */		
		private function onPurchaseFailure(event:Event):void
		{
			_canBack = true;
		}
		
		/**
		 * Purchase cancelled.
		 */		
		private function onPurchaseCancelled(event:Event):void
		{
			_canBack = true;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_authenticationContainer.removeFromParent(true);
			_authenticationContainer = null;
			
			_retryContainer.removeEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.removeFromParent(true);
			_retryContainer = null;
			
			if( _adContainer )
			{
				_adContainer.removeFromParent(true);
				_adContainer = null;
			}
			
			var len:int = (_list.viewPort as ListDataViewPort).numChildren;
			var storeItemRenderer:StoreItemRenderer;
			for(var i:int = 0; i < len; i++)
			{
				storeItemRenderer = StoreItemRenderer( (_list.viewPort as ListDataViewPort).getChildAt(i) );
				_container.removeEventListener(Event.SCROLL, storeItemRenderer.onScroll);
			}
			storeItemRenderer = null;
			_list.removeEventListener(LudoEventType.PURCHASE_ITEM, onPurchaseItem);
			_list.removeFromParent(true);
			_list = null;
			
			_container.removeFromParent(true);
			_container = null;
			
			if( _temporaryProductsIds != null ) 
			{
				_temporaryProductsIds.length = 0;
				_temporaryProductsIds = null;
			}
			
			_store.removeEventListener(LudoEventType.STORE_PURCHASE_CANCELLED, onPurchaseCancelled);
			_store.removeEventListener(LudoEventType.STORE_PURCHASE_FAILURE, onPurchaseFailure);
			_store.removeEventListener(LudoEventType.STORE_PURCHASE_SUCCESS, onPurchaseSuccess);
			_store.removeEventListener(LudoEventType.STORE_INITIALIZED, onStoreInitialized);
			_store.removeEventListener(LudoEventType.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.removeEventListener(LudoEventType.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
			_store.dispose();
			_store = null;
			
			super.dispose();
		}
		
	}
}