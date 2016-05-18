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
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobileNew.core.analytics.Analytics;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	
	public class EventPushNotificationContent extends AbstractPopupContent
	{
		/**
		 * The disconnect icon. */		
		private var _icon:Image;
		
		/**
		 * The title. */		
		private var _notificationTitle:TextField;
		
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
			
			/*const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 30:50 );
			this.layout = layout;*/
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("icon-mail") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			addChild(_icon);
			
			_notificationTitle = new TextField(5, scaleAndRoundToDpi(50), _("Soyez avertis !"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 44 : 60), Theme.COLOR_DARK_GREY));
			addChild(_notificationTitle);
			
			_message = new Label();
			_message.text = _("Soyez immédiatement informé en cas de dépassement dans un tournoi en activant les notifications !\n\nVous pourrez changer ce paramètre plus tard dans la partie Mon Compte du menu.");
			addChild(_message);
			//_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 34), Theme.COLOR_DARK_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			
			_yesButton = new Button();
			_yesButton.label = _("Activer");
			_yesButton.addEventListener(Event.TRIGGERED, onConfirm);
			addChild(_yesButton);
			
			_cancelButton = new Button();
			_cancelButton.label = _("Plus tard");
			//_cancelButton.styleName = Theme.BUTTON_BLUE;
			_cancelButton.addEventListener(Event.TRIGGERED, onCancel);
			addChild(_cancelButton);
		}
		
		override protected function draw():void
		{
			_icon.y = scaleAndRoundToDpi(10);
			
			if(AbstractGameInfo.LANDSCAPE)
			{
				_notificationTitle.height = _icon.height;
				_notificationTitle.autoScale = false;
				_notificationTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				_icon.x = (actualWidth - _icon.width - _notificationTitle.width - scaleAndRoundToDpi(20)) * 0.5;
				//_notificationTitle.autoScale = true;
				//_notificationTitle.autoSize = TextFieldAutoSize.NONE;
				_notificationTitle.x = _icon.x + _icon.width + scaleAndRoundToDpi(20);
				_notificationTitle.y = _icon.y + ((_icon.height - _notificationTitle.height) * 0.5);
				
				_message.width = actualWidth;
				_message.validate();
				_message.y = _icon.y + _icon.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50);
				
				_yesButton.validate();
				_cancelButton.validate();
				_yesButton.width = _cancelButton.width = actualWidth * 0.5;
				_yesButton.y = _cancelButton.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50);
				_yesButton.x = (actualWidth - _yesButton.width - _cancelButton.width - scaleAndRoundToDpi(5)) * 0.5;
				_cancelButton.x = _yesButton.x + _yesButton.width + scaleAndRoundToDpi(5);
			}
			else
			{
				_notificationTitle.autoSize = TextFieldAutoSize.VERTICAL;
				
				_icon.x = (this.actualWidth - _icon.width) * 0.5;
				_notificationTitle.width = _message.width = this.actualWidth;
				_notificationTitle.y = _icon.y + _icon.height + scaleAndRoundToDpi(10);
				
				_message.validate();
				_message.y = _notificationTitle.y + _notificationTitle.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				
				_yesButton.validate();
				_cancelButton.validate();
				_yesButton.width = _cancelButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
				_yesButton.x = _cancelButton.x = (actualWidth +- _yesButton.width) * 0.5;
				_yesButton.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				_cancelButton.y = _yesButton.y + _yesButton.height + scaleAndRoundToDpi(10);
			}
			//hfg
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
			
			Analytics.trackEvent("Popup activation notifications push", "Activation");
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
				Remote.getInstance().accountUpdateNotifications({ etat:1 }, null, null, null, 1);
				Remote.getInstance().updatePushToken(event.token, null, null, null, 1);
			}
			AbstractEntryPoint.screenNavigator.replaceScreen(_completeScreenId);
			close();
		}
		
		private function onPermissionRefused(event:PushNotificationEvent):void
		{
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_REFUSED_EVENT, onPermissionRefused);
			AbstractEntryPoint.screenNavigator.replaceScreen(_completeScreenId);
			close();
		}
		
		private function onCancel(event:Event):void
		{
			Analytics.trackEvent("Popup activation notifications push", "Annulation");
			AbstractEntryPoint.screenNavigator.replaceScreen(_completeScreenId);
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