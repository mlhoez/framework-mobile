/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 3 oct. 2013
*/
package com.ludofactory.mobile.navigation
{
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class HowToWinGiftsScreen extends AdvancedScreen
	{
		/**
		 * The gifts image. */		
		private var _gifts:ImageLoader;
		
		/**
		 * The info (title). */		
		private var _title:Label;
		
		/**
		 * The button to follow the gifts. */		
		private var _followMyGiftsButton:Button;
		
		/**
		 * The left container. */		
		private var _leftContainer:LayoutGroup;
		private var _leftDescription:Label;
		private var _leftButton:Button;
		
		/**
		 * The right container. */		
		private var _rightContainer:LayoutGroup;
		private var _rightDescription:Label;
		private var _rightButton:Button;
		
		/**
		 * Particles */		
		private var _particles:PDParticleSystem;
		
		public function HowToWinGiftsScreen()
		{
			super();
			
			_howToWinGiftsBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_particles = new PDParticleSystem(Theme.particleSlowXml, Theme.particleRoundTexture);
			_particles.touchable = false;
			_particles.maxNumParticles = 300;
			_particles.startSizeVariance = 15;
			_particles.endSize = 10;
			_particles.endSizeVariance = 10;
			_particles.speed = 15;
			addChild(_particles);
			Starling.juggler.add(_particles);
			
			_gifts = new ImageLoader();
			_gifts.source = AbstractEntryPoint.assets.getTexture("gifts-" + (GlobalConfig.ios ? "apple" : "android"));
			_gifts.textureScale = GlobalConfig.dpiScale;
			_gifts.snapToPixels = true;
			addChild(_gifts);
			
			_title = new Label();
			_title.text = AbstractGameInfo.LANDSCAPE ? _("2 METHODES POUR GAGNER DES CADEAUX !") : _("2 METHODES POUR\nGAGNER DES CADEAUX !");
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? ((GlobalConfig.isPhone ? 40 : 62)) : (GlobalConfig.isPhone ? 50 : 72)), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_title.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 10, 10) ];
			
			_followMyGiftsButton = new Button();
			_followMyGiftsButton.addEventListener(Event.TRIGGERED, onFollowMyGiftsTouched);
			_followMyGiftsButton.label = _("Suivi de mes gains");
			addChild(_followMyGiftsButton);
			
			var containerLayout:VerticalLayout = new VerticalLayout();
			containerLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			containerLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			
			_leftContainer = new LayoutGroup();
			_leftContainer.layout = containerLayout;
			addChild(_leftContainer);
			
			_leftDescription = new Label();
			_leftDescription.text = _("Echangez vos\nPoints en Cadeaux");
			_leftContainer.addChild(_leftDescription);
			_leftDescription.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 36), 0x356700, true, true, null, null, null, TextFormatAlign.CENTER);
			
			_leftButton = new Button();
			_leftButton.addEventListener(Event.TRIGGERED, onShopTouched);
			_leftButton.label = _("Boutique");
			_leftContainer.addChild(_leftButton);
			_leftButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 38 : 46), Theme.COLOR_BROWN, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_rightContainer = new LayoutGroup();
			_rightContainer.layout = containerLayout;
			addChild(_rightContainer);
			
			_rightDescription = new Label();
			_rightDescription.text = _("Faites partie\ndu classement");
			_rightContainer.addChild(_rightDescription);
			_rightDescription.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 38), 0x006173, true, true, null, null, null, TextFormatAlign.CENTER);
			
			_rightButton = new Button();
			_rightButton.addEventListener(Event.TRIGGERED, onTournamentTouched);
			_rightButton.label = _("Tournois");
			_rightContainer.addChild(_rightButton);
			_rightButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 38 : 46), Theme.COLOR_BROWN, false, false, null, null, null, TextFormatAlign.CENTER);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				var leftGap:Number;
				var rightGap:Number;
				if( AbstractGameInfo.LANDSCAPE )
				{
					_gifts.width = actualWidth * (GlobalConfig.isPhone ? 0.5 : 0.7);
					_gifts.validate();
					_gifts.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
					_gifts.y = this.actualHeight * 0.95;
					_gifts.x = this.actualWidth * 0.5;
					
					_followMyGiftsButton.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 88 : 108);
					_followMyGiftsButton.validate();
					_followMyGiftsButton.width += scaleAndRoundToDpi(10);
					_followMyGiftsButton.x = (actualWidth - _followMyGiftsButton.width) * 0.5;
					_followMyGiftsButton.y = _gifts.y + ((actualHeight - _gifts.y) - _followMyGiftsButton.height) * 0.5 - scaleAndRoundToDpi(50);
					
					_title.width = actualWidth;
					_title.validate();
					_title.x = (actualWidth - _title.width) * 0.5;
					_title.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 20);
					
					_leftContainer.width = _leftDescription.width = this.actualWidth * 0.5;
					_leftContainer.y = _title.y + _title.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 40 );
					_leftContainer.height = _gifts.y - _leftContainer.y - _gifts.height - scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 40 );
					
					_leftDescription.validate();
					_leftButton.width = _rightButton.width = actualWidth * (GlobalConfig.isPhone ? 0.3 : 0.4);
					_leftButton.x = ((actualWidth * 0.5) - _leftButton.width) * 0.5;
					_rightButton.x = (actualWidth * 0.5) + _leftButton.x;
					_leftButton.height = _rightButton.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 88 : 118);
					
					leftGap = (_leftContainer.height - _leftDescription.height - _leftButton.height) / 2;
					_leftContainer.layout["gap"] = leftGap;
					
					_rightContainer.width = _rightDescription.width = this.actualWidth * 0.5;
					_rightContainer.x = this.actualWidth * 0.5;
					_rightContainer.y = _title.y + _title.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 40 );
					_rightContainer.height = _gifts.y - _rightContainer.y - _gifts.height - scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 40 );
					
					_rightDescription.validate();
					_rightButton.validate();
					
					rightGap = (_rightContainer.height - _rightDescription.height - _rightButton.height) / 2;
					_rightContainer.layout["gap"] = rightGap;
				}
				else
				{
					_gifts.width = actualWidth * (GlobalConfig.isPhone ? 0.9 : 0.8);
					_gifts.validate();
					_gifts.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
					_gifts.y = this.actualHeight * 0.87;
					_gifts.x = this.actualWidth * 0.5;
					
					_followMyGiftsButton.height = scaleAndRoundToDpi(108);
					_followMyGiftsButton.validate();
					_followMyGiftsButton.x = (actualWidth - _followMyGiftsButton.width) * 0.5;
					_followMyGiftsButton.y = _gifts.y + ((actualHeight - _gifts.y) - _followMyGiftsButton.height) * 0.5 - scaleAndRoundToDpi(20);
					
					_title.width = actualWidth;
					_title.validate();
					_title.x = (actualWidth - _title.width) * 0.5;
					_title.y = scaleAndRoundToDpi(20);
					
					_leftContainer.width = _leftDescription.width = this.actualWidth * 0.5;
					_leftContainer.y = _title.y + _title.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 40 );
					_leftContainer.height = _gifts.y - _leftContainer.y - _gifts.height - scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 40 );
					
					_leftDescription.validate();
					_leftButton.width = _rightButton.width = actualWidth * (GlobalConfig.isPhone ? 0.49 : 0.4);
					_leftButton.x = ((actualWidth * 0.5) - _leftButton.width) * 0.5;
					_rightButton.x = (actualWidth * 0.5) + _leftButton.x;
					_leftButton.height = _rightButton.height = scaleAndRoundToDpi(118);
					
					leftGap = (_leftContainer.height - _leftDescription.height - _leftButton.height) / 2;
					_leftContainer.layout["gap"] = leftGap;
					
					_rightContainer.width = _rightDescription.width = this.actualWidth * 0.5;
					_rightContainer.x = this.actualWidth * 0.5;
					_rightContainer.y = _title.y + _title.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 40 );
					_rightContainer.height = _gifts.y - _rightContainer.y - _gifts.height - scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 40 );
					
					_rightDescription.validate();
					_rightButton.validate();
					
					rightGap = (_rightContainer.height - _rightDescription.height - _rightButton.height) / 2;
					_rightContainer.layout["gap"] = rightGap;
				}
				
				_particles.emitterX = _gifts.x;
				_particles.emitterY = _gifts.y - (_gifts.height * 0.5);
				_particles.emitterXVariance = (_gifts.width * 0.5);
				_particles.emitterYVariance = (_gifts.height * 0.5);
				_particles.start();
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onShopTouched(event:Event):void
		{
			advancedOwner.showScreen( ScreenIds.BOUTIQUE_HOME );
		}
		
		private function onTournamentTouched(event:Event):void
		{
			advancedOwner.showScreen( ScreenIds.TOURNAMENT_RANKING_SCREEN );
		}
		
		private function onFollowMyGiftsTouched(event:Event):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				advancedOwner.showScreen( ScreenIds.MY_GIFTS_SCREEN );
			}
			else
			{
				advancedOwner.showScreen( ScreenIds.AUTHENTICATION_SCREEN );
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			TweenMax.killTweensOf(_particles);
			Starling.juggler.remove(_particles);
			_particles.stop(true);
			_particles.removeFromParent(true);
			_particles = null;
			
			_gifts.removeFromParent(true);
			_gifts = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_followMyGiftsButton.removeEventListener(Event.TRIGGERED, onFollowMyGiftsTouched);
			_followMyGiftsButton.removeFromParent(true);
			_followMyGiftsButton = null;
			
			_leftButton.removeEventListener(Event.TRIGGERED, onShopTouched);
			_leftButton.removeFromParent(true);
			_leftButton = null;
			
			_leftDescription.removeFromParent(true);
			_leftDescription = null;
			
			_leftContainer.removeFromParent(true);
			_leftContainer = null;
			
			_rightButton.removeEventListener(Event.TRIGGERED, onTournamentTouched);
			_rightButton.removeFromParent(true);
			_rightButton = null;
			
			_rightDescription.removeFromParent(true);
			_rightDescription = null;
			
			_rightContainer.removeFromParent(true);
			_rightContainer = null;
			
			super.dispose();
		}
		
	}
}