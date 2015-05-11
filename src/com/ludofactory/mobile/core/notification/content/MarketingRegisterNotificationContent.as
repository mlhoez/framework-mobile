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
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.AbstractNotificationPopupContent;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	public class MarketingRegisterNotificationContent extends AbstractNotificationPopupContent
	{
		/**
		 * The title. */		
		private var _title:TextField;
		
		/**
		 * The reasons. */		
		private var _reason1:TextField;
		private var _reason2:TextField;
		private var _reason3:TextField;
		private var _reason4:TextField;
		private var _reason5:TextField;
		
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
		
		public function MarketingRegisterNotificationContent( continueScreen:String )
		{
			super();
			
			_continueScreenId = continueScreen;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_title = new TextField(10, scaleAndRoundToDpi(GlobalConfig.isPhone ? 80 : 140), AbstractGameInfo.LANDSCAPE ? _("Créez votre compte dès maintenant pour :") : _("Créez votre compte dès\nmaintenant pour :"), Theme.FONT_SANSITA,
					scaleAndRoundToDpi(GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 34 : 46) : (AbstractGameInfo.LANDSCAPE ? 76 : 76)), Theme.COLOR_DARK_GREY);
			_title.autoScale = true;
			_title.border = true;
			addChild(_title);
			
			_reason1 = new TextField(50, scaleAndRoundToDpi(30), _("• Obtenir 50 Jetons par jour"), Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 46), Theme.COLOR_LIGHT_GREY);
			_reason1.autoScale = true;
			_reason1.hAlign = HAlign.CENTER;
			addChild(_reason1);
			
			_reason2 = new TextField(50, scaleAndRoundToDpi(30), _( "• Obtenir 50 Jetons supplémentaires"), Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 46), Theme.COLOR_LIGHT_GREY);
			_reason2.autoScale = true;
			_reason2.hAlign = HAlign.CENTER;
			addChild(_reason2);
			
			_reason3 = new TextField(50, scaleAndRoundToDpi(30), MemberManager.getInstance().getGiftsEnabled() ? _("• Convertir vos Points en Cadeaux") : _("• Convertir vos Points"), Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 46), Theme.COLOR_LIGHT_GREY);
			_reason3.autoScale = true;
			_reason3.hAlign = HAlign.CENTER;
			addChild(_reason3);
			
			_reason4 = new TextField(50, scaleAndRoundToDpi(30), _("• Gagner 200 Points en bonus"), Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 46), Theme.COLOR_LIGHT_GREY);
			_reason4.autoScale = true;
			_reason4.hAlign = HAlign.CENTER;
			addChild(_reason4);
			
			_reason5 = new TextField(50, scaleAndRoundToDpi(30), _("• Obtenir 1 Crédit gratuit"), Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 46), Theme.COLOR_LIGHT_GREY);
			_reason5.autoScale = true;
			_reason5.hAlign = HAlign.CENTER;
			addChild(_reason5);
			
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
			_title.width = this.actualWidth;
			
			_alreadyButton.validate();
			_alreadyButton.x = (actualWidth - _alreadyButton.width) * 0.5;
			_alreadyButton.y = actualHeight - _alreadyButton.height;

			_laterButton.width = _createButton.width = actualWidth * 0.4;
			_laterButton.x = (actualWidth * 0.5) - _laterButton.width - scaleAndRoundToDpi(5);
			_createButton.x = actualWidth * 0.5 + scaleAndRoundToDpi(5);
			_createButton.validate();
			_laterButton.y = _createButton.y = _alreadyButton.y - _createButton.height + scaleAndRoundToDpi(10);

			/*if( AbstractGameInfo.LANDSCAPE )
			{*/
				_reason1.width = _reason2.width = _reason3.width = _reason4.width = _reason5.width = actualWidth * 0.9;
				var maxReasonsHeight:int = (_createButton.y - _title.y - _title.height) / 5;
				maxReasonsHeight = maxReasonsHeight > scaleAndRoundToDpi(GlobalConfig.isPhone ? 60 : 110) ? scaleAndRoundToDpi(GlobalConfig.isPhone ? 60 : 110) : maxReasonsHeight;
				_reason1.height = _reason2.height = _reason3.height = _reason4.height = _reason5.height = maxReasonsHeight;
				_reason1.x = _reason2.x = _reason3.x = _reason4.x = _reason5.x = actualWidth * 0.05;
				var startY:int = _title.y + _title.height + ((_createButton.y - _title.y - _title.height) - (maxReasonsHeight * 5)) * 0.5;
				_reason1.y = startY;
				_reason2.y = _reason1.y + maxReasonsHeight;
				_reason3.y = _reason2.y + maxReasonsHeight;
				_reason4.y = _reason3.y + maxReasonsHeight;
				_reason5.y = _reason4.y + maxReasonsHeight;
			/*}
			else
			{
				// TODO Voir pour faire la même technique qu'en paysage
				_reason1.width = _reason2.width = _reason3.width = _reason4.width = _reason5.width = actualWidth * 0.9;
				var maxReasonsHeight:int = (_createButton.y - _title.y - _title.height) / 5;
				_reason1.height = _reason2.height = _reason3.height = _reason4.height = _reason5.height = maxReasonsHeight;
				_reason1.x = _reason2.x = _reason3.x = _reason4.x = _reason5.x = actualWidth * 0.05;
				_reason1.y = _title.y + _title.height;
				_reason2.y = _reason1.y + _reason1.height;
				_reason3.y = _reason2.y + _reason2.height;
				_reason4.y = _reason3.y + _reason3.height;
				_reason5.y = _reason4.y + _reason4.height;
			}*/
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onConfirm(event:Event):void
		{
			Flox.logEvent("Affichages popup marketing inscription", {Action:"Creation"});
			AuthenticationManager.startAuthenticationProcess(AbstractEntryPoint.screenNavigator, AbstractEntryPoint.screenNavigator.activeScreenID);
			onClose();
		}
		
		private function onCancel(event:Event):void
		{
			Flox.logEvent("Affichages popup marketing inscription", {Action:"Annulation"});
			AbstractEntryPoint.screenNavigator.showScreen( _continueScreenId );
			onClose();
		}
		
		private function onAlreadyHaveAccount(event:Event):void
		{
			Flox.logEvent("Affichages popup marketing inscription", {Action:"Connexion"});
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
			
			_reason1.removeFromParent(true);
			_reason1 = null;
			
			_reason2.removeFromParent(true);
			_reason2 = null;
			
			_reason3.removeFromParent(true);
			_reason3 = null;
			
			_reason4.removeFromParent(true);
			_reason4 = null;
			
			_reason5.removeFromParent(true);
			_reason5 = null;
			
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