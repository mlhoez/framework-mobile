/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 22 août 2013
*/
package com.ludofactory.mobile.navigation.shop.vip
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
import com.ludofactory.mobile.core.manager.MemberManager;
import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
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
			
			_message = new Label();
			_message.text = _("Echangez vos Points contre\nles cadeaux de vos rêves !"); // pas besoin de remplacer la notion de cadeaux car cet écran est passé si on est un joueur non-cadeau
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
                if( MemberManager.getInstance().getGiftsEnabled() )
                {
                    _retryContainer.visible = true;
                    Remote.getInstance().getBoutiqueCategories(onGetCategoriesSuccess, onGetCategoriesFailure, onGetCategoriesFailure, 2, advancedOwner.activeScreenID);
                }
                else
                {
                    this.advancedOwner.screenData.idCategory = 28;
                    this.advancedOwner.screenData.categoryName = _("Ludokado");
                    this.advancedOwner.showScreen( ScreenIds.BOUTIQUE_SUB_CATEGORY_LISTING );
                }
			}
			else
			{
				// default category
				_retryContainer.visible = false;
				NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, onActivate, false, 0, true);
                if( MemberManager.getInstance().getGiftsEnabled() )
                {
                    _list.dataProvider = new ListCollection(
                            [
                                new BoutiqueCategoryData( 26, _("Maison"), "BoutiqueHouseIcon" ),
                                new BoutiqueCategoryData( 23, _("Loisirs"), "BoutiqueLeisureIcon" ),
                                new BoutiqueCategoryData( 24, _("Pour Elle"), "BoutiqueForHerIcon" ),
                                new BoutiqueCategoryData( 8,  _("Vidéo"),  "BoutiqueVideoIcon" ),
                                new BoutiqueCategoryData( 27, _("Jeux Vidéo"), "BoutiqueVideoGamesIcon" ),
                                new BoutiqueCategoryData( 25, _("Image et Son"), "BoutiqueImageAndSoundIcon" ),
                                new BoutiqueCategoryData( 28, _("Ludokado"), "BoutiqueLudokadoIcon" )
                            ]);
                }
                else
                {
                    _list.dataProvider = new ListCollection(
                            [
                                new BoutiqueCategoryData( 28, _("Ludokado"), "BoutiqueLudokadoIcon" )
                            ]);
                }

			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_message.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 5 : 10) : (AbstractGameInfo.LANDSCAPE ? 15 : 30));
				_message.width = actualWidth * 0.9;
				_message.x = (actualWidth - _message.width) * 0.5;
				_message.validate();
				
				_listShadow.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 10 : 20) : (AbstractGameInfo.LANDSCAPE ? 20 : 40));
				_listShadow.width = actualWidth;
				
				_list.y = _retryContainer.y = _listShadow.y + _listShadow.height;
				_list.width = actualWidth;
				_list.height = actualHeight - _listShadow.y - _listShadow.height;
				
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
			_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
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
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
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
				InfoManager.showTimed(_("Vous devez être connecté à Internet pour afficher les lots."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * If the shop is not available, we need to redirect the user to
		 * the onine shop of Ludokado / Copyright © 2006-2015 Ludo Factory.
		 */		
		private function onGoOnlineShop(event:starling.events.Event):void
		{
			navigateToURL(new URLRequest(_("http://www.ludokado.com/")));
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