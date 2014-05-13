/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 5 nov. 2013
*/
package com.ludofactory.mobile.core.test.account.history.settings
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.freshplanet.nativeExtensions.PushNotification;
	import com.freshplanet.nativeExtensions.PushNotificationEvent;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.controls.CustomToggleSwitch;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	public class NotificationSettingsContainer extends LayoutGroup
	{
		/**
		 * Whether the push notification are enabled. */		
		private var _globalPushControl:CustomToggleSwitch;
		
		/**
		 * Save of push informations. */		
		private var _pushInformations:Object;
		
		/**
		 * The list. */		
		private var _list:List;
		
		public function NotificationSettingsContainer( data:Object )
		{
			super();
			
			_pushInformations = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_globalPushControl = new CustomToggleSwitch();
			_globalPushControl.onText = "";
			_globalPushControl.offText = "";
			_globalPushControl.onThumbText = _("Oui");
			_globalPushControl.offThumbText = _("Non");
			_globalPushControl.isSelected = _pushInformations == 0 ? false : true;
			_globalPushControl.addEventListener(Event.CHANGE, onSwitchPush);
			
			var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.hasVariableItemDimensions = true;
			
			_list = new List();
			_list.layout = vlayout;
			//_list.addEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.itemRendererType = AccountItemRenderer;
			if( GlobalConfig.ios )
			{
				_list.dataProvider = new ListCollection( [ { title:_("Activation"), accessory:_globalPushControl, helpTextTranslation:_("Vous ne recevez pas de notifications malgré l'option activée ?\n\nAssurez-vous que celle-ci est autorisée à les recevoir en allant dans l'application « Réglages » puis « Centre de notifications ».\n\nSélectionnez {0}, activez l'option « Dans Centre de notifications » et choisissez un style d'alerte.") }/*,
														   { title:"",   isSaveButton:true }*/] );
			}
			else
			{
				_list.dataProvider = new ListCollection( [ { title:_("Activation"), accessory:_globalPushControl }/*,
														   { title:"",   isSaveButton:true }*/] );
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
		/*private function onUpdateAccountSection(event:Event):void
		{
			var paramObject:Object = {};
			var change:Boolean = false;
			
			_globalPushControl.touchable = false;
			
			if( (_globalPushControl.isSelected ? 1 : 0) == _pushInformations )
			{
				AlertManager.showTimed( Localizer.getInstance().translate("ACCOUNT.NO_CHANGE"), AlertManager.DEFAULT_DISPLAY_TIME, true, ProgressPopup.SUCCESS_ICON_CROSS );
				onUpdatePushComplete();
				return;
			}
			
			paramObject.etat = _globalPushControl.isSelected ? 1 : 0;
			Remote.getInstance().accountUpdateNotifications(paramObject, onUpdatePushComplete, onUpdatePushComplete, onUpdatePushComplete, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
		}*/
		
		/**
		 * Push have been updated.
		 */		
		/*private function onUpdatePushComplete(result:Object = null):void
		{
			_globalPushControl.touchable = true;
			
			((_list.viewPort as ListDataViewPort).getChildAt( (_list.viewPort as ListDataViewPort).numChildren - 1 ) as AccountItemRenderer).onUpdateComplete();
			
			if( AlertManager.isDisplaying )
			{
				if( result )
					AlertManager.hide("", ProgressPopup.SUCCESS_ICON_NOTHING, 0, result ? AlertManager.showTimed:null, [result.txt, 60, true, ProgressPopup.SUCCESS_ICON_NOTHING]);
			}
			else
			{
				if( result )
					AlertManager.showTimed(result.txt, 5, true, ProgressPopup.SUCCESS_ICON_NOTHING);
			}
		}*/
		
		/**
		 * Request push in nay case.
		 */		
		private function onSwitchPush(event:Event):void
		{
			// default is false, because we don't want to prompt the popup at the very first launch
			// of the application (in this case we have much more chance that the player will refuse
			// to subscribe the push notification). Here he does it by itself so we can change the
			// boolean to true so that we can request a token at launch now. Later we don't care if
			// he disables the push notification in the iOS Settings, we will request a token anyway.
			Storage.getInstance().setProperty( StorageConfig.PROPERTY_PUSH_INITIALIZED, true );
			Remote.getInstance().accountUpdateNotifications({ etat:(_globalPushControl.isSelected ? 1 : 0) }, null, null, null, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			PushNotification.getInstance().addEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
			PushNotification.getInstance().registerForPushNotification(AbstractGameInfo.GCM_SENDER_ID);
		}
		
		/**
		 * The permission have been given, let's send the token to
		 * our server if connected to Internet.
		 */		
		private function onPermissionGiven(event:PushNotificationEvent):void
		{
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				// no need callbacks
				Remote.getInstance().updatePushToken(event.token, null, null, null, 2);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			// just in case
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
			
			if( _globalPushControl )
			{
				_globalPushControl.removeEventListener(Event.CHANGE, onSwitchPush);
				_globalPushControl.removeFromParent(true);
				_globalPushControl = null;
			}
			
			//_list.removeEventListener(LudoEventType.SAVE_ACCOUNT_INFORMATION, onUpdateAccountSection);
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}