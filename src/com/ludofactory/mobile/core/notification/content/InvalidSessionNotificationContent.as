/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 24 sept. 2013
*/
package com.ludofactory.mobile.core.notification.content
{

	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.*;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.notification.AbstractNotificationPopupContent;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.layout.VerticalLayout;

	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import starling.display.Image;
	import starling.events.Event;

	public class InvalidSessionNotificationContent extends AbstractNotificationPopupContent
	{
		/**
		 * The disconnect icon. */		
		private var _icon:Image;
		
		/**
		 * The title. */		
		private var _notificationTitle:Label;
		
		/**
		 * The message. */		
		private var _message:Label;
		
		/**
		 * The yes button. */		
		private var _yesButton:Button;
		
		/**
		 * The canel button. */		
		private var _cancelButton:Button;
		
		public function InvalidSessionNotificationContent()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 40:60 );
			this.layout = layout;
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("icon-cross") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			addChild(_icon);
			
			_notificationTitle = new Label();
			_notificationTitle.text = _("Vous avez été déconnecté.");
			addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 44 : 60), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_message = new Label();
			_message.text = _("Vous avez été automatiquement déconnecté car vous avez probablement changé vos identifiants de connexion sur un autre appareil.\n\nMerci de vous identifier à nouveau.");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 38), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_yesButton = new Button();
			_yesButton.label = _("Allons-y !");
			_yesButton.addEventListener(Event.TRIGGERED, onConfirm);
			addChild(_yesButton);
			
			_cancelButton = new Button();
			_cancelButton.label = _("Plus tard...");
			_cancelButton.styleName = Theme.BUTTON_BLUE;
			_cancelButton.addEventListener(Event.TRIGGERED, onCancel);
			addChild(_cancelButton);
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = this.actualWidth;
			_message.width = this.actualWidth * 0.9;
			_yesButton.width = _cancelButton.width = this.actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onConfirm(event:Event):void
		{
			AuthenticationManager.startAuthenticationProcess(AbstractEntryPoint.screenNavigator, AbstractEntryPoint.screenNavigator.activeScreenID);
			close();
		}
		
		private function onCancel(event:Event):void
		{
			AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.HOME_SCREEN );
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
			
			super.dispose();
		}
	}
}