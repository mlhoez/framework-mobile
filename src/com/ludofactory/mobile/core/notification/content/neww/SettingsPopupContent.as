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
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.mobile.core.controls.CustomToggleSwitch;
	import com.ludofactory.mobile.core.dispatcher;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.*;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.navigation.settings.LanguageData;
	import com.ludofactory.mobile.navigation.settings.SettingItemRenderer;
	
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.controls.ToggleSwitch;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	use namespace dispatcher;
	
	public class SettingsPopupContent extends AbstractPopupContent
	{
		/**
		 * The list. */
		private var _list:List;
		
		/**
		 * Sound toggle switch */
		private var _soundToggleSwitch:ToggleSwitch;
		/**
		 * Music toggle switch. */
		private var _musicToggleSwitch:ToggleSwitch;
		/**
		 * Music toggle switch. */
		private var _tutoToggleSwitch:ToggleSwitch;
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
		
		public function SettingsPopupContent()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			data = false;
			
			// reset alerts for new languages
			Storage.getInstance().setProperty(StorageConfig.PROPERTY_NEW_LANGUAGES, []);
			//dispatcher.dispatchEventWith(MobileEventTypes.ALERT_COUNT_UPDATED);
			
			_soundToggleSwitch = new ToggleSwitch();
			_soundToggleSwitch.onText = "xvxc";
			_soundToggleSwitch.offText = "dqsd";
			//_soundToggleSwitch.onThumbText = _("Oui");
			//_soundToggleSwitch.offThumbText = _("Non");
			_soundToggleSwitch.thumbProperties.isEnabled = false;
			_soundToggleSwitch.isSelected = Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED));
			_soundToggleSwitch.addEventListener(Event.CHANGE, onSwitchSound);
			_savedSoundChoice = _soundToggleSwitch.isSelected;
			
			_musicToggleSwitch = new ToggleSwitch();
			_musicToggleSwitch.onText = "";
			_musicToggleSwitch.offText = "";
			//_musicToggleSwitch.onThumbText = _("Oui");
			//_musicToggleSwitch.offThumbText = _("Non");
			_musicToggleSwitch.isSelected = Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED));
			_musicToggleSwitch.addEventListener(Event.CHANGE, onSwitchMusic);
			_savedMusicChoice = _musicToggleSwitch.isSelected;
			
			_tutoToggleSwitch = new ToggleSwitch();
			_tutoToggleSwitch.onText = "";
			_tutoToggleSwitch.offText = "";
			//_tutoToggleSwitch.onThumbText = _("Oui");
			//_tutoToggleSwitch.offThumbText = _("Non");
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
			_list.width = this.actualWidth;
			_list.validate();
			if(_list.height > CustomPopupManager.maxContentHeight)
					_list.height = CustomPopupManager.maxContentHeight;
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
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
			
			// TODO A remettre
			//advancedOwner.dispatchEventWith(MobileEventTypes.UPDATE_HEADER_TITLE, false, _("Réglages"));
			
			//_soundToggleSwitch.onThumbText = _("Oui");
			//_soundToggleSwitch.offThumbText = _("Non");
			
			//_musicToggleSwitch.onThumbText = _("Oui");
			//_musicToggleSwitch.offThumbText = _("Non");
			
			//_tutoToggleSwitch.onThumbText = _("Oui");
			//_tutoToggleSwitch.offThumbText = _("Non");
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
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