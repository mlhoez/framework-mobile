/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 21 août 2013
*/
package com.ludofactory.mobile.navigation.shop
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
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
		 * The encheres title */		
		//private var _encheresTitle:Label;
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
		//private var _boutiqueTitle:Label;
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
		
		public function BoutiqueHomeScreen()
		{
			super();
			
			_fullScreen = false;
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// Enchères
			
			_encheresParticles = new PDParticleSystem(Theme.particleSlowXml, Theme.particleRoundTexture);
			_encheresParticles.touchable = false;
			_encheresParticles.maxNumParticles = 500;
			addChild(_encheresParticles);
			Starling.juggler.add(_encheresParticles);
			
			_encheresImage = new Image( AbstractEntryPoint.assets.getTexture("EncheresImage") );
			_encheresImage.touchable = false;
			_encheresImage.scaleX = _encheresImage.scaleY = GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? ((GlobalConfig.isPhone ? 0.1 : 0) * GlobalConfig.dpiScale) : 0);
			_encheresImage.alignPivot();
			_encheresImage.alpha = 0;
			_encheresImage.rotation = deg2rad(90);
			addChild(_encheresImage);
			
			_encheresAccessButton = new Button();
			_encheresAccessButton.label = _("Enchères");
			_encheresAccessButton.addEventListener(Event.TRIGGERED, onAccessEncheres);
			_encheresAccessButton.alpha = 0;
			addChild(_encheresAccessButton);
			
			_encheresMessage = new Label();
			_encheresMessage.touchable = false;
			_encheresMessage.text = _("Accessible à tous\nles rangs Vip");
			addChild( _encheresMessage );
			_encheresMessage.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 32 : 40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// Boutique Vip
			
			_glow = new Image( AbstractEntryPoint.assets.getTexture("HighScoreGlow") );
			_glow.touchable = false;
			_glow.scaleX = _glow.scaleY = GlobalConfig.dpiScale;
			_glow.alignPivot();
			_glow.alpha = 0;
			addChild(_glow);
			
			_boutiqueMessage = new Label();
			_boutiqueMessage.touchable = false;
			_boutiqueMessage.text = _("A partir du\nrang Aventurier I");
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
			_boutiqueImage.scaleX = _boutiqueImage.scaleY = GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? ((GlobalConfig.isPhone ? 0.1 : 0) * GlobalConfig.dpiScale) : 0);
			_boutiqueImage.alignPivot();
			_boutiqueImage.alpha = 0;
			_boutiqueImage.rotation = deg2rad(-90);
			addChild(_boutiqueImage);
			
			_boutiqueAccessButton = new Button();
			_boutiqueAccessButton.label = _("Boutique VIP");
			_boutiqueAccessButton.alpha = 0;
			_boutiqueAccessButton.addEventListener(Event.TRIGGERED, onAccessBoutiqueVip);
			addChild(_boutiqueAccessButton);
			
			/*
			_encheresTitle = new Label();
			_encheresTitle.touchable = false;
			_encheresTitle.text = _("Enchères");
			addChild(_encheresTitle);
			_encheresTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 48 : 64), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_encheresTitle.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 5, 5, 3) ];
			*/
			
			/*
			_boutiqueTitle = new Label();
			_boutiqueTitle.touchable = false;
			_boutiqueTitle.text = _("Boutique VIP");
			addChild(_boutiqueTitle);
			_boutiqueTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 48 : 64), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_boutiqueTitle.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 5, 5, 3) ];
			*/
			
			// vip info
			
			_vipInfo = new Button();
			_vipInfo.styleName = Theme.BUTTON_TRANSPARENT_WHITE;
			_vipInfo.label = _("Qu'est ce que les rangs Vip ?");
			_vipInfo.addEventListener(Event.TRIGGERED, onShowVipInfo);
			addChild(_vipInfo);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				createBackground();
				
				const scale:Number = GlobalConfig.dpiScale + (GlobalConfig.isPhone ? (-0.3 * GlobalConfig.dpiScale) : (0.3 * GlobalConfig.dpiScale));
				_encheresImage.scaleX = _encheresImage.scaleY = _boutiqueImage.scaleX = _boutiqueImage.scaleY = scale; // GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? ((GlobalConfig.isPhone ? 0.2 : 0) * GlobalConfig.dpiScale) : 0);
				
				if( AbstractGameInfo.LANDSCAPE )
				{
					/*_encheresTitle.width = _boutiqueTitle.width = actualWidth * 0.5;
					_encheresTitle.y = _boutiqueTitle.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 30);
					_boutiqueTitle.x = actualWidth * 0.5;*/
					
					_vipInfo.validate();
					//_boutiqueMessage.validate();
					_vipInfo.y = actualHeight - _vipInfo.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 15 : 40);
					_vipInfo.x = (this.actualWidth - _vipInfo.width) * 0.5;
					
					_encheresImage.x = actualWidth * 0.25;
					_encheresImage.y = _boutiqueImage.y = _vipInfo.y * (GlobalConfig.isPhone ? 0.35 : 0.45);
					_glow.y = _buildings.y = _vipInfo.y * (GlobalConfig.isPhone ? 0.25 : 0.35);
					_boutiqueImage.x = _glow.x = _buildings.x = actualWidth * 0.75;
					
					_encheresAccessButton.height = _boutiqueAccessButton.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 100 : 140);
					_encheresAccessButton.width = _boutiqueAccessButton.width = actualWidth * 0.35;
					_encheresAccessButton.y = _boutiqueAccessButton.y =  _boutiqueImage.y + _boutiqueImage.height * 0.4;
					_encheresAccessButton.x = _encheresImage.x - _encheresAccessButton.width * 0.5;
					_boutiqueAccessButton.x = _boutiqueImage.x - _boutiqueAccessButton.width * 0.5;
					
					_encheresParticles.alpha = 0;
					_encheresParticles.x = _encheresImage.x;
					_encheresParticles.y = _encheresImage.y;
					_encheresParticles.start();
					
					_encheresMessage.y = _boutiqueMessage.y = _encheresAccessButton.y + _encheresAccessButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 40);
					_encheresMessage.width = _boutiqueMessage.width = actualWidth * 0.5;
					_boutiqueMessage.x = actualWidth * 0.5;
				}
				else
				{
					/*_encheresTitle.width = _boutiqueTitle.width = actualWidth * 0.5;
					_encheresTitle.y = _boutiqueTitle.y = this.actualHeight * (GlobalConfig.isPhone ? 0.05 : 0.1);
					_boutiqueTitle.x = actualWidth * 0.5;*/
					
					_encheresImage.x = actualWidth * 0.25;
					_encheresImage.y = _boutiqueImage.y = _glow.y = _buildings.y = this.actualHeight * 0.4;
					_boutiqueImage.x = _glow.x = _buildings.x = actualWidth * 0.75;
					
					_encheresAccessButton.width = _boutiqueAccessButton.width = actualWidth * 0.4;
					_encheresAccessButton.y =_boutiqueAccessButton.y =  _encheresImage.y + _encheresImage.height * 0.25;
					_encheresAccessButton.x = _encheresImage.x - _encheresAccessButton.width * 0.5;
					_boutiqueAccessButton.x = _boutiqueImage.x - _boutiqueAccessButton.width * 0.5;
					
					_encheresParticles.alpha = 0;
					_encheresParticles.x = _encheresImage.x;
					_encheresParticles.y = _encheresImage.y;
					_encheresParticles.start();
					
					_encheresMessage.y = _boutiqueMessage.y = _encheresAccessButton.y + _encheresAccessButton.height + scaleAndRoundToDpi(40);
					_encheresMessage.width = _boutiqueMessage.width = actualWidth * 0.5;
					_boutiqueMessage.x = actualWidth * 0.5;
					
					_vipInfo.validate();
					_boutiqueMessage.validate();
					_vipInfo.y = (_boutiqueMessage.y + _boutiqueMessage.height) + (  (this.actualHeight - (_boutiqueMessage.y + _boutiqueMessage.height) - _vipInfo.height) * 0.5 );
					_vipInfo.x = (this.actualWidth - _vipInfo.width) * 0.5;
				}
				 
				
				_encheresImage.scaleX = _encheresImage.scaleY = _boutiqueImage.scaleX = _boutiqueImage.scaleY = 0;
				TweenMax.to(_encheresParticles, 1, { alpha:1 });
				TweenMax.allTo([_encheresImage, _boutiqueImage], 1.75, { delay:0.25, scaleX:scale, scaleY:scale, alpha:1, rotation:deg2rad(0), ease:Elastic.easeOut });
				TweenMax.to([_encheresAccessButton, _boutiqueAccessButton], 0.5, { delay:0.5,  alpha:1 });
				TweenMax.to([_glow, _buildings], 1.5, { delay:1, alpha:0.75 });
				TweenMax.to(_glow, 20, { delay:0.5, rotation:deg2rad(360), repeat:-1, ease:Linear.easeNone });
			}
			
			super.draw();
		}
		
		private var _background:QuadBatch;
		
		private function createBackground():void
		{
			if( _background )
				_background.reset();
			
			var helperQuad:Quad;
			
			_background = new QuadBatch();
			
			// left green side
			helperQuad = new Quad(actualWidth * 0.5, actualHeight, 0x76ce2f);
			helperQuad.blendMode = BlendMode.MULTIPLY;
			_background.addQuad(helperQuad);
			
			// right blue side
			helperQuad.color = 0x00d8ff;
			helperQuad.x = actualWidth * 0.5;
			_background.addQuad(helperQuad);
			
			// left shadow
			helperQuad.blendMode = BlendMode.NONE;
			helperQuad.color = 0x000000;
			helperQuad.width = scaleAndRoundToDpi(5);
			helperQuad.setVertexAlpha(0, 0);
			helperQuad.setVertexAlpha(1, 0.35);
			helperQuad.setVertexAlpha(2, 0);
			helperQuad.setVertexAlpha(3, 0.35);
			helperQuad.x = actualWidth * 0.5 - scaleAndRoundToDpi(5);
			_background.addQuad(helperQuad);
			
			// right shadow
			helperQuad.setVertexAlpha(0, 0.35);
			helperQuad.setVertexAlpha(1, 0);
			helperQuad.setVertexAlpha(2, 0.35);
			helperQuad.setVertexAlpha(3, 0);
			helperQuad.x = actualWidth * 0.5;
			_background.addQuad(helperQuad);
			
			addChildAt(_background, 0);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Access boutique Vip.
		 */		
		private function onAccessEncheres(event:Event):void
		{
			advancedOwner.showScreen( ScreenIds.BIDS_HOME_SCREEN );
		}
		
		/**
		 * Access boutique Vip.
		 */		
		private function onAccessBoutiqueVip(event:Event):void
		{
			advancedOwner.showScreen( ScreenIds.BOUTIQUE_CATEGORY_LISTING );
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
			//_encheresTitle.removeFromParent(true);
			//_encheresTitle = null;
			
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
			
			//_boutiqueTitle.removeFromParent(true);
			//_boutiqueTitle = null;
			
			TweenMax.killTweensOf(_boutiqueImage);
			_boutiqueImage.removeFromParent(true);
			_boutiqueImage = null;
			
			TweenMax.killTweensOf(_buildings);
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
			
			super.dispose();
		}
	}
}