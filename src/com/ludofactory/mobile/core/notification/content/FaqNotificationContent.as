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
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.faq.*;
	
	import feathers.controls.Label;
	import feathers.layout.VerticalLayout;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	
	public class FaqNotificationContent extends AbstractPopupContent
	{
		/**
		 * The title. */		
		private var _notificationTitle:TextField;
		
		/**
		 *  The message. */		
		private var _message:TextField;
		
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
			
			_notificationTitle = new TextField(10, 10, _faqData.question, Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY);
			_notificationTitle.autoSize = TextFieldAutoSize.VERTICAL;
			addChild(_notificationTitle);
			
			_message = new TextField(10, 10, _faqData.answer, Theme.FONT_SANSITA, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, true);
			_message.hAlign = HAlign.LEFT;
			_message.autoSize = TextFieldAutoSize.VERTICAL;
			addChild(_message);
		}
		
		override protected function draw():void
		{
			if(AbstractGameInfo.LANDSCAPE)
				paddingTop = paddingBottom = scaleAndRoundToDpi(20);
			
			_notificationTitle.width = _message.width = this.actualWidth;
			_notificationTitle.x = _message.x = (this.actualWidth - _notificationTitle.width) * 0.5;
			
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