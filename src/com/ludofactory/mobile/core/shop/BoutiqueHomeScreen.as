/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 21 août 2013
*/
package com.ludofactory.mobile.core.shop
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;
	
	/**
	 * Boutique home page
	 */	
	public class BoutiqueHomeScreen extends AdvancedScreen
	{
		/**
		 * The green side overlay */		
		private var _greenSide:Quad;
		/**
		 * The blue side overlay */		
		private var _blueSide:Quad;
		
		/**
		 * The encheres title */		
		private var _encheresTitle:Label
		/**
		 * The encheres image */		
		private var _encheresImage:Image;
		/**
		 * Particles */		
		private var _encheresParticles:PDParticleSystem;
		/**
		 * The encheres access button */		
		private var _encheresAccessButton:Button;
		/**
		 * Echeres message */		
		private var _encheresMessage:Label;
		
		/**
		 * The boutique title */		
		private var _boutiqueTitle:Label
		/**
		 * The boutique image */		
		private var _boutiqueImage:Image;
		/**
		 * The boutique access button */		
		private var _boutiqueAccessButton:Button;
		/**
		 * The boutique vip glow */		
		private var _glow:Image;
		/**
		 * The boutique vip buildings */		
		private var _buildings:Image;
		/**
		 * Boutique vip message*/		
		private var _boutiqueMessage:Label;
		
		/**
		 * The vip info button */		
		private var _vipInfo:Button;
		private var _vipInfoGreenStripe:Quad;
		private var _vipInfoBlueStripe:Quad;
		
		public function BoutiqueHomeScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_greenSide = new Quad(50, 50, 0x76ce2f);
			_greenSide.addEventListener(TouchEvent.TOUCH, onAccessEncheres);
			_greenSide.blendMode = BlendMode.MULTIPLY;
			addChild(_greenSide);
			
			_blueSide = new Quad(50, 50, 0x00d8ff);
			_blueSide.addEventListener(TouchEvent.TOUCH, onAccessBoutiqueVip);
			_blueSide.blendMode = BlendMode.MULTIPLY;
			addChild(_blueSide);
			
			// Enchères
			
			_encheresParticles = new PDParticleSystem(Theme.particleSlowXml, Theme.particleRoundTexture);
			_encheresParticles.touchable = false;
			_encheresParticles.maxNumParticles = 500;
			addChild(_encheresParticles);
			Starling.juggler.add(_encheresParticles);
			
			_encheresTitle = new Label();
			_encheresTitle.touchable = false;
			_encheresTitle.text = Localizer.getInstance().translate("BOUTIQUE_HOME.BID_TITLE");
			addChild(_encheresTitle);
			_encheresTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 48 : 64), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_encheresTitle.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 5, 5, 3) ];
			
			_encheresImage = new Image( AbstractEntryPoint.assets.getTexture("EncheresImage") );
			_encheresImage.touchable = false;
			_encheresImage.scaleX = _encheresImage.scaleY = GlobalConfig.dpiScale;
			_encheresImage.alignPivot();
			_encheresImage.alpha = 0;
			_encheresImage.rotation = deg2rad(90);
			addChild(_encheresImage);
			
			_encheresAccessButton = new Button();
			_encheresAccessButton.touchable = false;
			_encheresAccessButton.label = Localizer.getInstance().translate("BOUTIQUE_HOME.ACCESS_BUTTON");
			_encheresAccessButton.alpha = 0;
			addChild(_encheresAccessButton);
			
			_encheresMessage = new Label();
			_encheresMessage.touchable = false;
			_encheresMessage.text = Localizer.getInstance().translate("BOUTIQUE_HOME.BID_MESSAGE");
			addChild( _encheresMessage );
			_encheresMessage.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 32 : 40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// Boutique Vip
			
			_boutiqueTitle = new Label();
			_boutiqueTitle.touchable = false;
			_boutiqueTitle.text = Localizer.getInstance().translate("BOUTIQUE_HOME.BOUTIQUE_VIP_TITLE");
			addChild(_boutiqueTitle);
			_boutiqueTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 48 : 64), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_boutiqueTitle.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 5, 5, 3) ];
			
			_glow = new Image( AbstractEntryPoint.assets.getTexture("HighScoreGlow") );
			_glow.touchable = false;
			_glow.scaleX = _glow.scaleY = GlobalConfig.dpiScale;
			_glow.alignPivot();
			_glow.alpha = 0;
			addChild(_glow);
			
			_boutiqueMessage = new Label();
			_boutiqueMessage.touchable = false;
			_boutiqueMessage.text = Localizer.getInstance().translate("BOUTIQUE_HOME.BOUTIQUE_VIP_MESSAGE");
			addChild( _boutiqueMessage );
			_boutiqueMessage.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 32 : 40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_buildings = new Image( AbstractEntryPoint.assets.getTexture("Buildings") );
			_buildings.touchable = false;
			_buildings.scaleX = _encheresImage.scaleY = GlobalConfig.dpiScale;
			_buildings.alignPivot(HAlign.CENTER, VAlign.TOP);
			_buildings.alpha = 0;
			addChild(_buildings);
			
			_boutiqueImage = new Image( AbstractEntryPoint.assets.getTexture("BoutiqueImage") );
			_boutiqueImage.touchable = false;
			_boutiqueImage.scaleX = _boutiqueImage.scaleY = GlobalConfig.dpiScale;
			_boutiqueImage.alignPivot();
			_boutiqueImage.alpha = 0;
			_boutiqueImage.rotation = deg2rad(-90);
			addChild(_boutiqueImage);
			
			_boutiqueAccessButton = new Button();
			_boutiqueAccessButton.touchable = false;
			_boutiqueAccessButton.label = Localizer.getInstance().translate("BOUTIQUE_HOME.ACCESS_BUTTON");
			_boutiqueAccessButton.alpha = 0;
			addChild(_boutiqueAccessButton);
			
			// vip info
			
			_vipInfoGreenStripe = new Quad(scaleAndRoundToDpi(5), 10, 0x76ce2f);
			_vipInfoGreenStripe.touchable = false;
			_vipInfoGreenStripe.alignPivot(HAlign.LEFT, VAlign.CENTER);
			_vipInfoGreenStripe.blendMode = BlendMode.MULTIPLY;
			addChild(_vipInfoGreenStripe);
			
			_vipInfoBlueStripe = new Quad(scaleAndRoundToDpi(5), 10, 0x00d8ff);
			_vipInfoBlueStripe.touchable = false;
			_vipInfoBlueStripe.alignPivot(HAlign.LEFT, VAlign.CENTER);
			_vipInfoBlueStripe.blendMode = BlendMode.MULTIPLY;
			addChild(_vipInfoBlueStripe);
			
			_vipInfo = new Button();
			_vipInfo.styleName = Theme.BUTTON_TRANSPARENT_WHITE;
			_vipInfo.label = Localizer.getInstance().translate("BOUTIQUE_HOME.VIP_INFO_BUTTON");
			_vipInfo.addEventListener(Event.TRIGGERED, onShowVipInfo);
			addChild(_vipInfo);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_greenSide.height = _blueSide.height = GlobalConfig.stageHeight;
				_greenSide.y = _blueSide.y = (actualHeight - GlobalConfig.stageHeight);
				_greenSide.width = _blueSide.width = _buildings.width = (this.actualWidth * 0.5) - scaleAndRoundToDpi(5);
				_blueSide.x = (this.actualWidth * 0.5) + scaleAndRoundToDpi(5);
				
				_encheresTitle.width = _boutiqueTitle.width = _greenSide.width;
				_encheresTitle.y = _boutiqueTitle.y = this.actualHeight * (GlobalConfig.isPhone ? 0.05 : 0.1);
				_boutiqueTitle.x = _blueSide.x;
				
				_encheresImage.x = _greenSide.width * 0.5;
				_encheresImage.y = _boutiqueImage.y = _glow.y = _buildings.y = this.actualHeight * 0.4;
				_boutiqueImage.x = _glow.x = _buildings.x = _blueSide.width * 0.5 + _blueSide.x;
				
				_encheresAccessButton.width = _boutiqueAccessButton.width = _greenSide.width * 0.8;
				_encheresAccessButton.y =_boutiqueAccessButton.y =  _encheresImage.y + _encheresImage.height * 0.25;
				_encheresAccessButton.x = _encheresImage.x - _encheresAccessButton.width * 0.5;
				_boutiqueAccessButton.x = _boutiqueImage.x - _boutiqueAccessButton.width * 0.5;
				
				_encheresParticles.alpha = 0;
				_encheresParticles.x = _encheresImage.x;
				_encheresParticles.y = _encheresImage.y;
				_encheresParticles.start();
				
				_encheresMessage.y = _boutiqueMessage.y = _encheresAccessButton.y + _encheresAccessButton.height + scaleAndRoundToDpi(40);
				_encheresMessage.width = _boutiqueMessage.width = _greenSide.width;
				_boutiqueMessage.x = _blueSide.x;
				
				_vipInfo.validate();
				_boutiqueMessage.validate();
				_vipInfo.y = (_boutiqueMessage.y + _boutiqueMessage.height) + (  (this.actualHeight - (_boutiqueMessage.y + _boutiqueMessage.height) - _vipInfo.height) * 0.5 );
				_vipInfo.x = (this.actualWidth - _vipInfo.width) * 0.5;
				
				_vipInfoBlueStripe.height = _vipInfoGreenStripe.height = _vipInfo.height - scaleAndRoundToDpi(12);
				_vipInfoGreenStripe.y = _vipInfoBlueStripe.y = _vipInfo.y + _vipInfo.height * 0.5;
				_vipInfoGreenStripe.x = (this.actualWidth * 0.5) - _vipInfoGreenStripe.width;
				_vipInfoBlueStripe.x = (this.actualWidth * 0.5);
				
				_encheresImage.scaleX = _encheresImage.scaleY = _boutiqueImage.scaleX = _boutiqueImage.scaleY = 0;
				TweenMax.to(_encheresParticles, 1, { alpha:1 });
				TweenMax.to(_encheresImage, 1.75, { delay:0.25, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, alpha:1, rotation:deg2rad(0), ease:Elastic.easeOut });
				TweenMax.to(_boutiqueImage, 1.75, { delay:0.35, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, alpha:1, rotation:deg2rad(0), ease:Elastic.easeOut });
				TweenMax.to([_encheresAccessButton, _boutiqueAccessButton], 0.5, { delay:0.5,  alpha:1 });
				TweenMax.to([_glow, _buildings], 1.5, { delay:1, alpha:0.5 });
				TweenMax.to(_glow, 20, { delay:0.5, rotation:deg2rad(360), repeat:-1, ease:Linear.easeNone });
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Access boutique Vip.
		 */		
		private function onAccessEncheres(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_greenSide);
			if( touch && touch.phase == TouchPhase.ENDED)
			{
				this.advancedOwner.showScreen( ScreenIds.BIDS_HOME_SCREEN );
			}
			touch = null;
		}
		
		/**
		 * Access boutique Vip.
		 */		
		private function onAccessBoutiqueVip(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_blueSide);
			if( touch && touch.phase == TouchPhase.ENDED)
			{
				this.advancedOwner.showScreen( ScreenIds.BOUTIQUE_CATEGORY_LISTING );
			}
			touch = null;
		}
		
		/**
		 * Show vip info.
		 */		
		private function onShowVipInfo(event:Event):void
		{
			advancedOwner.showScreen( ScreenIds.VIP_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_greenSide.removeEventListener(TouchEvent.TOUCH, onAccessEncheres);
			_greenSide.removeFromParent(true);
			_greenSide = null;
			
			_blueSide.removeFromParent(true);
			_blueSide.removeEventListener(TouchEvent.TOUCH, onAccessBoutiqueVip);
			_blueSide = null;
			
			_encheresTitle.removeFromParent(true);
			_encheresTitle = null;
			
			TweenMax.killTweensOf(_encheresParticles);
			Starling.juggler.remove(_encheresParticles);
			_encheresParticles.stop(true);
			_encheresParticles.removeFromParent(true);
			_encheresParticles = null;
			
			TweenMax.killTweensOf(_encheresImage);
			_encheresImage.removeFromParent(true);
			_encheresImage = null;
			
			TweenMax.killTweensOf(_encheresAccessButton);
			_encheresAccessButton.removeEventListener(Event.TRIGGERED, onAccessEncheres);
			_encheresAccessButton.removeFromParent(true);
			_encheresAccessButton = null;
			
			_encheresMessage.removeFromParent(true);
			_encheresMessage = null;
			
			_boutiqueTitle.removeFromParent(true);
			_boutiqueTitle = null;
			
			TweenMax.killTweensOf(_boutiqueImage);
			_boutiqueImage.removeFromParent(true);
			_boutiqueImage = null;
			
			_buildings.removeFromParent(true);
			_buildings = null;
			
			TweenMax.killTweensOf(_glow);
			_glow.removeFromParent(true);
			_glow = null;
			
			TweenMax.killTweensOf(_boutiqueAccessButton);
			_boutiqueAccessButton.removeEventListener(Event.TRIGGERED, onAccessBoutiqueVip);
			_boutiqueAccessButton.removeFromParent(true);
			_boutiqueAccessButton = null;
			
			_boutiqueMessage.removeFromParent(true);
			_boutiqueMessage = null;
			
			_vipInfo.removeEventListener(Event.TRIGGERED, onShowVipInfo);
			_vipInfo.removeFromParent(true);
			_vipInfo = null;
			
			_vipInfoBlueStripe.removeFromParent(true);
			_vipInfoBlueStripe = null;
			
			_vipInfoGreenStripe.removeFromParent(true);
			_vipInfoGreenStripe = null;
			
			super.dispose();
		}
	}
}