/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.navigation.account
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.OffsetTabBar;
	import com.ludofactory.mobile.navigation.account.history.account.AccountHistoryContainer;
	import com.ludofactory.mobile.navigation.account.history.payments.PaymentsHistoryContainer;
	import com.ludofactory.mobile.navigation.account.history.settings.PersonalInformationsContainer;
	
	import feathers.data.ListCollection;
	
	import starling.events.Event;
	
	public class MyAccountScreen extends AdvancedScreen
	{
		/**
		 * Main menu. */		
		private var _menu:OffsetTabBar;
		
		/**
		 * Personal informations. */		
		private var _personalInformationsContainer:PersonalInformationsContainer;
		
		/**
		 * The payments history container/ */		
		private var _paymentsHistoryContainer:PaymentsHistoryContainer;
		
		/**
		 * The account history container. */		
		private var _accountHistoryContainer:AccountHistoryContainer;
		
		public function MyAccountScreen()
		{
			super();
			
			_appClearBackground = false;
			_whiteBackground = true;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Mon compte");
			
			_menu = new OffsetTabBar();
			_menu.dataProvider = new ListCollection( [ _("Infos perso"),
													   _("Paiments"),
													   _("Historique") ] );
			_menu.addEventListener(Event.CHANGE, onMenuChange);
			addChild(_menu);
			
			_personalInformationsContainer = new PersonalInformationsContainer();
			addChild(_personalInformationsContainer);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_menu.width = this.actualWidth;
				_menu.y = scaleAndRoundToDpi(10);
				_menu.validate();
				
				_personalInformationsContainer.width = this.actualWidth;
				_personalInformationsContainer.y = _menu.y + _menu.height;
				_personalInformationsContainer.height = this.actualHeight - _personalInformationsContainer.y;
			}
		}
		
		private function layoutPaymentsHistoryContainer():void
		{
			_paymentsHistoryContainer.width = this.actualWidth;
			_paymentsHistoryContainer.y = _menu.y + _menu.height;
			_paymentsHistoryContainer.height = this.actualHeight - _paymentsHistoryContainer.y;
		}
		
		private function layoutAccountHistoryContainer():void
		{
			_accountHistoryContainer.width = this.actualWidth;
			_accountHistoryContainer.y = _menu.y + _menu.height;
			_accountHistoryContainer.height = this.actualHeight - _accountHistoryContainer.y;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onMenuChange(event:Event):void
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
					
					break;
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_menu.removeEventListener(Event.CHANGE, onMenuChange);
			_menu.removeFromParent(true);
			_menu = null;
			
			_personalInformationsContainer.removeFromParent(true);
			_personalInformationsContainer = null;
			
			if( _paymentsHistoryContainer )
			{
				_paymentsHistoryContainer.removeFromParent(true);
				_paymentsHistoryContainer = null;
			}
			
			if( _accountHistoryContainer )
			{
				_accountHistoryContainer.removeFromParent(true);
				_accountHistoryContainer = null;
			}
			
			super.dispose();
		}
		
	}
}