/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.core.notification.content
{
	
	import com.amazon.nativeextensions.android.AmazonItemData;
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.model.StakeType;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.promo.PromoContent;
	import com.ludofactory.mobile.core.promo.PromoManager;
	import com.ludofactory.mobile.core.purchases.Store;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	import com.ludofactory.mobile.navigation.store.StoreData;
	import com.ludofactory.mobile.navigation.store.StoreItemRenderer;
	import com.ludofactory.mobile.navigation.store.StoreSuccessAnimationComponenent;
	import com.milkmangames.nativeextensions.GAnalytics;
	import com.milkmangames.nativeextensions.android.AndroidItemDetails;
	import com.milkmangames.nativeextensions.ios.StoreKitProduct;
	
	import feathers.controls.List;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.data.ListCollection;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	public class CreditsNotificationContent extends AbstractPopupContent
	{
		private static const POPUP_NAME_FOR_RESPONDERS:String = "credits-popup";
		
		/**
		 * The title. */		
		private var _notificationTitle:TextField;
		
		/**
		 * Main container used to scroll the ads add the list within the same container. */
		private var _container:ScrollContainer;
		/**
		 * The items list. */
		private var _list:List;
		
		/**
		 * The store used to make purchases. */
		private var _store:Store;
		
		private var _productsData:Vector.<StoreData>;
		
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
		
		/**
		 * The promo content displayed when there is a promo. */
		private var _promoContent:PromoContent;
		
		/**
		 * If we need to resize the notification */
		private var _needResize:Boolean = false;
		
		public function CreditsNotificationContent()
		{
			super();
			
			// track screens with Google Analytics
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackScreenView(ScreenIds.POPUP_IAP, MemberManager.getInstance().id);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			data = false;
			
			_notificationTitle = new TextField(5, 5, _("Boutique de Crédits"), Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 34 : 44), Theme.COLOR_DARK_GREY);
			_notificationTitle.autoSize = TextFieldAutoSize.VERTICAL;
			addChild(_notificationTitle);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayout.gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 25);
			vlayout.paddingTop = GlobalConfig.isPhone ? scaleAndRoundToDpi(30) : scaleAndRoundToDpi(60);
			
			_container = new ScrollContainer();
			_container.layout = vlayout;
			_container.visible = false;
			addChild(_container);
			
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
			_list.addEventListener(MobileEventTypes.PURCHASE_ITEM, onPurchaseItem);
			_list.itemRendererType = StoreItemRenderer;
			_container.addChild(_list);
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.visible = false;
			addChild(_retryContainer);
			
			_store = new Store();
			_store.addEventListener(MobileEventTypes.STORE_INITIALIZED, onStoreInitialized);
			
			// les commentaires permettent d'autoriser un joueur non connecté à effectuer des achats
			// cf le rejet d'Apple pour Zeven
			/*if( MemberManager.getInstance().isLoggedIn() )
			 {*/
			_retryContainer.visible = true;
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_store.initialize();
			}
			else
			{
				_retryContainer.loadingMode = false;
			}
			/*}
			 else
			 {
			 _authenticationContainer.visible = true;
			 }*/
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = this.actualWidth;
			if( AbstractGameInfo.LANDSCAPE )
			{
				_list.validate();
				_container.width = _retryContainer.width = actualWidth;
				_retryContainer.y = _notificationTitle.y + _notificationTitle.height + scaleAndRoundToDpi(30);
				_container.y = _notificationTitle.y + _notificationTitle.height + scaleAndRoundToDpi(5);
				
				//_container.height = _retryContainer.height = actualHeight;
				
				_list.width = actualWidth * 0.9;
				
				//paddingTop = paddingBottom = scaleAndRoundToDpi(10);
			}
			else
			{
				_notificationTitle.y = scaleAndRoundToDpi(5);
				
				paddingBottom = scaleAndRoundToDpi(10);
			}
			
			super.draw();
			
			if( _needResize )
			{
				_needResize = false;
				NotificationPopupManager.adjustCurrentNotification();
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
			_store.removeEventListener(MobileEventTypes.STORE_INITIALIZED, onStoreInitialized);
			
			if( !_store.available )
			{
				// the store is not available, we need to inform the user
				_retryContainer.visible = true;
				_retryContainer.singleMessageMode = true;
				_retryContainer.loadingMode = false;
				_retryContainer.message = _("Impossible d'afficher le magasin car vous ne pouvez pas effectuer d'achats (contrôle parental ou autre raison).");
				
				if(CONFIG::DEBUG == true)
				{
					_retryContainer.visible = false;
					_container.visible = true;
					
					if(PromoManager.getInstance().isPromoPending)
					{
						_promoContent = PromoManager.getInstance().getPromoContent(false);
						_container.addChildAt(_promoContent, 0);
						_promoContent.animate();
					}
					
					_productsData = new Vector.<StoreData>();
					_productsData.push( new StoreData( { store_id:1, nb_credit:3,   nb_credit_promo:1 } ) );
					_productsData.push( new StoreData( { store_id:2, nb_credit:12,  nb_credit_promo:2, choix_joueur:1 } ) );
					_productsData.push( new StoreData( { store_id:3, nb_credit:32,  nb_credit_promo:6 } ) );
					_productsData.push( new StoreData( { store_id:4, nb_credit:64,  nb_credit_promo:12, top_offre:1} ) );
					_productsData.push( new StoreData( { store_id:5, nb_credit:126, nb_credit_promo:25 } ) );
					_productsData.push( new StoreData( { store_id:6, nb_credit:255, nb_credit_promo:51 } ) );
					
					_list.dataProvider = new ListCollection( _productsData );
					_list.width = GlobalConfig.stageWidth * 0.9;
					_list.validate();
					var len:int = (_list.viewPort as ListDataViewPort).numChildren;
					var storeItemRenderer:StoreItemRenderer;
					for(var i:int = 0; i < len; i++)
					{
						storeItemRenderer = StoreItemRenderer( (_list.viewPort as ListDataViewPort).getChildAt(i) );
						this.addEventListener(Event.SCROLL, storeItemRenderer.onScroll);
					}
					storeItemRenderer = null;
					
					invalidate();
				}
			}
			else
			{
				Remote.getInstance().getProductIds(onGetProductIdsSuccess, onGetProductIdsFailure, onGetProductIdsFailure, 2, POPUP_NAME_FOR_RESPONDERS);
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
			
			_store.addEventListener(MobileEventTypes.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.addEventListener(MobileEventTypes.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
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
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
			_store.addEventListener(MobileEventTypes.STORE_PURCHASE_SUCCESS, onPurchaseSuccess);
			_store.addEventListener(MobileEventTypes.STORE_PURCHASE_CANCELLED, onPurchaseCancelled);
			_store.addEventListener(MobileEventTypes.STORE_PURCHASE_FAILURE, onPurchaseFailure);
			
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
				
				if(PromoManager.getInstance().isPromoPending)
				{
					_promoContent = PromoManager.getInstance().getPromoContent(false);
					_container.addChildAt(_promoContent, 0);
					_promoContent.animate();
				}
				
				_list.dataProvider = new ListCollection( _productsData );
				_list.validate();
				var len:int = (_list.viewPort as ListDataViewPort).numChildren;
				var storeItemRenderer:StoreItemRenderer;
				for(var i:int = 0; i < len; i++)
				{
					storeItemRenderer = StoreItemRenderer( (_list.viewPort as ListDataViewPort).getChildAt(i) );
					this.addEventListener(Event.SCROLL, storeItemRenderer.onScroll);
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
			
			_needResize = true;
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		private function onProductsDetailsNotLoaded(event:Event):void
		{
			// no product details loaded : something is wrong
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
			
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
			AdvancedScreen(AbstractEntryPoint.screenNavigator.activeScreen).canBack = false;
			_store.requestPurchase( StoreData(event.data) );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Retry
		
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
					Remote.getInstance().getProductIds(onGetProductIdsSuccess, onGetProductIdsFailure, onGetProductIdsFailure, 2, POPUP_NAME_FOR_RESPONDERS);
				}
				else
				{
					_store.addEventListener(MobileEventTypes.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
					_store.addEventListener(MobileEventTypes.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
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
			try
			{
				//MobileAppTracker.instance.trackAction("purchase", event.data.value, "USD", event.data.id);
			}
			catch(error:Error)
			{
				
			}
			
			if( Boolean(event.data.newRank) == false )
				Remote.getInstance().getProductIds(onOffersRefreshed, null, null, 1, POPUP_NAME_FOR_RESPONDERS);
			InfoManager.hide("", InfoContent.ICON_NOTHING, 4, onAlertClosed, [ event.data.value, event.data.newRank ], new StoreSuccessAnimationComponenent(event.data.txt) );
		}
		
		/**
		 * The animation was closed (manually or automatically), then we re-enable the navigation or we display the
		 * specific screen if the used changed rank with this purchase.
		 *
		 * @param value Number of credits earned.
		 * @param newRank Whether the user changed rank with this purchase
		 *
		 */
		private function onAlertClosed(value:int, newRank:Boolean):void
		{
			// FIXME Utiliser useFrames pour TweenMax partout dans l'application ?
			AbstractEntryPoint.screenNavigator.dispatchEventWith(MobileEventTypes.ANIMATE_FOOTER, false, { type:StakeType.CREDIT, value:value } );
			
			if( newRank == true )
			{
				TweenMax.delayedCall(1.25, AbstractEntryPoint.screenNavigator.showScreen, [ScreenIds.VIP_UP_SCREEN]);
			}
			else
			{
				AdvancedScreen(AbstractEntryPoint.screenNavigator.activeScreen).canBack = true;
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
		}
		
		/**
		 * Purchase failed.
		 */
		private function onPurchaseFailure(event:Event):void
		{
			AdvancedScreen(AbstractEntryPoint.screenNavigator.activeScreen).canBack = true;
		}
		
		/**
		 * Purchase cancelled.
		 */
		private function onPurchaseCancelled(event:Event):void
		{
			AdvancedScreen(AbstractEntryPoint.screenNavigator.activeScreen).canBack = true;
		}
		
		override protected function close():void
		{
			Remote.getInstance().clearAllRespondersOfScreen(POPUP_NAME_FOR_RESPONDERS);
			super.close();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_retryContainer.removeEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.removeFromParent(true);
			_retryContainer = null;
			
			var len:int = (_list.viewPort as ListDataViewPort).numChildren;
			var storeItemRenderer:StoreItemRenderer;
			for(var i:int = 0; i < len; i++)
			{
				storeItemRenderer = StoreItemRenderer( (_list.viewPort as ListDataViewPort).getChildAt(i) );
				this.removeEventListener(Event.SCROLL, storeItemRenderer.onScroll);
			}
			storeItemRenderer = null;
			_list.removeEventListener(MobileEventTypes.PURCHASE_ITEM, onPurchaseItem);
			_list.removeFromParent(true);
			_list = null;
			
			if(_promoContent)
			{
				PromoManager.getInstance().removePromo(_promoContent);
				_promoContent.removeFromParent(true);
			}
			_promoContent = null;
			
			_container.removeFromParent(true);
			_container = null;
			
			if( _temporaryProductsIds != null )
			{
				_temporaryProductsIds.length = 0;
				_temporaryProductsIds = null;
			}
			
			TweenMax.killDelayedCallsTo(_store.initialize);
			_store.removeEventListener(MobileEventTypes.STORE_PURCHASE_CANCELLED, onPurchaseCancelled);
			_store.removeEventListener(MobileEventTypes.STORE_PURCHASE_FAILURE, onPurchaseFailure);
			_store.removeEventListener(MobileEventTypes.STORE_PURCHASE_SUCCESS, onPurchaseSuccess);
			_store.removeEventListener(MobileEventTypes.STORE_INITIALIZED, onStoreInitialized);
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_LOADED, onProductsDetailsLoaded);
			_store.removeEventListener(MobileEventTypes.STORE_PRODUCTS_NOT_LOADED, onProductsDetailsNotLoaded);
			_store.dispose();
			_store = null;
			
			super.dispose();
		}
	}
}