/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.navigation.account
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.navigation.account.history.settings.PersonalInformationsContainer;
	
	import starling.display.Quad;
	
	public class MyAccountScreen extends AdvancedScreen
	{
		/**
		 * Main menu. */		
		//private var _menu:OffsetTabBar;
		
		/**
		 * Personal informations. */		
		private var _personalInformationsContainer:PersonalInformationsContainer;
		
		/**
		 * White background to make it nicer while it's loading or when there is nothing to show. */
		private var _background:Quad;
		
		public function MyAccountScreen()
		{
			super();
			
			_appClearBackground = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			//_headerTitle = _("Mon compte");
			
			//_menu = new OffsetTabBar();
			/*_menu.dataProvider = new ListCollection( [ _("Infos perso"),
													   _("Paiements"),
													   _("Historique") ] );*/
			//_menu.addEventListener(Event.CHANGE, onMenuChange);
			//addChild(_menu);
			
			_background = new Quad(5, 5);
			addChild(_background);
			
			_personalInformationsContainer = new PersonalInformationsContainer();
			addChild(_personalInformationsContainer);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				/*_menu.width = this.actualWidth;
				_menu.y = scaleAndRoundToDpi(10);
				_menu.validate();*/
				
				_personalInformationsContainer.width = _background.width = this.actualWidth;
				//_personalInformationsContainer.y = _background.y = _menu.y + _menu.height;
				_personalInformationsContainer.height = _background.height = this.actualHeight - _personalInformationsContainer.y;
				
				//_menu.selectedIndex = AbstractEntryPoint.screenNavigator.screenData.indexToDisplayInMyAccount;
				//AbstractEntryPoint.screenNavigator.screenData.indexToDisplayInMyAccount = 0;
			}
			
			super.draw();
		}
		
		/*private function layoutPaymentsHistoryContainer():void
		{
			_paymentsHistoryContainer.width = this.actualWidth;
			_paymentsHistoryContainer.y = _menu.y + _menu.height;
			_paymentsHistoryContainer.height = this.actualHeight - _paymentsHistoryContainer.y;
		}*/
		
		/*private function layoutAccountHistoryContainer():void
		{
			_accountHistoryContainer.width = this.actualWidth;
			_accountHistoryContainer.y = _menu.y + _menu.height;
			_accountHistoryContainer.height = this.actualHeight - _accountHistoryContainer.y;
		}*/
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/*private function onMenuChange(event:Event):void
		{
			switch(_menu.selectedIndex)
			{
				case 0:
				{
					Flox.logInfo("\t\tAffichage de l'onglet [Informations Personnelles]");
					
					_personalInformationsContainer.visible = true;
					if( _accountHistoryContainer )
						_accountHistoryContainer.visible = false;
					if( _paymentsHistoryContainer )
						_paymentsHistoryContainer.visible = false;
					
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Mon Compte", "Informations personnelles", null, NaN, MemberManager.getInstance().id);
					
					break;
				}
					
				case 1:
				{
					Flox.logInfo("\t\tAffichage de l'onglet [Historique du compte]");
					
					if( !_paymentsHistoryContainer )
					{
						_paymentsHistoryContainer = new PaymentsHistoryContainer();
						addChild(_paymentsHistoryContainer);
						layoutPaymentsHistoryContainer();
					}
					
					_personalInformationsContainer.visible = false;
					if( _accountHistoryContainer )
						_accountHistoryContainer.visible = false;
					if( _paymentsHistoryContainer )
						_paymentsHistoryContainer.visible = true;
					
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Mon Compte", "Historique du compte", null, NaN, MemberManager.getInstance().id);
					
					break;
				}
					
				case 2:
				{
					Flox.logInfo("\t\tAffichage de l'onglet [Historique des paiements]");
					
					if( !_accountHistoryContainer )
					{
						_accountHistoryContainer = new AccountHistoryContainer();
						addChild(_accountHistoryContainer);
						layoutAccountHistoryContainer();
					}
					
					_personalInformationsContainer.visible = false;
					if( _paymentsHistoryContainer )
						_paymentsHistoryContainer.visible = false;
					if( _accountHistoryContainer )
						_accountHistoryContainer.visible = true;
					
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Mon Compte", "Historique des paiements", null, NaN, MemberManager.getInstance().id);
					
					break;
				}
			}
		}*/
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			/*_menu.removeEventListener(Event.CHANGE, onMenuChange);
			_menu.removeFromParent(true);
			_menu = null;*/
			
			_background.removeFromParent(true);
			_background = null;
			
			_personalInformationsContainer.removeFromParent(true);
			_personalInformationsContainer = null;
			
			/*if( _paymentsHistoryContainer )
			{
				_paymentsHistoryContainer.removeFromParent(true);
				_paymentsHistoryContainer = null;
			}
			
			if( _accountHistoryContainer )
			{
				_accountHistoryContainer.removeFromParent(true);
				_accountHistoryContainer = null;
			}*/
			
			super.dispose();
		}
		
	}
}