/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 5 nov. 2013
*/
package com.ludofactory.mobile.navigation.account.history.settings
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.navigation.highscore.CountryData;
	
	import feathers.controls.Label;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.data.ListCollection;
	
	import starling.events.Event;
	
	public class PseudoSettingsContainer extends LayoutGroup
	{
		/**
		 * The countries without the international element. */		
		//private var _countriesWithoutInternational:Array;
		
		/**
		 * The pseudo control. */		
		private var _pseudoControlCanBeModified:TextInput;
		
		/**
		 * The id control. */
		private var _pseudoControlCannotBeModified:Label;
		/**
		 * The pseudo country control. */		
		//private var _countryPseudoControl:PickerList;
		
		/**
		 * Save of pseudo informations. */		
		private var _pseudoInformations:Object;
		
		/**
		 * The list. */		
		private var _list:List;
		
		public function PseudoSettingsContainer( data:Object )
		{
			super();
			
			_pseudoInformations = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			//_countriesWithoutInternational = GlobalConfig.COUNTRIES.concat();
			//_countriesWithoutInternational.shift();
			
			_pseudoControlCanBeModified = new TextInput();
			_pseudoControlCanBeModified.text = _pseudoInformations.pseudo;
			_pseudoControlCanBeModified.textEditorProperties.maxChars = 25;
			
			_pseudoControlCannotBeModified = new Label();
			_pseudoControlCannotBeModified.text = _pseudoInformations.pseudo;
			
			//_countryPseudoControl = new PickerList();
			//_countryPseudoControl.dataProvider = new ListCollection( _countriesWithoutInternational );
			//for each(var countryData:CountryData in _countryPseudoControl.dataProvider.data)
			//{
			//	if( countryData.id == _pseudoInformations.pays )
			//		_countryPseudoControl.selectedItem = countryData;
			//}
			
			_list = new List();
			_list.addEventListener(MobileEventTypes.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.itemRendererType = AccountItemRenderer;
			
			if(_pseudoInformations.modify == true)
			{
				_list.dataProvider = new ListCollection( [ { title:_("Pseudo"),         accessory:_pseudoControlCanBeModified },
														   //{ title:_("Pays associé"), accessory:_countryPseudoControl },
														   { title:"",   isSaveButton:true } ] );
			}
			else
			{
				_list.dataProvider = new ListCollection( [ { title:_("Pseudo"),  accessory:_pseudoControlCannotBeModified } ] );
			}
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
			
			_pseudoControlCanBeModified.touchable = false;
			//_countryPseudoControl.touchable = false;
			
			paramObject.pseudo = _pseudoControlCanBeModified.text;
			//paramObject.id_pays = _countryPseudoControl.selectedItem.id;
			
			Remote.getInstance().accountUpdatePseudo(paramObject, onUpdatePseudoComplete, onUpdatePseudoComplete, onUpdatePseudoComplete, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
		/**
		 * Pseudo have been updated.
		 */		
		private function onUpdatePseudoComplete(result:Object = null):void
		{
			_pseudoControlCanBeModified.touchable = true;
			//_countryPseudoControl.touchable = true;
			
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
			
			if( result && result.hasOwnProperty("obj_membre_mobile") && result.obj_membre_mobile.hasOwnProperty("pseudo") )
				_pseudoControlCanBeModified.text = result.obj_membre_mobile.pseudo;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _pseudoControlCanBeModified )
			{
				_pseudoControlCanBeModified.removeFromParent(true);
				_pseudoControlCanBeModified = null;
			}
			
			if( _pseudoControlCannotBeModified )
			{
				_pseudoControlCannotBeModified.removeFromParent(true);
				_pseudoControlCannotBeModified = null;
			}
			
			//if( _countryPseudoControl )
			//{
			//	_countryPseudoControl.removeFromParent(true);
			//	_countryPseudoControl = null;
			//}
			
			_list.removeEventListener(MobileEventTypes.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.removeFromParent(true);
			_list = null;
			
			//if( _countriesWithoutInternational )
			//{
			//	_countriesWithoutInternational.length = 0;
			//	_countriesWithoutInternational = null;
			//}
			
			_pseudoInformations = null;
			
			super.dispose();
		}
	}
}