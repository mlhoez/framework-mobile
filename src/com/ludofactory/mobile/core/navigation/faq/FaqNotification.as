/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 2 sept. 2013
*/
package com.ludofactory.mobile.core.navigation.faq
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.notification.content.AbstractNotification;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Label;
	import feathers.layout.VerticalLayout;
	
	public class FaqNotification extends AbstractNotification
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
		
		public function FaqNotification(faqData:FaqQuestionAnswerData)
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
			_container.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = _faqData.question;
			_container.addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_message = new Label();
			_message.text = _faqData.answer;
			_container.addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, true);
		}
		
		override protected function draw():void
		{
			_container.width = this.actualWidth - padSide * 4;
			_container.x = padSide * 2;
			_notificationTitle.width = _message.width =  _container.width;
			
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