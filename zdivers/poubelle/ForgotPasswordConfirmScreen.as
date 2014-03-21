/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 24 juil. 2013
*/
package com.ludofactory.mobile.core.authentication
{
	import com.ludofactory.common.utils.scaleToDpi;
	import com.ludofactory.mobile.application.config.GlobalConfig;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import app.AppEntryPoint;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.events.Event;
	
	/**
	 * This is the screen displayed after the mail containing the user's password 
	 * have been successfully sent. It offers the possibility to go back to the home
	 * screen or restart the authentication process directly if he has already got
	 * his password.
	 */	
	public class ForgotPasswordConfirmScreen extends AdvancedScreen
	{
		/**
		 * The main container */		
		private var _mainContainer:ScrollContainer;
		
		/**
		 * The logo */		
		private var _logo:Image;
		
		/**
		 * the title */		
		private var _title:Label;
		
		/**
		 * The icon */		
		private var _icon:Image;
		
		/**
		 * the message */		
		private var _message:Label;
		
		/**
		 * Connect button */		
		private var _connectButton:Button;
		
		/**
		 * Home button */		
		private var _homeButton:Button;
		
		public function ForgotPasswordConfirmScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("FORGOT_PASSWORD_CONFIRM.HEADER_TITLE");
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.padding = scaleToDpi(10);
			vlayout.gap = scaleToDpi(10);
			
			_mainContainer = new ScrollContainer();
			_mainContainer.layout = vlayout;
			_mainContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_mainContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild( _mainContainer );
			
			_logo = new Image( AbstractEntryPoint.assets.getTexture("LogoLudokado") );
			_logo.scaleX = _logo.scaleY = GlobalConfig.dpiScalez;
			_mainContainer.addChild( _logo );
			
			_title = new Label();
			_title.text = Localizer.getInstance().translate("FORGOT_PASSWORD_CONFIRM.TITLE");
			_title.nameList.add( Theme.LABEL_GLOBAL_TITLE );
			_mainContainer.addChild(_title);
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("icon-check") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScalez;
			_mainContainer.addChild( _icon );
			
			_message = new Label();
			_message.nameList.add( Theme.LABEL_BLACK_CENTER );
			_message.text = Localizer.getInstance().translate("FORGOT_PASSWORD_CONFIRM.MESSAGE");
			_mainContainer.addChild(_message);
			
			_connectButton = new Button();
			_connectButton.label = Localizer.getInstance().translate("FORGOT_PASSWORD_CONFIRM.CONNECT_BUTTON_LABEL");
			_connectButton.addEventListener(Event.TRIGGERED, onConnect);
			_mainContainer.addChild( _connectButton );
			
			_homeButton = new Button();
			_homeButton.label = Localizer.getInstance().translate("FORGOT_PASSWORD_CONFIRM.HOME_BUTTON_LABEL");
			_homeButton.nameList.add( Theme.BUTTON_BLUE );
			_homeButton.addEventListener(Event.TRIGGERED, onGoHome);
			_mainContainer.addChild( _homeButton );
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_mainContainer.width = _title.width = _message.width = this.actualWidth * (GlobalConfig.isPhone ? 0.8:0.6);
				_mainContainer.height = this.actualHeight;
				_mainContainer.x = (this.actualWidth - _mainContainer.width) * 0.5;
				
				_connectButton.width = _homeButton.width = _mainContainer.width * 0.8;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onConnect(event:Event):void
		{
			AuthenticationManager.startAuthenticationProcess(this.advancedOwner, this.advancedOwner.screenData.startScreenId, this.advancedOwner.screenData.startScreenId, this.advancedOwner.screenData.completeScreenId);
		}
		
		private function onGoHome(event:Event):void
		{
			advancedOwner.showScreen( AdvancedScreen.HOME_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_connectButton.removeEventListener(Event.TRIGGERED, onConnect);
			_connectButton.removeFromParent(true);
			_connectButton = null;
			
			_homeButton.removeEventListener(Event.TRIGGERED, onGoHome);
			_homeButton.removeFromParent(true);
			_homeButton = null;
			
			_mainContainer.removeFromParent(true);
			_mainContainer = null;
			
			super.dispose();
		}
		
	}
}