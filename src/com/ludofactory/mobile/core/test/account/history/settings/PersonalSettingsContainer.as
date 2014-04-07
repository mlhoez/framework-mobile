/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 5 nov. 2013
*/
package com.ludofactory.mobile.core.test.account.history.settings
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.model.MonthData;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	
	import starling.events.Event;
	
	public class PersonalSettingsContainer extends LayoutGroup
	{
		/**
		 * The years, generated from the current year to less 100 years. */		
		private var _generatedYears:Vector.<int>  = new Vector.<int>();
		
		/**
		 * The id control. */		
		private var _idControl:Label;
		/**
		 * The title control. */		
		private var _titleControl:PickerList;
		/**
		 * The last name control. */		
		private var _lastNameControl:TextInput;
		/** 
		 * The first name control. */		
		private var _firstNameControl:TextInput;
		/**
		 * The birthday day control. */		
		private var _birthdayDayControl:PickerList;
		/**
		 * The birthday month control. */		
		private var _birthdayMonthControl:PickerList;
		/**
		 * The birthday year control. */		
		private var _birthdayYearControl:PickerList;
		/**
		 * The birthday container. */		
		private var _birthdayContainer:ScrollContainer;
		
		/**
		 * Save of personal informations. */		
		private var _personalInformations:Object;
		
		/**
		 * The list. */		
		private var _list:List;
		
		public function PersonalSettingsContainer( data:Object )
		{
			super();
			
			_personalInformations = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			if( _personalInformations.date_naissance != "" )
			{
				var uyear:int  = int( (_personalInformations.date_naissance as String).split("-")[0] );
				var umonth:int = int( (_personalInformations.date_naissance as String).split("-")[1] );
				var uday:int   = int( (_personalInformations.date_naissance as String).split("-")[2] );
			}
			
			const year:Number = new Date().getFullYear();
			for(var i:int = year; i >= (year - 100); i--)
				_generatedYears.push(i);
			
			
			var tab:Array = [];
			if( tab.indexOf( Localizer.getInstance().translate("Mr.") ) == -1 )
				tab.push( Localizer.getInstance().translate("Mr.") );
			if( tab.indexOf( Localizer.getInstance().translate("Mme.") ) == -1 )
				tab.push( Localizer.getInstance().translate("Mme.") );
			if( tab.indexOf( Localizer.getInstance().translate("Mlle.") ) == -1 )
				tab.push( Localizer.getInstance().translate("Mlle.") );
				
			_titleControl = new PickerList();
			_titleControl.dataProvider = new ListCollection( tab );
			_titleControl.typicalItem = Localizer.getInstance().translate("Mme.");
			if( _personalInformations.titre != "" )
				_titleControl.selectedItem = Localizer.getInstance().translate(_personalInformations.titre);
			
			_idControl = new Label();
			_idControl.text = "" + MemberManager.getInstance().getId();
			
			_lastNameControl = new TextInput();
			_lastNameControl.text = _personalInformations.nom;
			
			_firstNameControl = new TextInput();
			_firstNameControl.text = _personalInformations.prenom;
			
			const hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.gap = scaleAndRoundToDpi(10);
			_birthdayContainer = new ScrollContainer();
			_birthdayContainer.layout = hlayout;
			
			_birthdayDayControl = new PickerList();
			_birthdayDayControl.dataProvider = new ListCollection( GlobalConfig.DAYS );
			_birthdayDayControl.typicalItem = 991;
			if( uday )
				_birthdayDayControl.selectedItem = uday;
			_birthdayContainer.addChild( _birthdayDayControl );
			
			_birthdayMonthControl = new PickerList();
			_birthdayMonthControl.dataProvider = new ListCollection( GlobalConfig.MONTHS );
			_birthdayMonthControl.typicalItem = "salut";
			for each(var monthData:MonthData in _birthdayMonthControl.dataProvider.data)
			{
				if( monthData.id == umonth )
					_birthdayMonthControl.selectedItem = monthData;
			}
			_birthdayContainer.addChild( _birthdayMonthControl );
			
			_birthdayYearControl = new PickerList();
			_birthdayYearControl.dataProvider = new ListCollection( _generatedYears );
			_birthdayYearControl.typicalItem = 99991;
			if( uyear )
				_birthdayYearControl.selectedItem = uyear;
			_birthdayContainer.addChild( _birthdayYearControl );
			
			_list = new List();
			_list.addEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.itemRendererType = AccountItemRenderer;
			_list.dataProvider = new ListCollection( [ { title:Localizer.getInstance().translate("ACCOUNT.ID"),         accessory:_idControl },
													   { title:Localizer.getInstance().translate("ACCOUNT.TITLE"),      accessory:_titleControl },
													   { title:Localizer.getInstance().translate("ACCOUNT.LAST_NAME"),  accessory:_lastNameControl },
													   { title:Localizer.getInstance().translate("ACCOUNT.FIRST_NAME"), accessory:_firstNameControl },
													   { title:Localizer.getInstance().translate("ACCOUNT.BIRTHDAY"),   accessory:_birthdayContainer },
													   { title:"",   isSaveButton:true } ] );
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
			
			_titleControl.touchable = false;
			_lastNameControl.touchable = false;
			_firstNameControl.touchable = false;
			_birthdayContainer.touchable = false;
			
			if( _personalInformations.titre != _titleControl.selectedItem )
			{
				change = true;
				var fakeTab:Array = [ "Mr.", "Mme", "Mlle." ];
				paramObject.titre = fakeTab[_titleControl.selectedIndex];
			}
			if( _personalInformations.nom != _lastNameControl.text )
			{
				change = true;
				paramObject.nom = _lastNameControl.text;
			}
			if( _personalInformations.prenom != _firstNameControl.text )
			{
				change = true;
				paramObject.prenom = _firstNameControl.text;
			}
			if( _personalInformations.date_naissance != _birthdayYearControl.selectedItem + "-" + (MonthData(_birthdayMonthControl.selectedItem).id < 10 ? ("0" + MonthData(_birthdayMonthControl.selectedItem).id):MonthData(_birthdayMonthControl.selectedItem).id) + "-" + (_birthdayDayControl.selectedItem < 10 ? ("0"+_birthdayDayControl.selectedItem):_birthdayDayControl.selectedItem) )
			{
				change = true;
				paramObject.date_naissance = _birthdayYearControl.selectedItem + "-" + (MonthData(_birthdayMonthControl.selectedItem).id < 10 ? ("0" + MonthData(_birthdayMonthControl.selectedItem).id):MonthData(_birthdayMonthControl.selectedItem).id) + "-" + (_birthdayDayControl.selectedItem < 10 ? ("0"+_birthdayDayControl.selectedItem):_birthdayDayControl.selectedItem);
			}
			
			if( change )
				Remote.getInstance().accountUpdatePersonalInformations(paramObject, onUpdatePersonalInformationComplete, onUpdatePersonalInformationComplete, onUpdatePersonalInformationComplete, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("ACCOUNT.NO_CHANGE"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
				onUpdatePersonalInformationComplete();
			}
		}
		
		/**
		 * Personal informations have been updated.
		 */		
		private function onUpdatePersonalInformationComplete(result:Object = null):void
		{
			_titleControl.touchable = true;
			_lastNameControl.touchable = true;
			_firstNameControl.touchable = true;
			_birthdayContainer.touchable = true;
			
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
			_generatedYears.length = 0;
			_generatedYears = null;
			
			if( _idControl )
			{
				_idControl.removeFromParent(true);
				_idControl = null;
			}
			
			if( _titleControl )
			{
				_titleControl.removeFromParent(true);
				_titleControl = null;
			}
			
			if( _lastNameControl )
			{
				_lastNameControl.removeFromParent(true);
				_lastNameControl = null;
			}
			
			if( _firstNameControl )
			{
				_firstNameControl.removeFromParent(true);
				_firstNameControl = null;
			}
			
			if( _birthdayDayControl )
			{
				_birthdayDayControl.removeFromParent(true);
				_birthdayDayControl = null;
			}
			
			if( _birthdayMonthControl )
			{
				_birthdayMonthControl.removeFromParent(true);
				_birthdayMonthControl = null;
			}
			
			if( _birthdayYearControl )
			{
				_birthdayYearControl.removeFromParent(true);
				_birthdayYearControl = null;
			}
			
			if( _birthdayContainer )
			{
				_birthdayContainer.removeFromParent(true);
				_birthdayContainer = null;
			}
			
			_list.removeEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.removeFromParent(true);
			_list = null;
			
			_personalInformations = null;
			
			super.dispose();
		}
	}
}