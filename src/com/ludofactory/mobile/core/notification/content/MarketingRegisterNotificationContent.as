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
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.AbstractNotificationPopupContent;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.games.pyramid.AppEntryPoint;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.controls.Button;
	
	import starling.display.Image;
	
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	public class MarketingRegisterNotificationContent extends AbstractNotificationPopupContent
	{
		/**
		 * The title. */		
		private var _title:TextField;
		
		/**
		 * The yes button. */		
		private var _createButton:Button;
		/**
		 * The canel button. */		
		private var _laterButton:Button;
		/**
		 * T. */
		private var _alreadyButton:ArrowGroup;
		
		/**
		 * The screen id if the user clicks on "continue" */		
		private var _continueScreenId:String;
		
		private var _image:Image;
		
		public function MarketingRegisterNotificationContent( continueScreen:String )
		{
			super();
			
			_continueScreenId = continueScreen;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_title = new TextField(10, scaleAndRoundToDpi(GlobalConfig.isPhone ? 80 : 140), _("Recevez 50 jetons gratuits\net un crédit bonus en créant votre compte !"), Theme.FONT_SANSITA,
					scaleAndRoundToDpi(GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 34 : 46) : (AbstractGameInfo.LANDSCAPE ? 76 : 76)), Theme.COLOR_DARK_GREY);
			_title.autoScale = true;
			addChild(_title);
			
			_image = new Image(AbstractEntryPoint.assets.getTexture("marketing-popup-character" + (GlobalConfig.isPhone ? "" : "-hd")));
			_image.scaleX = _image.scaleY = GlobalConfig.dpiScale;
			addChild(_image);
			
			_laterButton = new Button();
			_laterButton.label = _("Plus tard");
			_laterButton.styleName = Theme.BUTTON_BLUE;
			_laterButton.addEventListener(Event.TRIGGERED, onCancel);
			addChild(_laterButton);
			
			_createButton = new Button();
			_createButton.label = _("Créer");
			_createButton.addEventListener(Event.TRIGGERED, onConfirm);
			addChild(_createButton);
			
			_alreadyButton = new ArrowGroup( _("J'ai déjà un compte") );
			_alreadyButton.addEventListener(Event.TRIGGERED, onAlreadyHaveAccount);
			addChild(_alreadyButton);
			
			Flox.logEvent("Affichages popup marketing inscription", {Total:"Total"});
		}
		
		override protected function draw():void
		{
			_title.width = this.actualWidth * (GlobalConfig.isPhone ? 0.55 : 0.5);
			_title.x = (actualWidth * (GlobalConfig.isPhone ? 0.45 : 0.5)) + roundUp(((actualWidth * 0.5) - _title.width) * 0.5);
			
			_image.y = roundUp((actualHeight - _image.height) * 0.5);
			_image.x = roundUp((actualWidth * 0.5 - _image.width) * 0.5);
			
			_laterButton.width = _createButton.width = actualWidth * 0.4;
			_laterButton.height = _createButton.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 90 : 130);
			
			_createButton.validate();
			_createButton.x = _laterButton.x = actualWidth * (GlobalConfig.isPhone ? 0.45 : 0.5)  + ((actualWidth * 0.5) - _createButton.width) * 0.5;
			
			_alreadyButton.validate();
			_alreadyButton.x = actualWidth * (GlobalConfig.isPhone ? 0.45 : 0.5)  + ((actualWidth * 0.5) - _alreadyButton.width) * 0.5;
			
			_title.y = roundUp((actualHeight - (_title.height + _createButton.height + _laterButton.height + _alreadyButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ?  20 : 80))) * 0.5);
			_createButton.y = _title.y + _title.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 40);
			_laterButton.y = _createButton.y + _createButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 40);
			_alreadyButton.y = _laterButton.y + _laterButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 0 : 30);
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onConfirm(event:Event):void
		{
			Flox.logEvent("Affichages popup marketing inscription", {Action:"Creation"});
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Popup marketing inscription", "Clic sur création de compte", null, NaN, MemberManager.getInstance().getId());
			AuthenticationManager.startAuthenticationProcess(AbstractEntryPoint.screenNavigator, AbstractEntryPoint.screenNavigator.activeScreenID);
			onClose();
		}
		
		private function onCancel(event:Event):void
		{
			Flox.logEvent("Affichages popup marketing inscription", {Action:"Annulation"});
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Popup marketing inscription", "Annulation", null, NaN, MemberManager.getInstance().getId());
			AbstractEntryPoint.screenNavigator.showScreen( _continueScreenId );
			onClose();
		}
		
		private function onAlreadyHaveAccount(event:Event):void
		{
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Popup marketing inscription", "Connexion à un compte existant", null, NaN, MemberManager.getInstance().getId());
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
			
			_laterButton.removeEventListener(Event.TRIGGERED, onCancel);
			_laterButton.removeFromParent(true);
			_laterButton = null;
			
			_alreadyButton.removeEventListener(Event.TRIGGERED, onAlreadyHaveAccount);
			_alreadyButton.removeFromParent(true);
			_alreadyButton = null;
			
			super.dispose();
		}
	}
}