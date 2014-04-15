/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 20 janv. 2014
*/
package com.ludofactory.mobile.debug
{
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.test.achievements.TrophyManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.settings.SettingItemRenderer;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.controls.CustomToggleSwitch;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.desktop.NativeApplication;
	
	import feathers.controls.Button;
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	public class DebugScreen extends AdvancedScreen
	{
		/**
		 * The list. */		
		private var _list:List;
		
		/**
		 * Repo picker. */		
		private var _repoPicker:PickerList;
		/**
		 * Port picker. */		
		private var _portPicker:PickerList;
		/**
		 * To reconnect. */		
		private var _connectButton:ArrowGroup;
		/**
		 * Temporary reset button. */		
		private var _resetButton:ArrowGroup;
		/**
		 * For debug only. */		
		private var _tournamentToggleSwitch:CustomToggleSwitch;
		/**
		 * Trophy tester. */		
		private var _winAllTrophiesButton:Button;
		/**
		 * Retreive default data. */		
		private var _getdefaultData:Button;
		
		public function DebugScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = "Debug";
			
			_repoPicker = new PickerList();
			_repoPicker.dataProvider = new ListCollection( ["http://ludomobile.ludokado.com",
															"http://ludomobile.ludokado.dev",
															"http://ludokadom.mlhoez.ludofactory.dev",
															"http://ludokado.pterrier.ludofactory.dev",
															"http://ludokado.aguerreiro.ludofactory.dev"] );
			_repoPicker.selectedItem = Remote.getInstance().baseGatewayUrl;
			
			_portPicker = new PickerList();
			_portPicker.dataProvider = new ListCollection( [80, 9999] );
			_portPicker.selectedItem = Remote.getInstance().gatewayPortNumber;
			
			_connectButton = new ArrowGroup("Connecter");
			_connectButton.addEventListener(Event.TRIGGERED, onChangeRepo);
			
			_resetButton = new ArrowGroup("Reset");
			_resetButton.addEventListener(Event.TRIGGERED, onReset);
			
			_winAllTrophiesButton = new Button();
			_winAllTrophiesButton.label = "Tester";
			_winAllTrophiesButton.addEventListener(Event.TRIGGERED, onTestTrophies);
			_winAllTrophiesButton.styleName = Theme.BUTTON_TRANSPARENT_BLUE_DARKER;
			
			_getdefaultData = new Button();
			_getdefaultData.label = "Go";
			_getdefaultData.addEventListener(Event.TRIGGERED, onGetDefaultData);
			_getdefaultData.styleName = Theme.BUTTON_TRANSPARENT_BLUE_DARKER;
			
			_tournamentToggleSwitch = new CustomToggleSwitch();
			_tournamentToggleSwitch.onText = "";
			_tournamentToggleSwitch.offText = "";
			_tournamentToggleSwitch.onThumbText = Localizer.getInstance().translate("COMMON.YES");
			_tournamentToggleSwitch.offThumbText = Localizer.getInstance().translate("COMMON.NO");
			_tournamentToggleSwitch.isSelected = MemberManager.getInstance().getTournamentUnlocked();
			_tournamentToggleSwitch.addEventListener(Event.CHANGE, onSwitchTournament);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.useVirtualLayout = false;
			vlayout.manageVisibility = true;
			
			_list = new List();
			_list.isSelectable = false;
			_list.layout = vlayout;
			_list.itemRendererType = SettingItemRenderer;
			_list.dataProvider = new ListCollection( [ { title:"Dépôt : " + Remote.getInstance().baseGatewayUrl + (Remote.getInstance().gatewayPortNumber ? (":" + Remote.getInstance().gatewayPortNumber) : ""), value:"" },
													   { title:"Changer dépôt", value:"", accessory:_repoPicker },
													   { title:"", value:"", accessory:_portPicker },
													   { title:"", value:"", accessory:_connectButton },
													   { title:"Reset données", value:"", accessory:_resetButton },
													   { title:"Tournoi débloqué", value:"", accessory:_tournamentToggleSwitch },
													   { title:"Gagner toutes les coupes", value:"", accessory:_winAllTrophiesButton },
													   { title:"Get données par défaut", value:"", accessory:_getdefaultData }
													 ] );
			addChild(_list);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				/*_repositoryLabel.y = scaleAndRoundToDpi(10);
				_repositoryLabel.x = scaleAndRoundToDpi(10);
				_repositoryLabel.width = actualWidth - _repositoryLabel.x;*/
				_list.width = actualWidth;
				_list.height = actualHeight;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Temporary function used to reset the application data.
		 */		
		private function onReset(event:Event):void
		{
			Storage.getInstance().clearStorage();
			if( GlobalConfig.ios )
				InfoManager.show("Redémarrer l'application pour éviter tout bug.");
			else
				NativeApplication.nativeApplication.exit();
		}
		
		private function onSwitchTournament(event:Event):void
		{
			MemberManager.getInstance().setTournamentUnlocked(_tournamentToggleSwitch.isSelected);
			MemberManager.getInstance().setTournamentAnimPending(_tournamentToggleSwitch.isSelected);
		}
		
		private function onTestTrophies(event:Event):void
		{
			for(var i:int = 1; i < 19; i++)
				TrophyManager.getInstance().onWinTrophy(i);
		}
		
		private function onGetDefaultData(event:Event):void
		{
			Remote.getInstance().getVip(onGetVipSuccess, null, null, 1, advancedOwner.activeScreenID);
			Remote.getInstance().getFaq(onGetFaqSuccess, null, null, 1, advancedOwner.activeScreenID);
			Remote.getInstance().getNews(onGetNewsSuccess, null, null, 1, advancedOwner.activeScreenID);
			Remote.getInstance().getTermsAndConditions(onGetTermsAndConditionsSuccess, null, null, 1, advancedOwner.activeScreenID);
		}
		
		private function onGetVipSuccess(result:Object):void
		{
			// Penser à changer la version sinon on récupère rien
			// Flash interprète tous les \ dans le JSON AVANT qu'il soit parsé, ce qui le fait
			// buguer (s'il y a une citation entre "" par exemple). Il faut donc doubler tous les
			// \ après avoir tranformé l'objet en JSON puis, optionnellement, si on veut stocker
			// ce JSON dans l'application comme ici, il faut rajouter APRES des \ devant toutes les
			// apostrophes / simple quote.
			if( result != null && result.hasOwnProperty("tab_vip") && result.tab_vip )
				log("VIP :\n" + JSON.stringify(result.tab_vip as Array).replace(/\\/g, "\\\\").replace(/'/g, "\\'"));
		}
		
		private function onGetFaqSuccess(result:Object):void
		{
			// Penser à changer la version sinon on récupère rien
			// Flash interprète tous les \ dans le JSON AVANT qu'il soit parsé, ce qui le fait
			// buguer (s'il y a une citation entre "" par exemple). Il faut donc doubler tous les
			// \ après avoir tranformé l'objet en JSON puis, optionnellement, si on veut stocker
			// ce JSON dans l'application comme ici, il faut rajouter APRES des \ devant toutes les
			// apostrophes / simple quote.
			if( result != null && result.hasOwnProperty( "tabFaq" ) && result.tabFaq != null )
				log("FAQ :\n" + JSON.stringify(result.tabFaq as Array).replace(/\\/g, "\\\\").replace(/'/g, "\\'"));
		}
		
		private function onGetNewsSuccess(result:Object):void
		{
			// Penser à changer la version sinon on récupère rien
			// Flash interprète tous les \ dans le JSON AVANT qu'il soit parsé, ce qui le fait
			// buguer (s'il y a une citation entre "" par exemple). Il faut donc doubler tous les
			// \ après avoir tranformé l'objet en JSON puis, optionnellement, si on veut stocker
			// ce JSON dans l'application comme ici, il faut rajouter APRES des \ devant toutes les
			// apostrophes / simple quote.
			if( result != null && result.hasOwnProperty("tab_actualites") && result.tab_actualites )
				log("NEWS :\n" + JSON.stringify(result.tab_actualites as Array).replace(/\\/g, "\\\\").replace(/'/g, "\\'"));
		}
		
		private function onGetTermsAndConditionsSuccess(result:Object):void
		{
			// Penser à changer la version sinon on récupère rien
			// Flash interprète tous les \ dans le JSON AVANT qu'il soit parsé, ce qui le fait
			// buguer (s'il y a une citation entre "" par exemple). Il faut donc doubler tous les
			// \ après avoir tranformé l'objet en JSON puis, optionnellement, si on veut stocker
			// ce JSON dans l'application comme ici, il faut rajouter APRES des \ devant toutes les
			// apostrophes / simple quote.
			if( result != null && result.hasOwnProperty("reglement") && result.reglement )
				log("CGU :\n" + JSON.stringify(result.reglement).replace(/\\/g, "\\\\").replace(/'/g, "\\'"));
		}
		
		private function onChangeRepo(event:Event):void
		{
			Remote.getInstance().reconnect(String(_repoPicker.selectedItem), int(_portPicker.selectedItem));
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_repoPicker.removeFromParent(true);
			_repoPicker = null;
			
			_portPicker.removeFromParent(true);
			_portPicker = null;
			
			_connectButton.removeEventListener(Event.TRIGGERED, onChangeRepo);
			_connectButton.removeFromParent(true);
			_connectButton = null;
			
			_resetButton.removeEventListener(Event.TRIGGERED, onReset);
			_resetButton.removeFromParent(true);
			_resetButton = null;
			
			_tournamentToggleSwitch.removeEventListener(Event.CHANGE, onSwitchTournament);
			_tournamentToggleSwitch.removeFromParent(true);
			_tournamentToggleSwitch = null;
			
			_winAllTrophiesButton.removeEventListener(Event.TRIGGERED, onTestTrophies);
			_winAllTrophiesButton.removeFromParent(true);
			_winAllTrophiesButton = null;
			
			_getdefaultData.removeEventListener(Event.TRIGGERED, onGetDefaultData);
			_getdefaultData.removeFromParent(true);
			_getdefaultData = null;
			
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}