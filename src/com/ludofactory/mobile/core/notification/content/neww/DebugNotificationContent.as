/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.core.notification.content.neww
{
	
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.controls.CustomToggleSwitch;
	import com.ludofactory.mobile.core.dispatcher;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.*;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.debug.DebugItemRenderer;
	import com.ludofactory.mobile.navigation.achievements.TrophyManager;
	import com.ludofactory.mobile.navigation.settings.LanguageData;
	import com.milkmangames.nativeextensions.GoViral;
	
	import feathers.controls.Button;
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import flash.data.EncryptedLocalStore;
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	use namespace dispatcher;
	
	public class DebugNotificationContent extends AbstractPopupContent
	{
		/**
		 * The list. */
		private var _list:List;
		
		private var _currentRepository:TextField;
		private var _changeRepository:TextField;
		
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
		 * Retreive default data. */
		private var _getdefaultData:Button;
		
		private var _mainContainer:ScrollContainer;
		
		public function DebugNotificationContent()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			data = false;
			
			_mainContainer = new ScrollContainer();
			_mainContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_mainContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild(_mainContainer);
			
			_currentRepository = new TextField(5, scaleAndRoundToDpi(50), "Connecté à : " + Remote.getInstance().baseGatewayUrl + (Remote.getInstance().gatewayPortNumber ? (":" + Remote.getInstance().gatewayPortNumber) : ""), new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY));
			_currentRepository.format.horizontalAlign = Align.LEFT;
			_currentRepository.autoScale = true;
			_mainContainer.addChild(_currentRepository);
			
			_changeRepository = new TextField(5, scaleAndRoundToDpi(50), "Changer : ", new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY));
			_changeRepository.format.horizontalAlign = Align.LEFT;
			_changeRepository.autoSize = TextFieldAutoSize.HORIZONTAL;
			_mainContainer.addChild(_changeRepository);
			
			// TODO rajouter un champ pour rentrer une url à la mano au cas ou
			
			_repoPicker = new PickerList();
			_repoPicker.styleNameList.add(Theme.PICKER_LIST_DEBUG);
			_repoPicker.dataProvider = new ListCollection( ["http://www.ludokado.com",
				"http://semiprod.ludokado.com",
				"http://appmobile.ludokado.com",
				"http://ludokado.mlhoez.ludofactory.dev",
				"http://ludokado2.pterrier.ludofactory.dev",
				"http://ludokado.aguerreiro.ludofactory.dev"] );
			_repoPicker.selectedItem = Remote.getInstance().baseGatewayUrl;
			_mainContainer.addChild(_repoPicker);
			
			_portPicker = new PickerList();
			_portPicker.dataProvider = new ListCollection( [80, 9999] );
			_portPicker.selectedItem = Remote.getInstance().gatewayPortNumber;
			_mainContainer.addChild(_portPicker);
			
			_connectButton = new ArrowGroup("Connecter");
			_connectButton.addEventListener(Event.TRIGGERED, onChangeRepo);
			_mainContainer.addChild(_connectButton);
			
			_resetButton = new ArrowGroup("Reset");
			_resetButton.addEventListener(Event.TRIGGERED, onReset);
			
			_getdefaultData = new Button();
			_getdefaultData.label = "Go";
			_getdefaultData.addEventListener(Event.TRIGGERED, onGetDefaultData);
			_getdefaultData.styleName = Theme.BUTTON_TRANSPARENT_BLUE_DARKER;
			
			_tournamentToggleSwitch = new CustomToggleSwitch();
			_tournamentToggleSwitch.onText = "";
			_tournamentToggleSwitch.offText = "";
			_tournamentToggleSwitch.onThumbText = _("Oui");
			_tournamentToggleSwitch.offThumbText = _("Non");
			_tournamentToggleSwitch.isSelected = MemberManager.getInstance().isTournamentUnlocked;
			_tournamentToggleSwitch.addEventListener(Event.CHANGE, onSwitchTournament);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.useVirtualLayout = false;
			
			_list = new List();
			_list.isSelectable = false;
			_list.layout = vlayout;
			_list.itemRendererType = DebugItemRenderer;
			_list.dataProvider = new ListCollection( [ { title:"Reset données", value:"", accessory:_resetButton },
				{ title:"Tournoi débloqué", value:"", accessory:_tournamentToggleSwitch },
				{ title:"Get données par défaut", value:"", accessory:_getdefaultData }
			] );
			_mainContainer.addChild(_list);
		}
		
		override protected function draw():void
		{
			/*_list.width = this.actualWidth;
			_list.validate();
			if(_list.height > NotificationPopupManager.maxContentHeight)
					_list.height = NotificationPopupManager.maxContentHeight;*/
			
			_mainContainer.width = this.actualWidth;
			
			_currentRepository.width = actualWidth;
			_changeRepository.y = _repoPicker.y = _portPicker.y = _currentRepository.height + scaleAndRoundToDpi(5);
			_portPicker.validate();
			_portPicker.width += scaleAndRoundToDpi(10);
			_portPicker.x = actualWidth - _portPicker.width - scaleAndRoundToDpi(10);
			_repoPicker.width = _portPicker.x - _changeRepository.width - scaleAndRoundToDpi(20);
			_repoPicker.x = _changeRepository.width + scaleAndRoundToDpi(10);
			
			_connectButton.y = _portPicker.y + _portPicker.height;
			_connectButton.x = actualWidth - _connectButton.width - scaleAndRoundToDpi(10);
			
			_list.y = _connectButton.y + _connectButton.height + scaleAndRoundToDpi(5);
			_list.width = this.actualWidth;
			_list.validate();
			
			_mainContainer.validate();
			if(_mainContainer.height > CustomPopupManager.maxContentHeight)
				_mainContainer.height = CustomPopupManager.maxContentHeight;
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Temporary function used to reset the application data.
		 */
		private function onReset(event:Event):void
		{
			Storage.getInstance().clearStorage();
			EncryptedLocalStore.reset();
			if( GoViral.isSupported() && GoViral.goViral.isFacebookSupported() )
				GoViral.goViral.logoutFacebook();
			if( GlobalConfig.ios )
				InfoManager.show("Redémarrer l'application pour éviter tout bug.");
			else
				NativeApplication.nativeApplication.exit();
		}
		
		private function onSwitchTournament(event:Event):void
		{
			MemberManager.getInstance().isTournamentUnlocked = _tournamentToggleSwitch.isSelected;
			MemberManager.getInstance().isTournamentAnimPending = _tournamentToggleSwitch.isSelected;
		}
		
		private function onTestTrophies(event:Event):void
		{
			for(var i:int = 1; i < 19; i++)
				TrophyManager.getInstance().onWinTrophy(i);
		}
		
		/**
		 * How many defaults to retrieve. */
		private static const DEFAULT_COUNTER:int = 4;
		private var _counter:int = 0;
		private var _languagesToParse:Array = [];
		private var _actualLangSave:String;
		
		private function onGetDefaultData(event:Event):void
		{
			// save the actual language
			_actualLangSave = LanguageManager.getInstance().lang;
			// retrieve all the languages
			_languagesToParse = (Storage.getInstance().getProperty( StorageConfig.PROPERTY_AVAILABLE_LANGUAGES) as Array).concat();
			// and fetch the default for all of them
			fetchNext();
		}
		
		private function fetchNext():void
		{
			if (_languagesToParse.length > 0)
			{
				var languageToFetchDefaultsFor:LanguageData = _languagesToParse.pop();
				// change the language
				LanguageManager.getInstance().lang = languageToFetchDefaultsFor.key;
				
				// then fetch everything
				log("Fetching defaults for " + languageToFetchDefaultsFor.translationKey);
				_counter = DEFAULT_COUNTER;
				Remote.getInstance().getFaq(onGetFaqSuccess, null, null, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
				Remote.getInstance().getNews(onGetNewsSuccess, null, null, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
				Remote.getInstance().getTermsAndConditions(onGetTermsAndConditionsSuccess, null, null, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				// bring back the language that was selected
				LanguageManager.getInstance().lang = _actualLangSave;
				log("Defaults fetch done !");
			}
		}
		
		private function writeTo(className:String, contentToWrite:Object):void
		{
			// write in file so that we can simply copy / paste the content in the DefaultXXX.as classes
			var file:File = new File();
			file = file.resolvePath("/Users/Maxime/Desktop/export-defaults/" + className + ".as");
			
			// Flash interprète tous les \ dans le JSON AVANT qu'il soit parsé, ce qui le fait buguer (s'il y a une
			// citation entre "" par exemple). Il faut donc doubler tous les \ après avoir tranformé l'objet en JSON
			// puis, optionnellement, si on veut stocker ce JSON dans l'application comme ici, il faut rajouter APRES
			// des \ devant toutes les apostrophes / simple quote.
			
			//log(className + " :\n" + JSON.stringify(contentToWrite).replace(/\\/g, "\\\\").replace(/'/g, "\\'"));
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.UPDATE);
			if(file.size == 0)
				fileStream.writeUTFBytes("package com.ludofactory.mobile.core.storage.defaults\n{\n\n\tpublic class " + className + "\n\t{\n");
			else
				fileStream.position = fileStream.bytesAvailable;
			fileStream.writeUTFBytes("\n\t\t" + "public static const " + LanguageManager.getInstance().lang.toUpperCase() + ":String = '" + JSON.stringify(contentToWrite).replace(/\\/g, "\\\\").replace(/'/g, "\\'") +"';");
			if(_languagesToParse.length == 0)
			{
				// finalize file
				fileStream.writeUTFBytes("\n\n\t}\n}");
			}
			fileStream.close();
			fileStream = null;
		}
		
		private function onGetFaqSuccess(result:Object):void
		{
			if( result != null && result.hasOwnProperty( "tabFaq" ) && result.tabFaq != null )
				writeTo("DefaultFaq", result.tabFaq);
			
			log("  - FAQ DONE");
			onDefaultRetrieved();
		}
		
		private function onGetNewsSuccess(result:Object):void
		{
			if( result != null && result.hasOwnProperty("tab_actualites") && result.tab_actualites )
				writeTo("DefaultNews", result.tab_actualites);
			
			log("  - NEWS DONE");
			onDefaultRetrieved();
		}
		
		private function onGetTermsAndConditionsSuccess(result:Object):void
		{
			if( result != null && result.hasOwnProperty("reglement") && result.reglement )
				writeTo("DefaultTermsAndConditions", result.reglement);
			
			log("  - CGU DONE");
			onDefaultRetrieved();
		}
		
		private function onDefaultRetrieved():void
		{
			_counter--;
			if(_counter <= 0)
				fetchNext();
		}
		
		private function onChangeRepo(event:Event):void
		{
			_currentRepository.text = "Connecté à " + String(_repoPicker.selectedItem);
			Remote.getInstance().reconnect(String(_repoPicker.selectedItem), int(_portPicker.selectedItem));
			
			MemberManager.getInstance().disconnect();
			//onBack();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_currentRepository.removeFromParent(true);
			_currentRepository = null;
			
			_changeRepository.removeFromParent(true);
			_changeRepository = null;
			
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
			
			_getdefaultData.removeEventListener(Event.TRIGGERED, onGetDefaultData);
			_getdefaultData.removeFromParent(true);
			_getdefaultData = null;
			
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}