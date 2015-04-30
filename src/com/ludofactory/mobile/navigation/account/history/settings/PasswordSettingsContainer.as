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
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.data.ListCollection;
	
	import starling.events.Event;
	
	public class PasswordSettingsContainer extends LayoutGroup
	{
		/**
		 * The new password control. */		
		private var _newPasswordControl:TextInput;
		/**
		 * The new password verification control. */		
		private var _newPasswordConfirmControl:TextInput;
		
		/**
		 * Save of mail informations. */		
		private var _connexionInformations:Object;
		
		/**
		 * The list. */		
		private var _list:List;
		
		public function PasswordSettingsContainer( data:Object )
		{
			super();
			
			_connexionInformations = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_newPasswordControl = new TextInput();
			_newPasswordControl.prompt = _("Nouveau mot de passe...");
			_newPasswordControl.textEditorProperties.displayAsPassword = true;
			
			_newPasswordConfirmControl = new TextInput();
			_newPasswordConfirmControl.prompt = _("Confirmer...");
			_newPasswordConfirmControl.textEditorProperties.displayAsPassword = true;
			
			_list = new List();
			_list.addEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.itemRendererType = AccountItemRenderer;
			_list.dataProvider = new ListCollection( [ { title:_("Nouveau"),         accessory:_newPasswordControl },
													   { title:_("Confirmation"), accessory:_newPasswordConfirmControl },
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
			
			_newPasswordControl.touchable = false;
			_newPasswordConfirmControl.touchable = false;
			
			if( _newPasswordControl.text == "" && _newPasswordConfirmControl.text == "" )
			{
				InfoManager.showTimed( _("Aucune donnée à mettre à jour."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				onUpdatePasswordComplete();
				return;
			}
			
			if( (_newPasswordControl.text == "" || _newPasswordConfirmControl.text == "") || (_newPasswordControl.text != _newPasswordConfirmControl.text) )
			{
				InfoManager.showTimed( _("Les mots de passe ne correspondent pas."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				onUpdatePasswordComplete();
				return;
			}
			
			paramObject.nouveau_mdp = _newPasswordConfirmControl.text;
			Remote.getInstance().accountUpdatePassword(paramObject, onUpdatePasswordComplete, onUpdatePasswordComplete, onUpdatePasswordComplete, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
		/**
		 * Password have been updated.
		 */		
		private function onUpdatePasswordComplete(result:Object = null):void
		{
			_newPasswordControl.touchable = true;
			_newPasswordConfirmControl.touchable = true;
			
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
			if( _newPasswordControl )
			{
				_newPasswordControl.removeFromParent(true);
				_newPasswordControl = null;
			}
			
			if( _newPasswordConfirmControl )
			{
				_newPasswordConfirmControl.removeFromParent(true);
				_newPasswordConfirmControl = null;
			}
			
			_list.removeEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.removeFromParent(true);
			_list = null;
			
			_connexionInformations = null;
			
			super.dispose();
		}
		
	}
}