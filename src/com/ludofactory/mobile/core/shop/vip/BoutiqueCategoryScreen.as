/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 22 août 2013
*/
package com.ludofactory.mobile.core.shop.vip
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.data.ListCollection;
	import feathers.display.TiledImage;
	import feathers.layout.TiledRowsLayout;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	/**
	 * Boutique main category listing
	 */	
	public class BoutiqueCategoryScreen extends AdvancedScreen
	{
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		/**
		 * Message */		
		private var _message:Label;
		/**
		 * List */		
		private var _list:List;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		private var _connectedContentInitialized:Boolean = false
		
		public function BoutiqueCategoryScreen()
		{
			super();
			
			_fullScreen = false;
			_appClearBackground = false;
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_SHOP_ENABLED) == true )
			{
				_message = new Label();
				_message.text = Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.TITLE");
				addChild(_message);
				_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
				
				_listShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
				_listShadow.setVertexColor(0, 0xffffff);
				_listShadow.setVertexAlpha(0, 0);
				_listShadow.setVertexColor(1, 0xffffff);
				_listShadow.setVertexAlpha(1, 0);
				_listShadow.setVertexAlpha(2, 0.1);
				_listShadow.setVertexAlpha(3, 0.1);
				addChild(_listShadow);
				
				const listLayout:TiledRowsLayout = new  TiledRowsLayout();
				listLayout.paging = TiledRowsLayout.PAGING_HORIZONTAL;
				listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
				listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
				listLayout.useSquareTiles = false;
				listLayout.manageVisibility = true;
				
				_list = new List();
				_list.backgroundSkin = new TiledImage(AbstractEntryPoint.assets.getTexture("MenuTile"), GlobalConfig.dpiScale);
				_list.isSelectable = false;
				_list.layout = listLayout;
				_list.snapToPages = false;
				_list.itemRendererType = BoutiqueCategoryItemRenderer;
				_list.addEventListener(LudoEventType.BOUTIQUE_CATEGORY_TOUCHED, onCategorySelected);
				addChild(_list);
				
				_retryContainer = new RetryContainer();
				_retryContainer.addEventListener(starling.events.Event.TRIGGERED, onRetry);
				_retryContainer.visible = false;
				addChild(_retryContainer);
				
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_retryContainer.visible = true;
					Remote.getInstance().getBoutiqueCategories(onGetCategoriesSuccess, onGetCategoriesFailure, onGetCategoriesFailure, 2, advancedOwner.activeScreenID);
				}
				else
				{
					// default category
					_retryContainer.visible = false;
					NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, onActivate, false, 0, true);
					_list.dataProvider = new ListCollection(
						[
							new BoutiqueCategoryData( 26, Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.26"), "BoutiqueHouseIcon" ),
							new BoutiqueCategoryData( 23, Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.23"), "BoutiqueLeisureIcon" ),
							new BoutiqueCategoryData( 24, Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.24"), "BoutiqueForHerIcon" ),
							new BoutiqueCategoryData( 8,  Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.8"),  "BoutiqueVideoIcon" ),
							new BoutiqueCategoryData( 27, Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.27"), "BoutiqueVideoGamesIcon" ),
							new BoutiqueCategoryData( 25, Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.25"), "BoutiqueImageAndSoundIcon" ),
							new BoutiqueCategoryData( 28, Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.28"), "BoutiqueLudokadoIcon" )
						]);
				}
			}
			else
			{
				_retryContainer = new RetryContainer();
				_retryContainer.addEventListener(starling.events.Event.TRIGGERED, onGoOnlineShop);
				_retryContainer.loadingMode = false;
				addChild(_retryContainer);
				_retryContainer.message = Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.DISABLED_MESSAGE");
				_retryContainer.retryButtonMessage = Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.DISABLED_BUTTON_MESSAGE");
			}
			
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_SHOP_ENABLED) == true )
				{
					_message.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 30);
					_message.width = actualWidth * 0.9;
					_message.x = (actualWidth - _message.width) * 0.5;
					_message.validate();
					
					
					_listShadow.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
					_listShadow.width = actualWidth;
					
					_list.y = _retryContainer.y = _listShadow.y + _listShadow.height;
					_list.width = actualWidth;
					_list.height = actualHeight - _listShadow.y - _listShadow.height;
				}
				
				_retryContainer.width = actualWidth;
				_retryContainer.height = actualHeight - (_list ? _list.y:0);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onActivate(event:flash.events.Event):void
		{
			if( !_connectedContentInitialized && AirNetworkInfo.networkInfo.isConnected() )
			{
				_list.dataProvider.removeAll();
				_retryContainer.visible = true;
				Remote.getInstance().getBoutiqueCategories(onGetCategoriesSuccess, onGetCategoriesFailure, onGetCategoriesFailure, 2, advancedOwner.activeScreenID);
			}
		}
		
		private function onGetCategoriesSuccess(result:Object):void
		{
			_connectedContentInitialized = true;
			_retryContainer.visible = false;
			
			var dataProvider:Array = [];
			for each(var categoryData:Object in result.tab_categorie)
				dataProvider.push( new BoutiqueCategoryData( categoryData.id, categoryData.nom, categoryData.image ) );
			_list.dataProvider = new ListCollection( dataProvider );
		}
		
		private function onGetCategoriesFailure(error:Object = null):void
		{
			_retryContainer.message = Localizer.getInstance().translate("COMMON.QUERY_FAILURE");
			_retryContainer.loadingMode = false;
		}
		
		/**
		 * If an error occurred while retreiving the account activity history
		 * or if the user was not connected when this componenent was created,
		 * we need to show a retry button so that he doesn't need to leave and
		 * come back to the view to load the messages.
		 */		
		private function onRetry(event:starling.events.Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getBoutiqueCategories(onGetCategoriesSuccess, onGetCategoriesFailure, onGetCategoriesFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * A category was touched.
		 */		
		private function onCategorySelected(event:starling.events.Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected())
			{
				if( _connectedContentInitialized )
				{
					this.advancedOwner.screenData.idCategory = BoutiqueCategoryData(event.data).id;
					this.advancedOwner.screenData.categoryName = BoutiqueCategoryData(event.data).title;
					this.advancedOwner.showScreen( ScreenIds.BOUTIQUE_SUB_CATEGORY_LISTING );
				}
				else
				{
					_list.dataProvider.removeAll();
					
					_retryContainer.visible = true;
					_retryContainer.loadingMode = true;
					Remote.getInstance().getBoutiqueCategories(onGetCategoriesSuccess, onGetCategoriesFailure, onGetCategoriesFailure, 2, advancedOwner.activeScreenID);
				}
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.NOT_CONNECTED_ERROR"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * If the shop is not available, we need to redirect the user to
		 * the onine shop of Ludokado / LudoFactory.
		 */		
		private function onGoOnlineShop(event:starling.events.Event):void
		{
			navigateToURL(new URLRequest(Localizer.getInstance().translate("BOUTIQUE_CATEGORY_LIST_SCREEN.DISABLED_LINK")));
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			NativeApplication.nativeApplication.removeEventListener(flash.events.Event.ACTIVATE, onActivate);
			
			if( _listShadow )
			{
				_listShadow.removeFromParent(true);
				_listShadow = null;
			}
			
			if( _message )
			{
				_message.removeFromParent(true);
				_message = null;
			}
			
			if( _list )
			{
				_list.removeEventListener(LudoEventType.BOUTIQUE_CATEGORY_TOUCHED, onCategorySelected);
				_list.removeFromParent(true);
				_list = null;
			}
			
			_retryContainer.removeEventListener(starling.events.Event.TRIGGERED, onRetry);
			_retryContainer.removeEventListener(starling.events.Event.TRIGGERED, onGoOnlineShop);
			_retryContainer.removeFromParent(true);
			_retryContainer = null;
			
			super.dispose();
		}
	}
}