/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 24 sept. 2013
*/
package com.ludofactory.mobile.navigation
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
import com.ludofactory.mobile.core.manager.MemberManager;
import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.notification.content.AbstractNotification;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.display.Scale9Image;
	import feathers.display.TiledImage;
	import feathers.layout.VerticalLayout;
	import feathers.textures.Scale9Textures;
	
	import starling.display.BlendMode;
	import starling.events.Event;
	
	public class MarketingRegisterNotification extends AbstractNotification
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
		
		private var _buttonGroup:LayoutGroup;
		
		private var _test:Scale9Image;
		private var _alreadyButton:ArrowGroup;
		
		/**
		 * The screen id if the user clicks on "continue" */		
		private var _continueScreenId:String;
		
		public function MarketingRegisterNotification( continueScreen:String )
		{
			super();
			
			_continueScreenId = continueScreen;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_test = new Scale9Image(new Scale9Textures(AbstractEntryPoint.assets.getTexture("notification-background-skin-adjust"), new Rectangle(30, 50, 4, 2)), GlobalConfig.dpiScale);
			addChildAt(_test, 1);
			
			_tile = new TiledImage(AbstractEntryPoint.assets.getTexture("notification-tile"), GlobalConfig.dpiScale);
			_tile.blendMode = BlendMode.MULTIPLY;
			_tile.alpha = 0.7;
			addChildAt(_tile, 3);
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 50:70 );
			_container.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = _("Créez votre compte dès\nmaintenant pour :");
			_container.addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 46 : 66), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_notificationTitle.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			var textLayout:VerticalLayout = new VerticalLayout();
			textLayout.gap = scaleAndRoundToDpi(10);
			
			_textGroup = new LayoutGroup();
			_textGroup.layout = textLayout;
			_container.addChild(_textGroup);
			
			_bonus = new Label();
			_bonus.text = "• Obtenir 10 parties par jour";
			_textGroup.addChild(_bonus);
			_bonus.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			_bonus.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_bonusOne = new Label();
			_bonusOne.text =  "• Obtenir 10 Nouvelles Parties";
			_textGroup.addChild(_bonusOne);
			_bonusOne.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			_bonusOne.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_bonusTwo = new Label();
			_bonusTwo.text = MemberManager.getInstance().getGiftsEnabled() ? "• Convertir vos Points en Cadeaux" : "• Convertir vos Points";
			_textGroup.addChild(_bonusTwo);
			_bonusTwo.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			_bonusTwo.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_bonusThree = new Label();
			_bonusThree.text = "• Gagner 200 Points en bonus";
			_textGroup.addChild(_bonusThree);
			_bonusThree.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			_bonusThree.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_bonusFour = new Label();
			_bonusFour.text = "• Obtenir 1 Crédit gratuit";
			_textGroup.addChild(_bonusFour);
			_bonusFour.textRendererProperties.textFormat = Theme.marketingRegisterNotificationBonusTextFormat;
			_bonusFour.textRendererProperties.nativeFilters = [ new DropShadowFilter(4, 75, 0x000000, 0.6, 5, 5) ];
			
			_buttonGroup = new LayoutGroup();
			_container.addChild(_buttonGroup);
			
			_laterButton = new Button();
			_laterButton.label = "Plus tard";
			_laterButton.styleName = Theme.BUTTON_BLUE;
			_laterButton.addEventListener(Event.TRIGGERED, onCancel);
			_buttonGroup.addChild(_laterButton);
			
			_createButton = new Button();
			_createButton.label = "Créer";
			_createButton.addEventListener(Event.TRIGGERED, onConfirm);
			_buttonGroup.addChild(_createButton);
			
			_alreadyButton = new ArrowGroup( "J'ai déjà un compte" );
			_alreadyButton.addEventListener(Event.TRIGGERED, onAlreadyHaveAccount);
			_buttonGroup.addChild(_alreadyButton);
			
			Flox.logEvent("Affichages popup marketing inscription", {Total:"Total"});
		}
		
		override protected function draw():void
		{
			_container.width = this.actualWidth - padSide * 2;
			_container.x = padSide;
			
			_notificationTitle.width = _container.width;
			_textGroup.width = _bonusOne.width = _bonusTwo.width = _bonusThree.width = _bonusFour.width = _container.width * 0.9;
			_buttonGroup.width = actualWidth * 0.85;
			_laterButton.width = _createButton.width = _buttonGroup.width * 0.5 - scaleAndRoundToDpi(5);
			_createButton.x = _laterButton.width + scaleAndRoundToDpi(10);
			_createButton.validate();
			_alreadyButton.y = _createButton.height;
			_alreadyButton.validate();
			_alreadyButton.x = (_buttonGroup.width - _alreadyButton.width) * 0.5;
			
			super.draw();
			
			_tile.y = padTopBackgroundSkinou;
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
			_backgroundGradient.setVertexColor(3, 0x02649b);
			
			_topLeftDecoration.visible = _topRightDecoration.visible = _bottomLeftDecoration.visible = _bottomRightDecoration.visible = false;
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
		
		override public function onClose():void
		{
			Flox.logEvent("Affichages popup marketing inscription", {Action:"Fermeture"});
			super.onClose();
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
			
			_textGroup.removeFromParent(true);
			_textGroup = null;
			
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