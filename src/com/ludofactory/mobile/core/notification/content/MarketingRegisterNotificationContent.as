/*
Copyright © 2006-2014 Ludo Factory
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
	import com.ludofactory.mobile.core.AbstractGame;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.notification.AbstractNotificationPopupContent;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.display.Scale9Image;
	import feathers.display.TiledImage;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.textures.Scale9Textures;

	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import starling.display.BlendMode;
	import starling.events.Event;

	public class MarketingRegisterNotificationContent extends AbstractNotificationPopupContent
	{
		/**
		 * The title. */		
		private var _notificationTitle:Label;
		
		/**
		 * The message. */		
		private var _bonus:Label;
		private var _bonusOne:Label;
		private var _bonusTwo:Label;
		private var _bonusThree:Label;
		private var _bonusFour:Label;
		
		/**
		 * The yes button. */		
		private var _createButton:Button;
		
		/**
		 * The canel button. */		
		private var _laterButton:Button;
		
		private var _tile:TiledImage;
		
		private var _textGroup:LayoutGroup;
		private var _textGroupLine1:LayoutGroup;
		private var _textGroupLine2:LayoutGroup;
		
		private var _buttonGroup:LayoutGroup;
		
		private var _test:Scale9Image;
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
			
			_test = new Scale9Image(new Scale9Textures(AbstractEntryPoint.assets.getTexture("notification-background-skin-adjust"), new Rectangle(30, 50, 4, 2)), GlobalConfig.dpiScale);
			//addChild(_test);
			
			_tile = new TiledImage(AbstractEntryPoint.assets.getTexture("notification-tile"), GlobalConfig.dpiScale);
			_tile.blendMode = BlendMode.MULTIPLY;
			_tile.alpha = 0.7;
			//addChild(_tile);
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 40:60 );
			this.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = AbstractGameInfo.LANDSCAPE ? _("Créez votre compte dès maintenant pour :") : _("Créez votre compte dès\nmaintenant pour :");
			addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 34 : 46) : (AbstractGameInfo.LANDSCAPE ? 54 : 66)), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			//_notificationTitle.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];

			var textLayout:HorizontalLayout = new HorizontalLayout();
			textLayout.gap = scaleAndRoundToDpi(20);
			textLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			
			_textGroup = new LayoutGroup();
			_textGroup.layout = textLayout;
			addChild(_textGroup);
			
			var textLayoutLine1:VerticalLayout = new VerticalLayout();
			textLayoutLine1.gap = scaleAndRoundToDpi(10);
			
			_textGroupLine1 = new LayoutGroup();
			_textGroupLine1.layout = textLayoutLine1;
			_textGroup.addChild(_textGroupLine1);

			var textLayoutLine2:VerticalLayout = new VerticalLayout();
			textLayoutLine2.gap = scaleAndRoundToDpi(10);
			
			_textGroupLine2 = new LayoutGroup();
			_textGroupLine2.layout = textLayoutLine2;
			_textGroup.addChild(_textGroupLine2);
			
			_bonus = new Label();
			_bonus.text = _("• Obtenir 10 parties par jour");
			_textGroupLine1.addChild(_bonus);
			_bonus.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			//_bonus.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_bonusOne = new Label();
			_bonusOne.text = _( "• Obtenir 10 Nouvelles Parties");
			_textGroupLine1.addChild(_bonusOne);
			_bonusOne.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			//_bonusOne.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_bonusTwo = new Label();
			_bonusTwo.text = MemberManager.getInstance().getGiftsEnabled() ? _("• Convertir vos Points en Cadeaux") : _("• Convertir vos Points");
			_textGroupLine1.addChild(_bonusTwo);
			_bonusTwo.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			//_bonusTwo.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_bonusThree = new Label();
			_bonusThree.text = _("• Gagner 200 Points en bonus");
			_textGroupLine2.addChild(_bonusThree);
			_bonusThree.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			//_bonusThree.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_bonusFour = new Label();
			_bonusFour.text = _("• Obtenir 1 Crédit gratuit");
			_textGroupLine2.addChild(_bonusFour);
			_bonusFour.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			//_bonusFour.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_buttonGroup = new LayoutGroup();
			addChild(_buttonGroup);
			
			_laterButton = new Button();
			_laterButton.label = _("Plus tard");
			_laterButton.styleName = Theme.BUTTON_BLUE;
			_laterButton.addEventListener(Event.TRIGGERED, onCancel);
			_buttonGroup.addChild(_laterButton);
			
			_createButton = new Button();
			_createButton.label = _("Créer");
			_createButton.addEventListener(Event.TRIGGERED, onConfirm);
			_buttonGroup.addChild(_createButton);
			
			_alreadyButton = new ArrowGroup( _("J'ai déjà un compte") );
			_alreadyButton.addEventListener(Event.TRIGGERED, onAlreadyHaveAccount);
			_buttonGroup.addChild(_alreadyButton);
			
			Flox.logEvent("Affichages popup marketing inscription", {Total:"Total"});
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = this.actualWidth;
			_textGroup.width = this.actualWidth;
			_buttonGroup.width = actualWidth * 0.85;
			_laterButton.width = _createButton.width = _buttonGroup.width * 0.5 - scaleAndRoundToDpi(5);
			_createButton.x = _laterButton.width + scaleAndRoundToDpi(10);
			_createButton.validate();
			_alreadyButton.y = _createButton.height;
			_alreadyButton.validate();
			_alreadyButton.x = (_buttonGroup.width - _alreadyButton.width) * 0.5;
			
			super.draw();
			
			
			// TODO A remettre
			/*_tile.y = padTopBackgroundSkinou;
			_tile.width = _backgroundSkinou.width;
			_tile.height = _backgroundSkinou.height;
			
			_test.x = _backgroundGradient.x;
			_test.width = _backgroundGradient.width;
			_test.y = _backgroundSkinou.y + scaleAndRoundToDpi(13);
			_test.height = _backgroundSkinou.height - scaleAndRoundToDpi(13);
			_test.color = 0x01c6f5;
			
			_backgroundGradient.setVertexColor(0, 0x01c6f5);
			_backgroundGradient.setVertexColor(1, 0x01c6f5);
			_backgroundGradient.setVertexColor(2, 0x02649b);
			_backgroundGradient.setVertexColor(3, 0x02649b);*/
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
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_bonus.removeFromParent(true);
			_bonus = null;
			
			_bonusOne.removeFromParent(true);
			_bonusOne = null;
			
			_bonusTwo.removeFromParent(true);
			_bonusTwo = null;
			
			_bonusThree.removeFromParent(true);
			_bonusThree = null;
			
			_bonusFour.removeFromParent(true);
			_bonusFour = null;
			
			_textGroupLine1.removeFromParent(true);
			_textGroupLine1 = null;
			
			_createButton.removeEventListener(Event.TRIGGERED, onConfirm);
			_createButton.removeFromParent(true);
			_createButton = null;
			
			_laterButton.removeEventListener(Event.TRIGGERED, onCancel);
			_laterButton.removeFromParent(true);
			_laterButton = null;
			
			_alreadyButton.removeEventListener(Event.TRIGGERED, onAlreadyHaveAccount);
			_alreadyButton.removeFromParent(true);
			_alreadyButton = null;
			
			_buttonGroup.removeFromParent(true);
			_buttonGroup = null;
			
			_test.removeFromParent(true);
			_test = null;
			
			_tile.removeFromParent(true);
			_tile = null;
			
			super.dispose();
		}
	}
}