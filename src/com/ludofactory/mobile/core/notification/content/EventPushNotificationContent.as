/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 10 oct. 2013
*/
package com.ludofactory.mobile.core.notification.content
{

	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.freshplanet.nativeExtensions.PushNotification;
	import com.freshplanet.nativeExtensions.PushNotificationEvent;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.notification.AbstractNotificationPopupContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.layout.VerticalLayout;

	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import starling.display.Image;
	import starling.events.Event;

	public class EventPushNotificationContent extends AbstractNotificationPopupContent
	{
		/**
		 * The disconnect icon. */		
		private var _icon:Image;
		
		/**
		 * The title. */		
		private var _notificationTitle:Label;
		
		/**
		 * The title. */		
		private var _message:Label;
		
		/**
		 * The yes button. */		
		private var _yesButton:Button;
		
		/**
		 * The canel button. */		
		private var _cancelButton:Button;
		
		private var _completeScreenId:String;
		
		public function EventPushNotificationContent(completeScreenId:String)
		{
			super();
			
			_completeScreenId = completeScreenId;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 30:50 );
			this.layout = layout;
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("icon-mail") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			addChild(_icon);
			
			_notificationTitle = new Label();
			_notificationTitle.text = _("Soyez avertis !");
			addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 44 : 60), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_message = new Label();
			_message.text = _("Soyez immédiatement informé en cas de dépassement dans un tournoi en activant les notifications de cette application.\n\nVous pourrez changer ce paramètre plus tard dans la partie Mon Compte du menu.");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 38), Theme.COLOR_DARK_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			
			_yesButton = new Button();
			_yesButton.label = _("Activer");
			_yesButton.addEventListener(Event.TRIGGERED, onConfirm);
			addChild(_yesButton);
			
			_cancelButton = new Button();
			_cancelButton.label = _("Plus tard");
			_cancelButton.styleName = Theme.BUTTON_BLUE;
			_cancelButton.addEventListener(Event.TRIGGERED, onCancel);
			addChild(_cancelButton);
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = _message.width = this.actualWidth * 0.9;
			_yesButton.width = _cancelButton.width = this.actualWidth * 0.8;
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onConfirm(event:Event):void
		{
			// default is false, because we don't want to prompt the popup at the very first launch
			// of the application (in this case we have much more chance that the player will refuse
			// to subscribe the push notification). Here he does it by itself so we can change the
			// boolean to true so that we can request a token at launch now. Later we don't care if
			// he disables the push notification in the iOS Settings, we will request a token anyway.
			Storage.getInstance().setProperty( StorageConfig.PROPERTY_PUSH_INITIALIZED, true );
			PushNotification.getInstance().addEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
			PushNotification.getInstance().addEventListener(PushNotificationEvent.PERMISSION_REFUSED_EVENT, onPermissionRefused);
			PushNotification.getInstance().registerForPushNotification(AbstractGameInfo.GCM_SENDER_ID);
		}
		
		/**
		 * The permission have been given, let's send the token to
		 * our server if connected to Internet.
		 */		
		private function onPermissionGiven(event:PushNotificationEvent):void
		{
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_REFUSED_EVENT, onPermissionRefused);
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				// no need callbacks
				Remote.getInstance().accountUpdateNotifications({ etat:1 }, null, null, null, 2);
				Remote.getInstance().updatePushToken(event.token, null, null, null, 2);
			}
			AbstractEntryPoint.screenNavigator.showScreen(_completeScreenId);
			close();
		}
		
		private function onPermissionRefused(event:PushNotificationEvent):void
		{
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_REFUSED_EVENT, onPermissionRefused);
			AbstractEntryPoint.screenNavigator.showScreen(_completeScreenId);
			close();
		}
		
		private function onCancel(event:Event):void
		{
			AbstractEntryPoint.screenNavigator.showScreen(_completeScreenId);
			close();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_icon.removeFromParent(true);
			_icon = null;
			
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_yesButton.removeEventListener(Event.TRIGGERED, onConfirm);
			_yesButton.removeFromParent(true);
			_yesButton = null;
			
			_cancelButton.removeEventListener(Event.TRIGGERED, onCancel);
			_cancelButton.removeFromParent(true);
			_cancelButton = null;
			
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_REFUSED_EVENT, onPermissionRefused);
			
			super.dispose();
		}
	}
}