/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.core.notification.content
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	public class DisconnectNotificationContent extends AbstractPopupContent
	{
		/**
		 * The disconnect icon. */		
		private var _icon:Image;
		
		/**
		 * The title. */		
		private var _notificationTitle:TextField;
		
		/**
		 * The yes button. */		
		private var _yesButton:Button;
		
		/**
		 * The canel button. */		
		private var _cancelButton:Button;
		
		public function DisconnectNotificationContent()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			data = false;
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("icon-log-in-out") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			addChild(_icon);
			
			_notificationTitle = new TextField(10, 100, _("Voulez-vous vous déconnecter ?"), Theme.FONT_SANSITA, scaleAndRoundToDpi(50), Theme.COLOR_DARK_GREY);
			_notificationTitle.autoScale = AbstractGameInfo.LANDSCAPE;
			_notificationTitle.autoSize = AbstractGameInfo.LANDSCAPE ? TextFieldAutoSize.NONE : TextFieldAutoSize.VERTICAL;
			addChild(_notificationTitle);
			
			_yesButton = new Button();
			_yesButton.label = _("Oui");
			_yesButton.addEventListener(Event.TRIGGERED, onConfirm);
			addChild(_yesButton);
			
			_cancelButton = new Button();
			_cancelButton.label = _("Annuler");
			_cancelButton.styleName = Theme.BUTTON_BLUE;
			_cancelButton.addEventListener(Event.TRIGGERED, onCancel);
			addChild(_cancelButton);
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = this.actualWidth;
			if( AbstractGameInfo.LANDSCAPE )
			{
				_icon.x = roundUp((actualWidth - _icon.width) * 0.5);
				
				_yesButton.width = _cancelButton.width = this.actualWidth * 0.4;
				_yesButton.validate();
				
				_notificationTitle.y = _icon.y + _icon.height + scaleAndRoundToDpi(20);
				
				_yesButton.y = _cancelButton.y = _notificationTitle.y + _notificationTitle.height + scaleAndRoundToDpi(20);
				_yesButton.x = actualWidth * 0.5 + scaleAndRoundToDpi(5);
				_cancelButton.x = actualWidth * 0.5 - _cancelButton.width - scaleAndRoundToDpi(5);
				
				paddingTop = paddingBottom = scaleAndRoundToDpi(40);
			}
			else
			{
				_icon.x = roundUp((actualWidth - _icon.width) * 0.5);
				_yesButton.width = _cancelButton.width = this.actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
				_yesButton.x = _cancelButton.x = roundUp((actualWidth - _yesButton.width) * 0.5);
				
				_icon.y = scaleAndRoundToDpi(20);
				_notificationTitle.y = _icon.y + _icon.height + scaleAndRoundToDpi(20);
				_yesButton.y = _notificationTitle.y + _notificationTitle.height + scaleAndRoundToDpi(20);
				_cancelButton.y = _yesButton.y + _yesButton.height + scaleAndRoundToDpi(20);
				
				paddingBottom = scaleAndRoundToDpi(10);
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onConfirm(event:Event):void
		{
			data = true;
			close();
		}
		
		private function onCancel(event:Event):void
		{
			data = false;
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