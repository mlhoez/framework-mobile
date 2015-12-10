/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 24 sept. 2013
*/
package com.ludofactory.mobile.core.notification.content
{
	
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.controls.Button;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	public class MarketingRegisterNotificationContent extends AbstractPopupContent
	{
		/**
		 * The title. */		
		private var _title:TextField;
		
		/**
		 * The yes button. */		
		private var _createButton:MobileButton;
		/**
		 * T. */
		private var _alreadyButton:ArrowGroup;
		
		/**
		 * The screen id if the user clicks on "continue" */		
		private var _continueScreenId:String;
		
		private var _image:Image;
		
		private var _titleMain:TextField;
		private var _titleText:String = "";
		
		public function MarketingRegisterNotificationContent( title:String, continueScreen:String )
		{
			super();
			
			_titleText = title;
			_continueScreenId = continueScreen;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_title = new TextField(10, 10, _("Recevez 50 Jetons GRATUITS par jour + un crédit bonus en créant votre compte !"), Theme.FONT_SANSITA,
					scaleAndRoundToDpi(GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 34 : 46) : (AbstractGameInfo.LANDSCAPE ? 38 : 50)), Theme.COLOR_DARK_GREY);
			_title.autoSize = TextFieldAutoSize.VERTICAL;
			_title.autoScale = false;
			addChild(_title);
			
			_titleMain = new TextField(10, scaleAndRoundToDpi(70), _titleText, Theme.FONT_SANSITA, scaleAndRoundToDpi(76), Theme.COLOR_DARK_GREY);
			_titleMain.autoScale = true;
			addChild(_titleMain);
			
			_image = new Image(AbstractEntryPoint.assets.getTexture("marketing-popup-character" + (GlobalConfig.isPhone ? "" : "-hd")));
			//_image.scaleX = _image.scaleY = GlobalConfig.dpiScale;
			addChild(_image);
			
			_createButton = ButtonFactory.getButton(_("Je les veux !"), ButtonFactory.BLUE);
			_createButton.addEventListener(Event.TRIGGERED, onConfirm);
			addChild(_createButton);
			
			_alreadyButton = new ArrowGroup( _("Plus tard") );
			_alreadyButton.addEventListener(Event.TRIGGERED, onAlreadyHaveAccount);
			addChild(_alreadyButton);
			
			Flox.logEvent("Affichages popup marketing inscription", {Total:"Total"});
			
			_horizontalScrollPolicy = _verticalScrollPolicy = SCROLL_POLICY_OFF;
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE))
			{
				if(AbstractGameInfo.LANDSCAPE)
				{
					var paddingTitleMain:int = scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
					
					_titleMain.width = actualWidth;
					
					_title.width = this.actualWidth * 0.5;
					_title.x = (actualWidth * 0.5) + roundUp(((actualWidth * 0.5) - _title.width) * 0.5);
					
					_image.scaleX = _image.scaleY = 1;
					_image.scaleX = _image.scaleY = Utilities.getScaleToFill(_image.width, _image.height, (actualWidth * 0.5), ((NotificationPopupManager.maxContentHeight - _titleMain.y - _titleMain.height - paddingTitleMain) * 0.9));
					_image.x = roundUp((actualWidth * 0.5 - _image.width) * 0.5);
					_image.y = _titleMain.y + _titleMain.height + paddingTitleMain;
					
					_createButton.x = actualWidth * 0.5  + ((actualWidth * 0.5) - _createButton.width) * 0.5;
					_alreadyButton.x = actualWidth * 0.5  + ((actualWidth * 0.5) - _alreadyButton.width) * 0.5;
					
					if(_title.height > (NotificationPopupManager.maxContentHeight - _titleMain.y - _titleMain.height - paddingTitleMain -_createButton.height - _alreadyButton.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 40) - scaleAndRoundToDpi(GlobalConfig.isPhone ? 0 : 30) - scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20)))
					{
						_title.autoSize = TextFieldAutoSize.NONE;
						_title.autoScale = true;
						_title.height = NotificationPopupManager.maxContentHeight - _titleMain.y - _titleMain.height - paddingTitleMain - _createButton.height - _alreadyButton.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 40) - scaleAndRoundToDpi(GlobalConfig.isPhone ? 0 : 30) - scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					}
					
					_title.y = roundUp(_titleMain.y + _titleMain.height + (paddingTitleMain * 0.5) + (NotificationPopupManager.maxContentHeight - (_title.height + _titleMain.y + _titleMain.height + _createButton.height + _alreadyButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ?  20 : 80))) * 0.5);
					_createButton.y = _title.y + _title.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 40);
					_alreadyButton.y = _createButton.y + _createButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 0 : 30);
				}
				else
				{
					_image.scaleX = _image.scaleY = 1;
					_image.scaleX = _image.scaleY = Utilities.getScaleToFillHeight(_image.height, (GlobalConfig.stageHeight * 0.4));
					_image.x = roundUp((actualWidth - _image.width) * 0.5);
					
					_title.width = this.actualWidth * (GlobalConfig.isPhone ? 0.9 : 0.8);
					_title.x = roundUp((actualWidth - _title.width) * 0.5);
					
					_createButton.x = (actualWidth - _createButton.width) * 0.5;
					
					_alreadyButton.x = roundUp((actualWidth - _alreadyButton.width) * 0.5);
					
					_title.y = _image.height + scaleAndRoundToDpi(20);
					_createButton.y = _title.y + _title.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 30);
					_alreadyButton.y = _createButton.y + _createButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 0 : 15);
				}
				
				super.draw();
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onConfirm(event:Event):void
		{
			Flox.logEvent("Affichages popup marketing inscription", {Action:"Creation"});
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Popup marketing inscription", "Clic sur création de compte", null, NaN, MemberManager.getInstance().id);
			AuthenticationManager.startAuthenticationProcess(AbstractEntryPoint.screenNavigator, AbstractEntryPoint.screenNavigator.activeScreenID);
			onClose();
		}
		
		private function onAlreadyHaveAccount(event:Event):void
		{
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Popup marketing inscription", "Connexion à un compte existant", null, NaN, MemberManager.getInstance().id);
			AuthenticationManager.startAuthenticationProcess(AbstractEntryPoint.screenNavigator, AbstractEntryPoint.screenNavigator.activeScreenID);
			onClose();
		}

		/**
		 * Close the notification.
		 */
		public function onClose():void
		{
			Flox.logEvent("Affichages popup marketing inscription", {Action:"Fermeture"});
			close();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_title.removeFromParent(true);
			_title = null;
			
			_createButton.removeEventListener(Event.TRIGGERED, onConfirm);
			_createButton.removeFromParent(true);
			_createButton = null;
			
			_alreadyButton.removeEventListener(Event.TRIGGERED, onAlreadyHaveAccount);
			_alreadyButton.removeFromParent(true);
			_alreadyButton = null;
			
			super.dispose();
		}
	}
}