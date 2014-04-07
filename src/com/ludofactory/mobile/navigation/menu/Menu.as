/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.navigation.menu
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.AuthenticationManager;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreenNavigator;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.notification.NotificationManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	import feathers.controls.List;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.display.TiledImage;
	import feathers.layout.TiledRowsLayout;
	
	import starling.events.Event;
	
	public class Menu extends FeathersControl
	{
		/**
		 * The tiled background */		
		private var _tiledBackground:TiledImage;
		
		/**
		 * The menu list */		
		private var _list:List;
		
		/**
		 * The screen navigator */		
		private var _screenNavigator:AdvancedScreenNavigator;
		
		private var _showHomeOnClose:Boolean;
		
		public function Menu(screenNavigator:AdvancedScreenNavigator, showHomeOnClose:Boolean)
		{
			super();
			
			_screenNavigator = screenNavigator;
			_showHomeOnClose = showHomeOnClose;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// FIXME Checker la tailel de la tile, et essayer de l'agrandir pour les perfs ? (voir utiliser autre chose)
			
			_tiledBackground = new TiledImage(AbstractEntryPoint.assets.getTexture("MenuTile"), GlobalConfig.dpiScale);
			_tiledBackground.touchable = false;
			addChild(_tiledBackground);
			
			const listLayout:TiledRowsLayout = new  TiledRowsLayout();
			listLayout.paging = TiledRowsLayout.PAGING_NONE;
			//listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			//listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.useSquareTiles = false;
			listLayout.manageVisibility = true;
			
			_list = new List();
			_list.layout = listLayout;
			_list.isSelectable = false;
			_list.itemRendererType = MenuItemRenderer;
			_list.addEventListener(LudoEventType.MENU_ICON_TOUCHED, onMenuIconTouched);
			_list.dataProvider = new ListCollection(
				[
					new MenuItemData( "menu-icon-my-account",    "MENU.MY_ACCOUNT",       ScreenIds.MY_ACCOUNT_SCREEN ),
					new MenuItemData( "menu-icon-parrainage",    "MENU.SPONSORING",       ScreenIds.SPONSOR_HOME_SCREEN, AbstractEntryPoint.alertData.numSponsorAlerts ),
					new MenuItemData( "menu-icon-help", 		 "MENU.HELP", 			  ScreenIds.HELP_HOME_SCREEN, AbstractEntryPoint.alertData.numCustomerServiceAlerts + AbstractEntryPoint.alertData.numCustomerServiceImportantAlerts ),
					new MenuItemData( "menu-icon-credit",        "MENU.CREDITS",          ScreenIds.STORE_SCREEN ),
					new MenuItemData( "menu-icon-store",         "MENU.STORE",            ScreenIds.BOUTIQUE_HOME ),
					new MenuItemData( "menu-icon-vip",           "MENU.VIP",              ScreenIds.VIP_SCREEN ),
					new MenuItemData( "menu-icon-my-gifts",      "MENU.MY_GAINS",         ScreenIds.MY_GIFTS_SCREEN, AbstractEntryPoint.alertData.numGainAlerts ),
					new MenuItemData( "menu-icon-highscore",     "MENU.HIGHSCORE",        ScreenIds.HIGH_SCORE_HOME_SCREEN ),
					new MenuItemData( "menu-icon-trophy",        "MENU.CUP",              ScreenIds.TROPHY_SCREEN, AbstractEntryPoint.alertData.numTrophiesAlerts ),
					new MenuItemData( "menu-icon-tournaments",   "MENU.TOURNAMENT",       ScreenIds.PREVIOUS_TOURNAMENTS_SCREEN ),
					new MenuItemData( "menu-icon-settings",      "MENU.SETTINGS",         ScreenIds.SETTINGS_SCREEN ),
					new MenuItemData( MemberManager.getInstance().isLoggedIn() ? "menu-icon-log-out" : "menu-icon-log-in",   MemberManager.getInstance().isLoggedIn() ? "MENU.LOG_OUT":"MENU.LOG_IN",          ScreenIds.LOG_IN_OUT )
				]);
			addChild(_list);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_tiledBackground.width = _list.width = this.actualWidth;
			_tiledBackground.height = _list.height = this.actualHeight;
			
			//flatten();
		}
		
		/**
		 * Updates the content after a log in / out or when the
		 * langugae is changed.
		 */		
		public function updateContent():void
		{
			var tempMenuItemData:MenuItemData;
			var i:int = 0;
			
			// My Account
			_list.dataProvider.updateItemAt(i);
			
			// Sponsoring
			i++;
			tempMenuItemData = _list.dataProvider.getItemAt(i) as MenuItemData;
			tempMenuItemData.badgeNumber = AbstractEntryPoint.alertData.numSponsorAlerts;
			_list.dataProvider.setItemAt(tempMenuItemData, i);
			_list.dataProvider.updateItemAt(i);
			
			// Help
			i++;
			tempMenuItemData = _list.dataProvider.getItemAt(i) as MenuItemData;
			tempMenuItemData.badgeNumber = AbstractEntryPoint.alertData.numCustomerServiceAlerts + AbstractEntryPoint.alertData.numCustomerServiceImportantAlerts;
			_list.dataProvider.setItemAt(tempMenuItemData, i);
			_list.dataProvider.updateItemAt(i);
			
			// Credit
			i++;
			_list.dataProvider.updateItemAt(i);
			
			// Store
			i++;
			_list.dataProvider.updateItemAt(i);
			
			// Vip
			i++;
			_list.dataProvider.updateItemAt(i);
			
			// My Gifts
			i++;
			tempMenuItemData = _list.dataProvider.getItemAt(i) as MenuItemData;
			tempMenuItemData.badgeNumber = AbstractEntryPoint.alertData.numGainAlerts;
			_list.dataProvider.setItemAt(tempMenuItemData, i);
			_list.dataProvider.updateItemAt(i);
			
			// High Scores
			i++;
			_list.dataProvider.updateItemAt(i);
			
			// Trophies
			i++;
			tempMenuItemData = _list.dataProvider.getItemAt(i) as MenuItemData;
			tempMenuItemData.badgeNumber = AbstractEntryPoint.alertData.numTrophiesAlerts;
			_list.dataProvider.setItemAt(tempMenuItemData, i);
			_list.dataProvider.updateItemAt(i);
			
			// Tournament
			i++;
			_list.dataProvider.updateItemAt(i);
			
			// Settings
			i++;
			_list.dataProvider.updateItemAt(i);
			
			// Log in / out
			i++;
			tempMenuItemData = _list.dataProvider.getItemAt(i) as MenuItemData;
			tempMenuItemData.textureName = MemberManager.getInstance().isLoggedIn() ? "menu-icon-log-out" : "menu-icon-log-in";
			tempMenuItemData.title = MemberManager.getInstance().isLoggedIn() ? "MENU.LOG_OUT":"MENU.LOG_IN";
			_list.dataProvider.setItemAt(tempMenuItemData, i);
			_list.dataProvider.updateItemAt(i);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * A menu icon was touched.
		 */		
		private function onMenuIconTouched(event:Event):void
		{
			// FIXME A vérifier....
			//AbstractEntryPoint.screenNavigator.screenData.purgeData();
			if( String(event.data) == ScreenIds.LOG_IN_OUT )
			{
				if( MemberManager.getInstance().isLoggedIn() )
				{
					// log out
					NotificationManager.addNotification( new DisconnectNotification(), onCloseDisconnectNotification );
				}
				else
				{
					// log in
					Remote.getInstance().clearAllRespondersOfScreen("Menu");
					NavigationManager.resetNavigation();
					if( _screenNavigator.activeScreenID != ScreenIds.AUTHENTICATION_SCREEN )
						AuthenticationManager.startAuthenticationProcess(_screenNavigator, _screenNavigator.activeScreenID);
					else
						dispatchEventWith(LudoEventType.HIDE_MAIN_MENU);
				}
			}
			else
			{
				_showHomeOnClose = false;
				NavigationManager.resetNavigation();
				if( _screenNavigator.activeScreenID != String(event.data) )
				{
					Remote.getInstance().clearAllRespondersOfScreen("Menu");
					if( String(event.data) == ScreenIds.MY_GIFTS_SCREEN && MemberManager.getInstance().isLoggedIn() && AirNetworkInfo.networkInfo.isConnected())
					{
						Remote.getInstance().getGiftsHistory(0, 20, onGetGifts, onGetGifts, onGetGifts, 1, "Menu");
					}
					else
					{
						if( !MemberManager.getInstance().isLoggedIn() &&
							( String(event.data) == ScreenIds.MY_ACCOUNT_SCREEN ||
							  String(event.data) == ScreenIds.STORE_SCREEN ||
							  String(event.data) == ScreenIds.MY_GIFTS_SCREEN ))
						{
							if( _screenNavigator.activeScreenID != ScreenIds.AUTHENTICATION_SCREEN )
								_screenNavigator.showScreen( ScreenIds.AUTHENTICATION_SCREEN );
							else
								dispatchEventWith(LudoEventType.HIDE_MAIN_MENU);
						}
						else
						{
							_screenNavigator.showScreen( String(event.data) );
						}
					}
				}
				else
				{
					dispatchEventWith(LudoEventType.HIDE_MAIN_MENU);
				}
			}
		}
		
		private function onGetGifts(result:Object = null):void
		{
			if( result && result.code == 3 && Storage.getInstance().getProperty(StorageConfig.PROPERTY_DISPLAY_HOW_TO_WIN_GIFTS_SCREEN) )
			{
				// no gifts won yet
				_screenNavigator.showScreen( ScreenIds.HOW_TO_WIN_GIFTS_SCREEN );
			}
			else
			{
				_screenNavigator.showScreen( ScreenIds.MY_GIFTS_SCREEN );
			}
		}
		
		private function onCloseDisconnectNotification(event:Event):void
		{
			if( event.data )
			{
				Remote.getInstance().clearAllRespondersOfScreen("Menu");
				MemberManager.getInstance().disconnect();
				if( _screenNavigator.activeScreenID != ScreenIds.HOME_SCREEN )
					_screenNavigator.showScreen( ScreenIds.HOME_SCREEN );
				else
					dispatchEventWith(LudoEventType.HIDE_MAIN_MENU);
			}
		}
		
		public function get showHomeOnClose():Boolean { return _showHomeOnClose; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_tiledBackground.removeFromParent(true);
			_tiledBackground = null;
			
			_list.removeEventListener(LudoEventType.MENU_ICON_TOUCHED, onMenuIconTouched);
			_list.removeFromParent(true);
			_list = null;
			
			_screenNavigator = null;
			
			super.dispose();
		}
	}
}