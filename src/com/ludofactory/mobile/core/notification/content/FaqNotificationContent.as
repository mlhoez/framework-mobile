/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 2 sept. 2013
*/
package com.ludofactory.mobile.core.notification.content
{

	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.navigation.faq.*;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.Label;
	import feathers.layout.VerticalLayout;

	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class FaqNotificationContent extends AbstractPopupContent
	{
		/**
		 * The title. */		
		private var _notificationTitle:Label;
		
		/**
		 *  The message. */		
		private var _message:Label;
		
		/**
		 * The faq data. */		
		private var _faqData:FaqQuestionAnswerData;
		
		public function FaqNotificationContent(faqData:FaqQuestionAnswerData)
		{
			super();
			_faqData = faqData;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 40:60 );
			this.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = _faqData.question;
			addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_message = new Label();
			_message.text = _faqData.answer;
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, true);
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = _message.width = this.actualWidth * 0.9;
			_notificationTitle.x = _message.x = (this.actualWidth - _notificationTitle.width) * 0.5;
			
			if(AbstractGameInfo.LANDSCAPE)
			{
				paddingTop = paddingBottom = scaleAndRoundToDpi(20);
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			super.dispose();
		}
		
	}
}