/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.navigation.menu
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreenNavigator;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.DisconnectNotificationContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	
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
			
			// FIXME Checker la taille de la tile, et essayer de l'agrandir pour les perfs ? (voir utiliser autre chose)
			
			_tiledBackground = new TiledImage(AbstractEntryPoint.assets.getTexture("MenuTile"), GlobalConfig.dpiScale);
			_tiledBackground.touchable = false;
			_tiledBackground.useSeparateBatch = false;
			addChild(_tiledBackground);
			
			const listLayout:TiledRowsLayout = new  TiledRowsLayout();
			listLayout.paging = TiledRowsLayout.PAGING_NONE;
			//listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			//listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.useSquareTiles = false;
			listLayout.manageVisibility = true;
			
			/*
			
			_("Mon Compte");
			_("Parrainage");
			_("Aide");
			_("Crédits");
			_("Cadeaux");
			_("Rangs VIP");
			_("Mes gains");
			_("High Scores");
			_("Coupes");
			_("Tournois");
			_("Réglages");
			
			 */
			
			
			_list = new List();
			_list.layout = listLayout;
			_list.isSelectable = false;
			_list.itemRendererType = MenuItemRenderer;
			_list.addEventListener(MobileEventTypes.MENU_ICON_TOUCHED, onMenuIconTouched);
            if( MemberManager.getInstance().getGiftsEnabled() )
            {
                _list.dataProvider = new ListCollection(
                    [
                        new MenuItemData( "menu-icon-my-account",    "Mon Compte",  ScreenIds.MY_ACCOUNT_SCREEN ),
                        new MenuItemData( "menu-icon-parrainage",    "Parrainage",  ScreenIds.SPONSOR_HOME_SCREEN, AbstractEntryPoint.alertData.numSponsorAlerts ),
                        new MenuItemData( "menu-icon-help", 		 "Aide",        ScreenIds.HELP_HOME_SCREEN, AbstractEntryPoint.alertData.numCustomerServiceAlerts + AbstractEntryPoint.alertData.numCustomerServiceImportantAlerts ),
                        new MenuItemData( "menu-icon-credit",        "Crédits",     ScreenIds.STORE_SCREEN ),
                        new MenuItemData( "menu-icon-store",         "Cadeaux",     ScreenIds.BOUTIQUE_HOME ),
                        new MenuItemData( "menu-icon-vip",           "Rangs VIP",   ScreenIds.VIP_SCREEN ),
                        new MenuItemData( "menu-icon-my-gifts",      "Mes gains",   ScreenIds.MY_GIFTS_SCREEN, AbstractEntryPoint.alertData.numGainAlerts ),
                        new MenuItemData( "menu-icon-highscore",     "High Scores", ScreenIds.HIGH_SCORE_HOME_SCREEN ),
                        new MenuItemData( "menu-icon-trophy",        "Coupes",      ScreenIds.TROPHY_SCREEN, AbstractEntryPoint.alertData.numTrophiesAlerts ),
                        new MenuItemData( "menu-icon-tournaments",   "Tournois",    ScreenIds.PREVIOUS_TOURNAMENTS_SCREEN ),
                        new MenuItemData( "menu-icon-settings",      "Réglages",    ScreenIds.SETTINGS_SCREEN ),
                        new MenuItemData( MemberManager.getInstance().isLoggedIn() ? "menu-icon-log-out" : "menu-icon-log-in",   MemberManager.getInstance().isLoggedIn() ? "Déconnexion" : "Connexion",          ScreenIds.LOG_IN_OUT )
                    ]);
            }
            else
            {
                _list.dataProvider = new ListCollection(
                        [
                            new MenuItemData( "menu-icon-my-account",    "Mon Compte",  ScreenIds.MY_ACCOUNT_SCREEN ),
                            new MenuItemData( "menu-icon-parrainage",    "Parrainage",  ScreenIds.SPONSOR_HOME_SCREEN, AbstractEntryPoint.alertData.numSponsorAlerts ),
                            new MenuItemData( "menu-icon-help", 		 "Aide",        ScreenIds.HELP_HOME_SCREEN, AbstractEntryPoint.alertData.numCustomerServiceAlerts + AbstractEntryPoint.alertData.numCustomerServiceImportantAlerts ),
                            new MenuItemData( "menu-icon-credit",        "Crédits",     ScreenIds.STORE_SCREEN ),
                            new MenuItemData( "menu-icon-store",         "Boutique",     ScreenIds.BOUTIQUE_HOME ),
                            new MenuItemData( "menu-icon-vip",           "Rangs VIP",   ScreenIds.VIP_SCREEN ),
                            new MenuItemData( "menu-icon-highscore",     "High Scores", ScreenIds.HIGH_SCORE_HOME_SCREEN ),
                            new MenuItemData( "menu-icon-trophy",        "Coupes",      ScreenIds.TROPHY_SCREEN, AbstractEntryPoint.alertData.numTrophiesAlerts ),
                            new MenuItemData( "menu-icon-tournaments",   "Tournois",    ScreenIds.PREVIOUS_TOURNAMENTS_SCREEN ),
                            new MenuItemData( "menu-icon-settings",      "Réglages",    ScreenIds.SETTINGS_SCREEN ),
                            new MenuItemData( MemberManager.getInstance().isLoggedIn() ? "menu-icon-log-out" : "menu-icon-log-in",   MemberManager.getInstance().isLoggedIn() ? "Déconnexion" : "Connexion",          ScreenIds.LOG_IN_OUT )
                        ]);
            }
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
            if( MemberManager.getInstance().getGiftsEnabled() )
            {
                i++;
                tempMenuItemData = _list.dataProvider.getItemAt(i) as MenuItemData;
                tempMenuItemData.badgeNumber = AbstractEntryPoint.alertData.numGainAlerts;
                _list.dataProvider.setItemAt(tempMenuItemData, i);
                _list.dataProvider.updateItemAt(i);
            }

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
			tempMenuItemData.title = MemberManager.getInstance().isLoggedIn() ? _("Déconnexion") : _("Connexion");
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
					//NotificationManager.addNotification( new DisconnectNotification(), onCloseDisconnectNotification );
					NotificationPopupManager.addNotification( new DisconnectNotificationContent(), onCloseDisconnectNotification );
				}
				else
				{
					// log in
					Remote.getInstance().clearAllRespondersOfScreen("Menu");
					NavigationManager.resetNavigation();
					if( _screenNavigator.activeScreenID != ScreenIds.AUTHENTICATION_SCREEN )
						AuthenticationManager.startAuthenticationProcess(_screenNavigator, _screenNavigator.activeScreenID);
					else
						dispatchEventWith(MobileEventTypes.HIDE_MAIN_MENU);
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
								dispatchEventWith(MobileEventTypes.HIDE_MAIN_MENU);
						}
						else
						{
							_screenNavigator.showScreen( String(event.data) );
						}
					}
				}
				else
				{
					dispatchEventWith(MobileEventTypes.HIDE_MAIN_MENU);
				}
			}
		}
		
		private function onGetGifts(result:Object = null):void
		{
			if( result && result.code == 3 )
			{
				// no gifts won yet
				_screenNavigator.showScreen( ScreenIds.HOW_TO_WIN_GIFTS_SCREEN );
			}
			else
			{
				_screenNavigator.showScreen( ScreenIds.MY_GIFTS_SCREEN );
			}
		}
		
		private function onCloseDisconnectNotification(data:Object):void
		{
			if( Boolean(data) )
			{
				Remote.getInstance().clearAllRespondersOfScreen("Menu");
				MemberManager.getInstance().disconnect();
				if( _screenNavigator.activeScreenID != ScreenIds.HOME_SCREEN )
					_screenNavigator.showScreen( ScreenIds.HOME_SCREEN );
				else
					dispatchEventWith(MobileEventTypes.HIDE_MAIN_MENU);
			}
		}
		
		public function get showHomeOnClose():Boolean { return _showHomeOnClose; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_tiledBackground.removeFromParent(true);
			_tiledBackground = null;
			
			_list.removeEventListener(MobileEventTypes.MENU_ICON_TOUCHED, onMenuIconTouched);
			_list.removeFromParent(true);
			_list = null;
			
			_screenNavigator = null;
			
			super.dispose();
		}
	}
}