/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 10 oct. 2013
*/
package com.ludofactory.mobile.core.notification.content
{

	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.notification.AbstractNotificationPopupContent;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.navigation.event.EventData;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.layout.VerticalLayout;

	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.formatString;

	public class RateNotificationContent extends AbstractNotificationPopupContent
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
		 * The vent data. */		
		private var _eventData:EventData;
		
		public function RateNotificationContent( data:EventData )
		{
			super();
			
			_eventData = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 40:60 );
			this.layout = layout;
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("rate-icon") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			addChild(_icon);
			
			_notificationTitle = new Label();
			_notificationTitle.text = _("Donnez-nous une note !");
			addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_message = new Label();
			_message.text = _("Vous aimez notre jeu ?\nAidez-nous à le faire connaître en lui donnant une note !");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_DARK_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			
			_yesButton = new Button();
			_yesButton.label = formatString(_("Noter {0}"), AbstractGameInfo.GAME_NAME);
			_yesButton.addEventListener(Event.TRIGGERED, onConfirm);
			addChild(_yesButton);
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = _message.width = this.actualWidth * 0.9;
			_yesButton.width = this.actualWidth * 0.8;
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onConfirm(event:Event):void
		{
			if( _eventData.link != "" )
				navigateToURL( new URLRequest( _eventData.link ) );
			close();
		}
		
		private function onCancel(event:Event):void
		{
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
			
			_eventData = null;
			
			super.dispose();
		}
	}
}