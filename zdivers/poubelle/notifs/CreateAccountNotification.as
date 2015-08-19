/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 20 août 2013
*/
package com.ludofactory.mobile.core.notification.content
{
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.common.utils.scaleToDpi;
	import com.ludofactory.mobile.application.config.GlobalConfig;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreenNavigator;
	import NotificationManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class CreateAccountNotification extends AbstractNotification
	{
		/**
		 * The title */		
		private var _notificationTitle:Label;
		
		/**
		 *  The message */		
		private var _message:Label;
		
		/**
		 * The buttons container */		
		private var _buttonsContainer:ScrollContainer;
		
		/**
		 * The create account button */		
		private var _createAccountButton:Button;
		/**
		 * The continue button */		
		private var _continueButton:Button;
		
		/**
		 * The login label */		
		private var _loginLabel:Label;
		
		/**
		 * The screen navigator, for reference */		
		private var _screenNavigator:AdvancedScreenNavigator;
		/**
		 * The screen id if the user clicks on "continue" */		
		private var _continueScreenId:String;
		
		public function CreateAccountNotification(screenNavigator:AdvancedScreenNavigator, continueScreen:String)
		{
			super();
			
			_screenNavigator = screenNavigator;
			_continueScreenId = continueScreen;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleToDpi( GlobalConfig.isPhone ? 40:60 );
			_container.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = Localizer.getInstance().translate("CREATE_ACCOUNT_NOTIFICATION.TITLE");
			_container.addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA_ONE, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_message = new Label();
			_message.text = Localizer.getInstance().translate("CREATE_ACCOUNT_NOTIFICATION.MESSAGE");
			_container.addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL_BOLD, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, null, null, null, null, null, TextFormatAlign.LEFT);
			
			const buttonsLayout:VerticalLayout = new VerticalLayout();
			buttonsLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			buttonsLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			buttonsLayout.gap = scaleToDpi(5);
			
			_buttonsContainer = new ScrollContainer();
			_buttonsContainer.layout = buttonsLayout;
			_container.addChild(_buttonsContainer);
			
			_createAccountButton = new Button();
			_createAccountButton.label = Localizer.getInstance().translate("CREATE_ACCOUNT_NOTIFICATION.CREATE_ACCOUNT_BUTTON");
			_createAccountButton.addEventListener(Event.TRIGGERED, onCreateAccount);
			_buttonsContainer.addChild(_createAccountButton);
			
			_continueButton = new Button();
			_continueButton.label = Localizer.getInstance().translate("CREATE_ACCOUNT_NOTIFICATION.LATER_BUTTON");
			_continueButton.nameList.add( Theme.BUTTON_BLUE );
			_continueButton.addEventListener(Event.TRIGGERED, onContinue);
			_buttonsContainer.addChild(_continueButton);
			
			_loginLabel = new Label();
			_loginLabel.text = Localizer.getInstance().translate("CREATE_ACCOUNT_NOTIFICATION.ALREADY_HAVE_ACCOUNT_BUTTON");
			_loginLabel.addEventListener(TouchEvent.TOUCH, onLogin);
			_container.addChild(_loginLabel);
			_loginLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL_BOLD, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, null, null, null, null, null, TextFormatAlign.CENTER);
			
		}
		
		override protected function draw():void
		{
			_container.width = this.actualWidth - padSide * 2;
			_container.x = padSide;
			_notificationTitle.width = _container.width;
			_buttonsContainer.width = _createAccountButton.width = _continueButton.width = _container.width * 0.8;
			_loginLabel.width = _container.width;
			_loginLabel.validate();
			_loginLabel.height *= 1.5;
			_loginLabel.minTouchHeight = scaleToDpi(140);
			
			super.draw();
		}
		
		private function onCreateAccount(event:Event):void
		{
			TweenMax.killAll();
			AuthenticationManager.startAuthenticationProcess(_screenNavigator, _screenNavigator.screenData.startScreenId, _screenNavigator.screenData.previousScreenId, _screenNavigator.screenData.completeScreenId);
			NotificationManager.closeNotification();
		}
		
		private function onContinue(event:Event):void
		{
			TweenMax.killAll();
			_screenNavigator.showScreen( _continueScreenId );
			NotificationManager.closeNotification();
		}
		
		private function onLogin(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if( touch && touch.phase == TouchPhase.BEGAN )
			{
				TweenMax.killAll();
				AuthenticationManager.startAuthenticationProcess(_screenNavigator, _screenNavigator.screenData.startScreenId, _screenNavigator.screenData.previousScreenId, _screenNavigator.screenData.completeScreenId);
				NotificationManager.closeNotification();
			}
			touch = null;
		}
		
		override public function dispose():void
		{
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_createAccountButton.removeEventListener(Event.TRIGGERED, onCreateAccount);
			_createAccountButton.removeFromParent(true);
			_createAccountButton = null;
			
			_continueButton.removeEventListener(Event.TRIGGERED, onContinue);
			_continueButton.removeFromParent(true);
			_continueButton = null;
			
			_loginLabel.removeEventListener(TouchEvent.TOUCH, onLogin);
			_loginLabel.removeFromParent(true);
			_loginLabel = null;
			
			_buttonsContainer.removeFromParent(true);
			_buttonsContainer = null;
			
			_screenNavigator = null;
			
			super.dispose();
		}
	}
}