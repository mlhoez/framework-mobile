/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.navigation.menu
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import AbstractNotification;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.events.Event;
	
	public class DisconnectNotification extends AbstractNotification
	{
		/**
		 * The disconnect icon. */		
		private var _icon:Image;
		
		/**
		 * The title. */		
		private var _notificationTitle:Label;
		
		/**
		 * The yes button. */		
		private var _yesButton:Button;
		
		/**
		 * The canel button. */		
		private var _cancelButton:Button;
		
		public function DisconnectNotification()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 10:40):(AbstractGameInfo.LANDSCAPE ? 40:60) );
			_container.layout = layout;
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("icon-log-in-out") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_icon);
			
			_notificationTitle = new Label();
			_notificationTitle.text = _("Voulez-vous vous déconnecter ?");
			_container.addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_yesButton = new Button();
			_yesButton.label = _("Oui");
			_yesButton.addEventListener(Event.TRIGGERED, onConfirm);
			_container.addChild(_yesButton);
			
			_cancelButton = new Button();
			_cancelButton.label = _("Annuler");
			_cancelButton.styleName = Theme.BUTTON_BLUE;
			_cancelButton.addEventListener(Event.TRIGGERED, onCancel);
			_container.addChild(_cancelButton);
		}
		
		override protected function draw():void
		{
			_container.width = this.actualWidth - padSide * 2;
			_container.x = padSide;
			
			_notificationTitle.width = _container.width * (GlobalConfig.isPhone ? 0.8 : 0.6);
			if( AbstractGameInfo.LANDSCAPE )
				_yesButton.width = _cancelButton.width = _container.width * (GlobalConfig.isPhone ? 0.6 : 0.4);
			else
				_yesButton.width = _cancelButton.width = _container.width * (GlobalConfig.isPhone ? 0.8 : 0.6);
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onConfirm(event:Event):void
		{
			_data = true;
			onClose();
		}
		
		private function onCancel(event:Event):void
		{
			onClose();
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