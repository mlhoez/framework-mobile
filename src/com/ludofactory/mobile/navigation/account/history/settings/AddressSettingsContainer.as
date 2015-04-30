/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 5 nov. 2013
*/
package com.ludofactory.mobile.navigation.account.history.settings
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.navigation.highscore.CountryData;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.data.ListCollection;
	
	import starling.events.Event;
	
	public class AddressSettingsContainer extends LayoutGroup
	{
		/**
		 * The countries without the international element. */		
		private var _countriesWithoutInternational:Array;
		
		/**
		 * The address control. */		
		private var _addressControl:TextInput;
		/**
		 * The postal code control. */		
		private var _postalCodeControl:TextInput;
		/**
		 * The city control. */		
		private var _cityControl:TextInput;
		/**
		 * The country control. */		
		private var _countryControl:PickerList;
		/**
		 * The fixe phone number control. */		
		private var _fixePhoneNumber:TextInput;
		/**
		 * The mobile phone number control. */		
		private var _mobilePhoneNumber:TextInput;
		
		/**
		 * Save of address informations. */		
		private var _addressInformations:Object;
		
		/**
		 * The list. */		
		private var _list:List;
		
		public function AddressSettingsContainer( data:Object )
		{
			super();
			
			_addressInformations = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_countriesWithoutInternational = GlobalConfig.COUNTRIES.concat();
			_countriesWithoutInternational.shift();
			
			_addressControl = new TextInput();
			_addressControl.text = _addressInformations.adresse;
			
			_postalCodeControl = new TextInput();
			_postalCodeControl.text = _addressInformations.cp;
			
			_cityControl = new TextInput();
			_cityControl.text = _addressInformations.ville;
			
			_countryControl = new PickerList();
			_countryControl.dataProvider = new ListCollection( _countriesWithoutInternational );
			for each(var countryData:CountryData in _countryControl.dataProvider.data)
			{
				if( countryData.id == _addressInformations.pays )
					_countryControl.selectedItem = countryData;
			}
			
			_fixePhoneNumber = new TextInput();
			_fixePhoneNumber.text = _addressInformations.tel_fixe;
			
			_mobilePhoneNumber = new TextInput();
			_mobilePhoneNumber.text = _addressInformations.tel_port;
			
			_list = new List();
			_list.addEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.itemRendererType = AccountItemRenderer;
			_list.dataProvider = new ListCollection( [ { title:_("Adresse"),     accessory:_addressControl },
													   { title:_("Code postal"), accessory:_postalCodeControl },
													   { title:_("Ville"),       accessory:_cityControl },
													   { title:_("Pays"),        accessory:_countryControl },
													   { title:_("Tel. fixe"),   accessory:_fixePhoneNumber },
													   { title:_("Mobile"),      accessory:_mobilePhoneNumber },
													   { title:"",               isSaveButton:true } ] );
			addChild(_list);
		}
		
		override protected function draw():void
		{
			super.draw();
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the user request an update for a section.
		 */		
		private function onUpdateAccountSection(event:Event):void
		{
			var paramObject:Object = {};
			var change:Boolean = false;
			
			_addressControl.touchable = false;
			_postalCodeControl.touchable = false;
			_cityControl.touchable = false;
			_countryControl.touchable = false;
			_fixePhoneNumber.touchable = false;
			_mobilePhoneNumber.touchable = false;
			
			if( _addressInformations.adresse != _addressControl.text )
			{
				change = true;
				paramObject.adresse = _addressControl.text;
			}
			if( _addressInformations.cp != _postalCodeControl.text )
			{
				change = true;
				paramObject.cp = _postalCodeControl.text;
			}
			if( _addressInformations.ville != _cityControl.text )
			{
				change = true;
				paramObject.ville = _cityControl.text;
			}
			if( _addressInformations.pays != _countryControl.selectedItem.id )
			{
				change = true;
				paramObject.id_pays = _countryControl.selectedItem.id;
			}
			if( _addressInformations.tel_fixe != _fixePhoneNumber.text )
			{
				change = true;
				paramObject.tel_fixe = _fixePhoneNumber.text;
			}
			if( _addressInformations.tel_port != _mobilePhoneNumber.text )
			{
				change = true;
				paramObject.tel_port = _mobilePhoneNumber.text;
			}
			
			if( change )
				Remote.getInstance().accountUpdateAddressInformations(paramObject, onUpdateAddressComplete, onUpdateAddressComplete, onUpdateAddressComplete, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			else
			{
				InfoManager.showTimed(_("Aucune donnée à mettre à jour."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
				onUpdateAddressComplete();
			}
		}
		
		/**
		 * Address have been updated.
		 */		
		private function onUpdateAddressComplete(result:Object = null):void
		{
			_addressControl.touchable = true;
			_postalCodeControl.touchable = true;
			_cityControl.touchable = true;
			_countryControl.touchable = true;
			_fixePhoneNumber.touchable = true;
			_mobilePhoneNumber.touchable = true;
			
			((_list.viewPort as ListDataViewPort).getChildAt( (_list.viewPort as ListDataViewPort).numChildren - 1 ) as AccountItemRenderer).onUpdateComplete();
			
			if( InfoManager.isDisplaying )
			{
				if( result )
					InfoManager.hide("", InfoContent.ICON_NOTHING, 0, result ? InfoManager.showTimed:null, [result.txt, 60, true, InfoContent.ICON_NOTHING]);
			}
			else
			{
				if( result )
					InfoManager.showTimed(result.txt, 5, InfoContent.ICON_NOTHING);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _addressControl )
			{
				_addressControl.removeFromParent(true);
				_addressControl = null;
			}
			
			if( _postalCodeControl )
			{
				_postalCodeControl.removeFromParent(true);
				_postalCodeControl = null;
			}
			
			if( _cityControl )
			{
				_cityControl.removeFromParent(true);
				_cityControl = null;
			}
			
			if( _countryControl )
			{
				_countryControl.removeFromParent(true);
				_countryControl = null;
			}
			
			if( _fixePhoneNumber )
			{
				_fixePhoneNumber.removeFromParent(true);
				_fixePhoneNumber = null;
			}
			
			if( _mobilePhoneNumber )
			{
				_mobilePhoneNumber.removeFromParent(true);
				_mobilePhoneNumber = null;
			}
			
			_list.removeEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.removeFromParent(true);
			_list = null;
			
			if( _countriesWithoutInternational )
			{
				_countriesWithoutInternational.length = 0;
				_countriesWithoutInternational = null;
			}
			
			_addressInformations = null;
			
			super.dispose();
		}
	}
}