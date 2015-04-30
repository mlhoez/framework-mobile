/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 5 nov. 2013
*/
package com.ludofactory.mobile.navigation.account.history.settings
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.data.ListCollection;
	
	import starling.events.Event;
	
	public class EmailSettingsContainer extends LayoutGroup
	{
		/**
		 * The mail control. */		
		private var _emailControl:TextInput;
		
		/**
		 * Save of mail informations. */		
		private var _connexionInformations:Object;
		
		/**
		 * The list. */		
		private var _list:List;
		
		public function EmailSettingsContainer( data:Object )
		{
			super();
			
			_connexionInformations = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_emailControl = new TextInput();
			_emailControl.text = _connexionInformations.mail;
			
			_list = new List();
			_list.addEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.itemRendererType = AccountItemRenderer;
			_list.dataProvider = new ListCollection( [ { title:_("Email"), accessory:_emailControl },
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
			
			_emailControl.touchable = false;
			
			if(_emailControl.text == "" || !Utilities.isValidMail(_emailControl.text))
			{
				InfoManager.showTimed( _("Email invalide."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				onUpdateMailComplete();
				return;
			}
			
			if( _connexionInformations.mail != _emailControl.text )
			{
				change = true;
				paramObject.nouveau_mail = Utilities.isValidMail(_emailControl.text);
			}
			
			if( change )
				Remote.getInstance().accountUpdateMail(paramObject, onUpdateMailComplete, onUpdateMailComplete, onUpdateMailComplete, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			else
			{
				InfoManager.showTimed(_("Aucune donnée à mettre à jour."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
				onUpdateMailComplete();
			}
		}
		
		/**
		 * Email have been updated.
		 */		
		private function onUpdateMailComplete(result:Object = null):void
		{
			_emailControl.touchable = true;
			
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
			if( _emailControl )
			{
				_emailControl.removeFromParent(true);
				_emailControl = null;
			}
			
			_list.removeEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.removeFromParent(true);
			_list = null;
			
			_connexionInformations = null;
			
			super.dispose();
		}
	}
}