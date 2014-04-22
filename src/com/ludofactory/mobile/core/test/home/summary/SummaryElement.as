/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 9 août 2013
*/
package com.ludofactory.mobile.core.test.home.summary
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Callout;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.utils.formatString;
	
	public class SummaryElement extends FeathersControl
	{
		/**
		 * The background. */		
		private var _background:Scale9Image;
		/**
		 * The label. */		
		private var _label:Label;
		private var _firstQuestionLabel:Label;
		private var _secondQuestionLabel:Label;
		private var _thirdQuestionLabel:Label;
		/**
		 * The icon. */		
		private var _icon:ImageLoader;
		
		/**
		 * The type used to choose the correct icon and background. */		
		private var _type:String;
		/**
		 * The icon background name. */		
		private var _backgroundTextureName:String;
		/**
		 * The icon texture name. */		
		private var _iconTextureName:String;
		
		private var _calloutLabel:Label;
		
		private var _isCalloutDisplaying:Boolean = false;
		
		private var _animationLabel:Label;
		
		public var _oldTweenValue:int;
		public var _targetTweenValue:int;
		
		private var _isInterrogationDisplaying:Boolean = false;
		
		/**
		 * Particles */		
		private var _particles:PDParticleSystem;
		
		public function SummaryElement(type:String)
		{
			super();
			_type = type;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_calloutLabel = new Label();
			
			switch(_type)
			{
				case GameSession.PRICE_FREE:
				{
					_backgroundTextureName = "summary-green-container";
					_iconTextureName = GlobalConfig.isPhone ? "summary-icon-free" : "summary-icon-free-hd";
					_calloutLabel.text = formatString(Localizer.getInstance().translate("SUMMARY.FREE_TEXT"), MemberManager.getInstance().getNumFreeGameSessionsTotal());
					break;
				}
				case GameSession.PRICE_CREDIT:
				{
					_backgroundTextureName = "summary-yellow-container";
					_iconTextureName = GlobalConfig.isPhone ? "summary-icon-credits" : "summary-icon-credits-hd";
					_calloutLabel.text = Localizer.getInstance().translate("SUMMARY.CREDITS_TEXT");
					break;
				}
				case GameSession.PRICE_POINT:
				{
					_backgroundTextureName = "summary-blue-container";
					_iconTextureName = GlobalConfig.isPhone ? "summary-icon-points" : "summary-icon-points-hd";
					_calloutLabel.text = Localizer.getInstance().translate("SUMMARY.POINTS_TEXT");
					break;
				}
			}
			
			const textures:Scale9Textures = new Scale9Textures( AbstractEntryPoint.assets.getTexture( _backgroundTextureName ), new Rectangle(18, 18, 14, 14) );
			_background = new Scale9Image( textures, GlobalConfig.dpiScale);
			addChild( _background );
			textures.texture.dispose();
			
			_icon = new ImageLoader();
			_icon.source = AbstractEntryPoint.assets.getTexture( _iconTextureName );
			_icon.textureScale = GlobalConfig.dpiScale;
			_icon.snapToPixels = true;
			addChild(_icon);
			
			_particles = new PDParticleSystem(Theme.particleSlowXml, AbstractEntryPoint.assets.getTexture(_iconTextureName));
			_particles.touchable = false;
			_particles.maxNumParticles = 100;
			_particles.radialAccelerationVariance = 0;
			_particles.startColor.alpha = 0.6;
			_particles.endColor.alpha = 0;
			_particles.speed = 10;
			_particles.speedVariance = 5;
			_particles.lifespan = 1;
			_particles.lifespanVariance = 0.5;
			addChild(_particles);
			
			_label = new Label();
			_label.text = "00:00";
			addChild(_label);
			_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), 0xe2bf89, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_animationLabel = new Label();
			_animationLabel.visible = false;
			_animationLabel.alpha = 0;
			addChild(_animationLabel);
			_animationLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(46), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_animationLabel.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 6, 6, 5) ];
			
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_icon.x = ( (this.actualWidth - _icon.width) * 0.5 ) << 0;
				_icon.y = _icon.y << 0;
				
				_background.width = this.actualWidth;
				_background.y = (_icon.height * 0.35) << 0;
				_background.x = _background.x << 0;
				_background.height = this.actualHeight - _background.y;
				
				_label.width = _background.width;
				_label.validate();
				_label.y = ((this.actualHeight - _icon.height - scaleAndRoundToDpi(10)) - _label.height) * 0.5 + _icon.height;
				
				_calloutLabel.width = GlobalConfig.stageWidth * 0.9;
				_calloutLabel.validate();
				
				_particles.emitterX = _particles.emitterXVariance = actualWidth * 0.5;
				_particles.emitterY = _particles.emitterYVariance = actualHeight * 0.5;
				
				_animationLabel.width = actualWidth;
				
				if( _isInterrogationDisplaying )
				{
					TweenLite.killTweensOf([_firstQuestionLabel,_secondQuestionLabel,_thirdQuestionLabel]);
					
					_firstQuestionLabel.validate();
					_saveXFirst = _firstQuestionLabel.x = (_background.width - (_firstQuestionLabel.width * 3)) * 0.5;
					_saveXSecond = _secondQuestionLabel.x = _firstQuestionLabel.x + _firstQuestionLabel.width;
					_saveXThird = _thirdQuestionLabel.x = _firstQuestionLabel.x + (_firstQuestionLabel.width * 2);
					_saveY = _firstQuestionLabel.y = _secondQuestionLabel.y = _thirdQuestionLabel.y = ((this.actualHeight - _icon.height - scaleAndRoundToDpi(10)) - _firstQuestionLabel.height) * 0.5 + _icon.height;
					
					_firstQuestionLabel.visible = _secondQuestionLabel.visible = _thirdQuestionLabel.visible = true;
					repeatAnimation();
				}
			}
			
			//setSizeInternal(this.actualWidth, _background.height, false);
		}
		
		private function repeatAnimation():void
		{
			TweenLite.to(_firstQuestionLabel, 0.85, { delay:1, bezier:[{x:_saveXFirst, y:(_saveY - scaleAndRoundToDpi(8))}, {x:_saveXFirst, y:_saveY}], orientToBezier:false/*, ease:Bounce.easeOut*/});
			TweenLite.to(_secondQuestionLabel, 0.85, { delay:1.15, bezier:[{x:_saveXSecond, y:(_saveY - scaleAndRoundToDpi(8))}, {x:_saveXSecond, y:_saveY}], orientToBezier:false/*, ease:Bounce.easeOut*/});
			TweenLite.to(_thirdQuestionLabel, 0.85, { delay:1.3, bezier:[{x:_saveXThird, y:(_saveY - scaleAndRoundToDpi(8))}, {x:_saveXThird, y:_saveY}], orientToBezier:false/*, ease:Bounce.easeOut*/, onComplete:repeatAnimation});
		}
		private var _saveXFirst:int;
		private var _saveXSecond:int;
		private var _saveXThird:int;
		private var _saveY:int;
		/**
		 * Updates the label text.
		 */		
		public function setLabelText(value:String):void
		{
			if( value == "???" || (value == "-" && MemberManager.getInstance().getNumFreeGameSessions() == 0) )
			{
				if( !_isInterrogationDisplaying )
				{
					_label.text = "";
					addInterrogationLabels();
				}
			}
			else
			{
				if( _isInterrogationDisplaying )
					removeInterrogationLabels();
				_label.text = value;
				if( MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().getNumFreeGameSessions() == 0 )
					_calloutLabel.text = formatString(Localizer.getInstance().translate("SUMMARY.FREE_TEXT_TIMER"), MemberManager.getInstance().getNumFreeGameSessionsTotal(), value); 
			}
			
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * Animates a change in the element.
		 */		
		public function animateChange(newValue:int):void
		{
			//(_animationLabel.textRendererProperties.textFormat as TextFormat).color = newValue < 0 ? 0xB00909 : 0x57C40E;
			
			_oldTweenValue = int(_label.text.split(" ").join(""));
			_targetTweenValue = _oldTweenValue + newValue;
			if( newValue < 0 )
				TweenMax.to(this, 0.75, { _oldTweenValue : _targetTweenValue, onUpdate : function():void{ _label.text = Utilities.splitThousands(_oldTweenValue); }, ease:Linear.easeNone } );
			_animationLabel.text = (newValue < 0 ? "- " : "+ ") + Math.abs(newValue);
			_animationLabel.visible = false;
			_animationLabel.alpha = 0;
			_animationLabel.y = 0;
			TweenMax.to(_animationLabel, 1.25, { y:-50 });
			TweenMax.to(_animationLabel, 0.5, { autoAlpha:1, yoyo:true, repeatDelay:1, repeat:1 });
			
			Starling.juggler.add(_particles);
			_particles.addEventListener(Event.COMPLETE, onParticlesComplete);
			_particles.start(0.5);
		}
		
		private function onParticlesComplete(event:Event):void
		{
			_particles.removeEventListener(Event.COMPLETE, onParticlesComplete);
			Starling.juggler.remove(_particles);
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				if( !_isCalloutDisplaying )
				{
					_isCalloutDisplaying = true;
					
					switch(_type)
					{
						case GameSession.PRICE_FREE:
						{
							_calloutLabel.text = formatString(Localizer.getInstance().translate(MemberManager.getInstance().isLoggedIn() ? ( SummaryContainer.IS_TIMER_OVER_AND_REQUEST_FAILED ? "SUMMARY.TIMER_OVER_AND_REQUEST_FAILED" : "SUMMARY.FREE_TEXT") : "SUMMARY.FREE_TEXT_NOT_LOGGED_IN"), MemberManager.getInstance().getNumFreeGameSessionsTotal());
							break;
						}
						case GameSession.PRICE_CREDIT:
						{
							if( !MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().getNumFreeGameSessions() == 0 )
								_calloutLabel.text = formatString(Localizer.getInstance().translate(MemberManager.getInstance().isLoggedIn() ? "SUMMARY.CREDITS_TEXT" : "SUMMARY.FREE_TEXT_NOT_LOGGED_IN"), MemberManager.getInstance().getNumFreeGameSessionsTotal());
							else
								_calloutLabel.text = Localizer.getInstance().translate("SUMMARY.CREDITS_TEXT");
							break;
						}
						case GameSession.PRICE_POINT:
						{
							if( !MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().getNumFreeGameSessions() == 0 )
								_calloutLabel.text = formatString(Localizer.getInstance().translate(MemberManager.getInstance().isLoggedIn() ? "SUMMARY.POINTS_TEXT" : "SUMMARY.FREE_TEXT_NOT_LOGGED_IN"), MemberManager.getInstance().getNumFreeGameSessionsTotal());
							else
								_calloutLabel.text = Localizer.getInstance().translate("SUMMARY.POINTS_TEXT");
							break;
						}
					}
						
					var callout:Callout = Callout.show(_calloutLabel, this, Callout.DIRECTION_UP, false);
					callout.touchable = false;
					callout.disposeContent = false;
					callout.addEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
					_calloutLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
					
					if( !MemberManager.getInstance().isLoggedIn() && (_type == GameSession.PRICE_FREE || MemberManager.getInstance().getNumFreeGameSessions() == 0))
					{
						callout.touchable = true;
						callout.addEventListener(TouchEvent.TOUCH, onRegister);
					}
				}
			}
			callout = null;
			touch = null;
		}
		
		private function onRegister(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(DisplayObject(event.target));
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				DisplayObject(event.target).removeFromParent();
				AbstractEntryPoint.screenNavigator.showScreen(ScreenIds.AUTHENTICATION_SCREEN);
			}
			touch = null;
		}
		
		private function onCalloutRemoved(event:Event):void
		{
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			event.target.removeEventListener(TouchEvent.TOUCH, onRegister);
			_isCalloutDisplaying = false;
		}
		
		private function addInterrogationLabels():void
		{
			_firstQuestionLabel = new Label();
			_firstQuestionLabel.text = "?";
			_firstQuestionLabel.visible = false;
			addChild(_firstQuestionLabel);
			_firstQuestionLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), 0xe2bf89);
			
			_secondQuestionLabel = new Label();
			_secondQuestionLabel.text = "?";
			_secondQuestionLabel.visible = false;
			addChild(_secondQuestionLabel);
			_secondQuestionLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), 0xe2bf89);
			
			_thirdQuestionLabel = new Label();
			_thirdQuestionLabel.text = "?";
			_thirdQuestionLabel.visible = false;
			addChild(_thirdQuestionLabel);
			_thirdQuestionLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), 0xe2bf89);
			
			_isInterrogationDisplaying = true;
		}
		
		private function removeInterrogationLabels():void
		{
			TweenLite.killTweensOf(_firstQuestionLabel);
			_firstQuestionLabel.removeFromParent(true);
			_firstQuestionLabel = null;
			
			TweenLite.killTweensOf(_secondQuestionLabel);
			_secondQuestionLabel.removeFromParent(true);
			_secondQuestionLabel = null;
			
			TweenLite.killTweensOf(_thirdQuestionLabel);
			_thirdQuestionLabel.removeFromParent(true);
			_thirdQuestionLabel = null;
			
			_isInterrogationDisplaying = false;
		}
	}
}