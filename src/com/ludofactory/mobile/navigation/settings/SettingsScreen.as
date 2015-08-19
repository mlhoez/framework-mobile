/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 3 oct. 2013
*/
package com.ludofactory.mobile.navigation.settings
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.dispatcher;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.CustomToggleSwitch;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	
	public class SettingsScreen extends AdvancedScreen
	{
		/**
		 * The logo. */		
		private var _logo:Image;
		
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		
		/**
		 * The list. */		
		private var _list:List;
		
		/**
		 * Sound toggle switch */		
		private var _soundToggleSwitch:CustomToggleSwitch;
		/**
		 * Music toggle switch. */		
		private var _musicToggleSwitch:CustomToggleSwitch;
		/**
		 * Music toggle switch. */		
		private var _tutoToggleSwitch:CustomToggleSwitch;
		/**
		 * Language picker. */		
		private var _languagePicker:PickerList;
		
		/**
		 * Saved values used to determine if we need to send
		 * the data in our server on screen disposal or not. */		
		private var _savedSoundChoice:Boolean;
		private var _savedMusicChoice:Boolean;
		private var _savedGameCeneterChoice:Boolean;
		private var _savedTutoChoice:Boolean;
		private var _savedLanguageChoice:int;
		
		public function SettingsScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Réglages");
			
			// reset alerts for new languages
			Storage.getInstance().setProperty(StorageConfig.PROPERTY_NEW_LANGUAGES, []);
			dispatcher.dispatchEventWith(MobileEventTypes.ALERT_COUNT_UPDATED);
			
			if( !AbstractGameInfo.LANDSCAPE )
			{
				_logo = new Image( AbstractEntryPoint.assets.getTexture( "menu-icon-settings" ) );
				_logo.scaleX = _logo.scaleY = Utilities.getScaleToFillWidth(_logo.width, (GlobalConfig.stageWidth * 0.4));
				addChild( _logo );
				
				_listShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
				_listShadow.setVertexColor(0, 0xffffff);
				_listShadow.setVertexAlpha(0, 0);
				_listShadow.setVertexColor(1, 0xffffff);
				_listShadow.setVertexAlpha(1, 0);
				_listShadow.setVertexAlpha(2, 0.1);
				_listShadow.setVertexAlpha(3, 0.1);
				addChild(_listShadow);
			}
			
			_soundToggleSwitch = new CustomToggleSwitch();
			_soundToggleSwitch.onText = "";
			_soundToggleSwitch.offText = "";
			_soundToggleSwitch.onThumbText = _("Oui");
			_soundToggleSwitch.offThumbText = _("Non");
			_soundToggleSwitch.thumbProperties.isEnabled = false;
			_soundToggleSwitch.isSelected = Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED));
			_soundToggleSwitch.addEventListener(Event.CHANGE, onSwitchSound);
			_savedSoundChoice = _soundToggleSwitch.isSelected;
			
			_musicToggleSwitch = new CustomToggleSwitch();
			_musicToggleSwitch.onText = "";
			_musicToggleSwitch.offText = "";
			_musicToggleSwitch.onThumbText = _("Oui");
			_musicToggleSwitch.offThumbText = _("Non");
			_musicToggleSwitch.isSelected = Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED));
			_musicToggleSwitch.addEventListener(Event.CHANGE, onSwitchMusic);
			_savedMusicChoice = _musicToggleSwitch.isSelected;
			
			_tutoToggleSwitch = new CustomToggleSwitch();
			_tutoToggleSwitch.onText = "";
			_tutoToggleSwitch.offText = "";
			_tutoToggleSwitch.onThumbText = _("Oui");
			_tutoToggleSwitch.offThumbText = _("Non");
			_tutoToggleSwitch.isSelected = MemberManager.getInstance().getDisplayTutorial();
			_tutoToggleSwitch.addEventListener(Event.CHANGE, onSwitchTuto);
			_savedTutoChoice = _tutoToggleSwitch.isSelected;
			
			_languagePicker = new PickerList();
			_languagePicker.dataProvider = new ListCollection( Storage.getInstance().getProperty( StorageConfig.PROPERTY_AVAILABLE_LANGUAGES) );
			for each(var languageData:LanguageData in _languagePicker.dataProvider.data)
			{
				if( languageData.key == Storage.getInstance().getProperty(StorageConfig.PROPERTY_LANGUAGE) )
				{
					_languagePicker.selectedItem = languageData;
					_savedLanguageChoice = languageData.id;
				}
			}
			_languagePicker.addEventListener(Event.CHANGE, onLanguageChanged);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.useVirtualLayout = false;
			vlayout.manageVisibility = true;
			
			_list = new List();
			_list.isSelectable = false;
			_list.layout = vlayout;
			_list.itemRendererType = SettingItemRenderer;
			_list.dataProvider = new ListCollection( [ { title:_("Sons"),     value:"", accessory:_soundToggleSwitch },
													   { title:_("Musique"),  value:"", accessory:_musicToggleSwitch },
													   { title:_("Tutoriel"), value:"", accessory:_tutoToggleSwitch },
													   { title:_("Langage"),  value:"", accessory:_languagePicker }
												      ] );
			addChild(_list);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( !AbstractGameInfo.LANDSCAPE )
				{
					_logo.x = (actualWidth - _logo.width) * 0.5;
					_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
					
					_listShadow.y = _logo.y + _logo.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
					_listShadow.width = this.actualWidth;
				}
				
				_list.y = AbstractGameInfo.LANDSCAPE ? 0 : (_listShadow.y + _listShadow.height);
				_list.width = actualWidth;
				_list.height = actualHeight - _list.y;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onSwitchSound(event:Event):void
		{
			Storage.getInstance().setProperty(StorageConfig.PROPERTY_SOUND_ENABLED, _soundToggleSwitch.isSelected);
			
			if( _soundToggleSwitch.isSelected )
				SoundManager.getInstance().unmutePlaylist("sfx", 1);
			else
				SoundManager.getInstance().mutePlaylist("sfx", 1);
		}
		
		private function onSwitchMusic(event:Event):void
		{
			Storage.getInstance().setProperty(StorageConfig.PROPERTY_MUSIC_ENABLED, _musicToggleSwitch.isSelected);
			
			if( _musicToggleSwitch.isSelected )
				SoundManager.getInstance().unmutePlaylist("music", 1);
			else
				SoundManager.getInstance().mutePlaylist("music", 1);
		}
		
		private function onSwitchTuto(event:Event):void
		{
			MemberManager.getInstance().setDisplayTutorial(_tutoToggleSwitch.isSelected);
		}
		
		private function onLanguageChanged(event:Event):void
		{
			LanguageManager.getInstance().lang = (_languagePicker.selectedItem as LanguageData).key;
			if( _list && _list.dataProvider )
			{
				for(var i:int = 0; i < _list.dataProvider.length; i++)
					_list.dataProvider.updateItemAt(i);
			}
			
			advancedOwner.dispatchEventWith(MobileEventTypes.UPDATE_HEADER_TITLE, false, _("Réglages"));
			
			_soundToggleSwitch.onThumbText = _("Oui");
			_soundToggleSwitch.offThumbText = _("Non");
			
			_musicToggleSwitch.onThumbText = _("Oui");
			_musicToggleSwitch.offThumbText = _("Non");
			
			_tutoToggleSwitch.onThumbText = _("Oui");
			_tutoToggleSwitch.offThumbText = _("Non");
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			// if some settings have changed and if we have an connection, we
			// need to save the data in the server for statistics purpose
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				// comprare data here
				var params:Object = {};
				var change:Boolean = false;
				
				if( LanguageData(_languagePicker.selectedItem).id != _savedLanguageChoice )
				{
					params.id_langue = LanguageData(_languagePicker.selectedItem).id;
					change = true;
					Flox.logInfo("\t\t&rarr;Changement du paramètre de langue : {0}", _( LanguageData(_languagePicker.selectedItem).translationKey ));
				}
				
				if( _savedSoundChoice != _soundToggleSwitch.isSelected )
				{
					params.activer_son = _soundToggleSwitch.isSelected;
					change = true;
					Flox.logInfo("\t\t&rarr;Changement du paramètre de Son : {0}", (_soundToggleSwitch.isSelected ? "Activé" : "Désactivé"));
				}
				
				if( _savedMusicChoice != _musicToggleSwitch.isSelected )
				{
					params.activer_musique = _musicToggleSwitch.isSelected;
					change = true;
					Flox.logInfo("\t\t&rarr;Changement du paramètre de Musique : {0}", (_musicToggleSwitch.isSelected ? "Activé" : "Désactivé"));
				}
				
				if( _savedTutoChoice != _tutoToggleSwitch.isSelected )
				{
					params.tutoriel = _tutoToggleSwitch.isSelected;
					change = true;
					Flox.logInfo("\t\t&rarr;Changement du paramètre du tutoriel en jeu : {0}", (_tutoToggleSwitch.isSelected ? "Activé" : "Désactivé"));
				}
				
				if( change )
				{
					Remote.getInstance().sendSettings(params, null, null, null, 2);
				}
			}
			
			if( _logo )
			{
				_logo.removeFromParent(true);
				_logo = null;
			}
			
			if( _listShadow )
			{
				_listShadow.removeFromParent(true);
				_listShadow = null;
			}
			
			_languagePicker.removeEventListener(Event.CHANGE, onLanguageChanged);
			_languagePicker.removeFromParent(true);
			_languagePicker = null;
			
			_soundToggleSwitch.removeEventListener(Event.CHANGE, onSwitchSound);
			_soundToggleSwitch.removeFromParent(true);
			_soundToggleSwitch = null;
			
			_musicToggleSwitch.removeEventListener(Event.CHANGE, onSwitchMusic);
			_musicToggleSwitch.removeFromParent(true);
			_musicToggleSwitch = null;
			
			_tutoToggleSwitch.removeEventListener(Event.CHANGE, onSwitchTuto);
			_tutoToggleSwitch.removeFromParent(true);
			_tutoToggleSwitch = null;
			
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
		
	}
}