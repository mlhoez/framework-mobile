/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 23 oct. 2013
*/
package com.ludofactory.mobile.core.test.pause
{
	import com.greensock.TweenLite;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.ads.AdManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	
	import starling.display.Button;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class PauseView extends FeathersControl
	{
		/**
		 * Dark background */		
		private var _darkness:Quad;
		
		/**
		 * Title */		
		private var _titleLabel:Label;
		
		/**
		 * Resume button */		
		private var _resumeButton:feathers.controls.Button;
		
		/**
		 * Exit button */		
		private var _exitButton:feathers.controls.Button;
		
		/**
		 *  */		
		private var _fxButton:starling.display.Button;
		/**
		 *  */		
		private var _musicButton:starling.display.Button;
		
		public function PauseView()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_darkness = new Quad(GlobalConfig.stageWidth, GlobalConfig.stageHeight, 0x000000);
			_darkness.alpha = 0;
			addChild(_darkness);
			
			_titleLabel = new Label();
			_titleLabel.alpha = 0;
			_titleLabel.text = Localizer.getInstance().translate("COMMON.PAUSE");
			addChild(_titleLabel);
			_titleLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(28), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_resumeButton = new feathers.controls.Button();
			_resumeButton.alpha = 0;
			_resumeButton.label = Localizer.getInstance().translate("COMMON.RESUME");
			addChild(_resumeButton);
			
			_exitButton = new feathers.controls.Button();
			_exitButton.alpha = 0;
			_exitButton.nameList.add( Theme.BUTTON_RED );
			_exitButton.label = Localizer.getInstance().translate("COMMON.QUIT");
			addChild(_exitButton);
			
			_fxButton = new starling.display.Button( AbstractEntryPoint.assets.getTexture("fx-button") );
			_fxButton.scaleX = _fxButton.scaleY = GlobalConfig.dpiScale;
			addChild(_fxButton);
			
			_musicButton = new starling.display.Button( AbstractEntryPoint.assets.getTexture("music-button") );
			_musicButton.scaleX = _musicButton.scaleY = GlobalConfig.dpiScale;
			addChild(_musicButton);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				//var rect:Rectangle = AdMobAdType.getPixelSize( AdMobAdType.IAB_MRECT );
				
				_titleLabel.width = _darkness.width;
				_titleLabel.validate();
				_titleLabel.y = (_darkness.height * 0.5 - _titleLabel.height) * 0.5;
				
				_resumeButton.width = _exitButton.width = _darkness.width * 0.5;
				_resumeButton.validate();
				_exitButton.validate();
				
				_resumeButton.x = (_darkness.width - _resumeButton.width) * 0.5;
				_resumeButton.y = _darkness.height * 0.5 - _resumeButton.height - scaleAndRoundToDpi(10);
				
				_exitButton.x = (_darkness.width - _exitButton.width) * 0.5;
				_exitButton.y = _darkness.height * 0.5 + scaleAndRoundToDpi(10);
				
				_fxButton.x = (_darkness.width * 0.5) - _fxButton.width;
				_fxButton.y = _exitButton.y + _exitButton.height + scaleAndRoundToDpi(10);
				
				_musicButton.x = (_darkness.width * 0.5);
				_musicButton.y = _exitButton.y + _exitButton.height + scaleAndRoundToDpi(10);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Animate in - out
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Play the animation in.
		 */		
		public function animateIn(manualCall:Boolean):void
		{
			enableUi();
			TweenLite.to(_darkness,  manualCall ? .5:0, { alpha:.8, onComplete:onAnimationInComplete});
			TweenLite.to(_titleLabel, manualCall ? .5:0, { alpha:1 });
			TweenLite.to(_resumeButton, manualCall ? .5:0, { alpha:1 });
			TweenLite.to(_exitButton, manualCall ? .5:0, { alpha:1 });
			TweenLite.to(_fxButton, manualCall ? .5:0, { alpha:Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED)) ? 1 : 0.5 });
			TweenLite.to(_musicButton, manualCall ? .5:0, { alpha:Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED)) ? 1 : 0.5 });
		}
		
		/**
		 * When the animation in is complete.
		 */		
		private function onAnimationInComplete():void
		{
			dispatchEventWith(LudoEventType.ANIMATION_IN_COMPLETE);
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_DISPLAY_ADS) == true )
				AdManager.setBannersVisibility(true);
		}
		
		/**
		 * Play the animation out.
		 */		
		public function animateOut():void
		{
			disableUi();
			TweenLite.to(_darkness,  .5, { alpha:0, onComplete:onAnimationOutComplete});
			TweenLite.to(_titleLabel, .5, { alpha:0 });
			TweenLite.to(_resumeButton, .5, { alpha:0 });
			TweenLite.to(_exitButton, .5, { alpha:0 });
			TweenLite.to(_fxButton, .5, { alpha:0 });
			TweenLite.to(_musicButton, .5, { alpha:0 });
		}
		
		/**
		 * When the animation out is complete.
		 */		
		private function onAnimationOutComplete():void
		{
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_DISPLAY_ADS) == true )
				AdManager.setBannersVisibility(false);
			dispatchEventWith(LudoEventType.ANIMATION_OUT_COMPLETE);
		}
		
		private function onSwitchFx(event:Event):void
		{
			Storage.getInstance().setProperty( StorageConfig.PROPERTY_SOUND_ENABLED, !Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED)) );
			_fxButton.alpha = Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED)) ? 1 : 0.5;
			
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED)) )
				SoundManager.getInstance().unmutePlaylist("sfx", 1);
			else
				SoundManager.getInstance().mutePlaylist("sfx", 1);
		}
		
		private function onSwitchMusic(event:Event):void
		{
			Storage.getInstance().setProperty( StorageConfig.PROPERTY_MUSIC_ENABLED, !Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED)) );
			_musicButton.alpha = Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED)) ? 1 : 0.5;
			
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED)) )
				SoundManager.getInstance().unmutePlaylist("music", 1);
			else
				SoundManager.getInstance().mutePlaylist("music", 1);
		}
		
		
		
//------------------------------------------------------------------------------------------------------------
//	Utils
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Enables the user interface.
		 */		
		private function enableUi():void
		{
			this.touchable = true;
			_resumeButton.addEventListener(Event.TRIGGERED, onResume);
			_exitButton.addEventListener(Event.TRIGGERED, onExit);
			_fxButton.addEventListener(Event.TRIGGERED, onSwitchFx);
			_musicButton.addEventListener(Event.TRIGGERED, onSwitchMusic);
			_darkness.addEventListener(TouchEvent.TOUCH, onTouchOverlay);
		}
		
		/**
		 * Disables the user interface.
		 */		
		private function disableUi():void
		{
			this.touchable = false;
			_resumeButton.removeEventListener(Event.TRIGGERED, onResume);
			_exitButton.removeEventListener(Event.TRIGGERED, onExit);
			_fxButton.removeEventListener(Event.TRIGGERED, onSwitchFx);
			_musicButton.removeEventListener(Event.TRIGGERED, onSwitchMusic);
			_darkness.removeEventListener(TouchEvent.TOUCH, onTouchOverlay);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onResume(event:Event = null):void
		{
			animateOut();
			dispatchEventWith(LudoEventType.RESUME);
		}
		
		private function onExit(event:Event):void
		{
			animateOut();
			dispatchEventWith(LudoEventType.EXIT);
		}
		
		private function onTouchOverlay(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_darkness);
			if( touch && touch.phase == TouchPhase.ENDED )
				onResume();
			touch = null;
		}
		
	}
}