/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 23 oct. 2013
*/
package com.ludofactory.mobile.core.pause
{
	
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.ads.AdManager;
	
	import feathers.core.FeathersControl;
	
	import starling.display.Button;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	public class PauseView extends FeathersControl
	{
		/**
		 * Dark background */		
		private var _overlay:Quad;
		/**
		 * Title */		
		private var _title:TextField;
		/**
		 * Resume button */		
		private var _resumeButton:MobileButton;
		/**
		 * Exit button */		
		private var _exitButton:MobileButton;
		/**
		 * Sound effects button. */		
		private var _fxButton:Button;
		/**
		 * Music button. */		
		private var _musicButton:Button;
		
		public function PauseView()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_overlay = new Quad(GlobalConfig.stageWidth, GlobalConfig.stageHeight, 0x000000);
			_overlay.alpha = 0;
			_overlay.visible = false;
			addChild(_overlay);
			
			_title = new TextField(5, 5, "", Theme.FONT_SANSITA, scaleAndRoundToDpi(34), Theme.COLOR_WHITE);
			_title.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_title.alpha = 0;
			_title.visible = false;
			_title.text = _("Jeu en pause");
			addChild(_title);
			
			_resumeButton = ButtonFactory.getButton(_("Reprendre"), ButtonFactory.SPECIAL);
			_resumeButton.visible = false;
			_resumeButton.alpha = 0;
			addChild(_resumeButton);
			
			_exitButton = ButtonFactory.getButton(_("Abandonner"), ButtonFactory.RED);
			_exitButton.alpha = 0;
			_exitButton.visible = false;
			addChild(_exitButton);
			
			_fxButton = new Button( AbstractEntryPoint.assets.getTexture("fx-button") );
			_fxButton.scaleX = _fxButton.scaleY = GlobalConfig.dpiScale;
			addChild(_fxButton);
			
			_musicButton = new Button( AbstractEntryPoint.assets.getTexture("music-button") );
			_musicButton.scaleX = _musicButton.scaleY = GlobalConfig.dpiScale;
			addChild(_musicButton);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				//var rect:Rectangle = AdMobAdType.getPixelSize( AdMobAdType.IAB_MRECT );
				
				_resumeButton.width = _exitButton.width = GlobalConfig.stageWidth * (AbstractGameInfo.LANDSCAPE ? 0.5 : (GlobalConfig.isPhone ? 0.6 : 0.5));
				
				_resumeButton.x = _exitButton.x = (GlobalConfig.stageWidth - _resumeButton.width) * 0.5;
				_resumeButton.y = (GlobalConfig.stageHeight * 0.5) - _resumeButton.height - scaleAndRoundToDpi(10);
				_exitButton.y = (GlobalConfig.stageHeight * 0.5) + scaleAndRoundToDpi(10);
				
				_title.x = (GlobalConfig.stageWidth - _title.width) * 0.5;
				_title.y = _resumeButton.y - _title.height - scaleAndRoundToDpi(20);
				
				_fxButton.x = (GlobalConfig.stageWidth * 0.5) - _fxButton.width;
				_musicButton.x = (GlobalConfig.stageWidth * 0.5);
				_fxButton.y = _musicButton.y = _exitButton.y + _exitButton.height + scaleAndRoundToDpi(10);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Animate in - out
		
		/**
		 * Plays the animation in.
		 */		
		public function animateIn(manualCall:Boolean):void
		{
			enableUi();
			TweenLite.to(_overlay,  manualCall ? .5:0, { autoAlpha:.8, onComplete:onAnimationInComplete });
			TweenMax.allTo([_title, _resumeButton, _exitButton], manualCall ? .5:0, { autoAlpha:1 });
			TweenLite.to(_fxButton, manualCall ? .5:0, { autoAlpha:Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED)) ? 1 : 0.5 });
			TweenLite.to(_musicButton, manualCall ? .5:0, { autoAlpha:Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED)) ? 1 : 0.5 });
		}
		
		/**
		 * When the animation in is complete.
		 */		
		private function onAnimationInComplete():void
		{
			dispatchEventWith(MobileEventTypes.ANIMATION_IN_COMPLETE);
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_DISPLAY_ADS) == true )
				AdManager.setBannersVisibility(true);
		}
		
		/**
		 * Play the animation out.
		 */		
		public function animateOut():void
		{
			disableUi();
			TweenMax.allTo([_overlay, _title, _resumeButton, _exitButton, _fxButton, _musicButton], 0.5, { autoAlpha:0, onComplete:onAnimationOutComplete });
		}
		
		/**
		 * When the animation out is complete.
		 */		
		private function onAnimationOutComplete():void
		{
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_DISPLAY_ADS) == true )
				AdManager.setBannersVisibility(false);
			dispatchEventWith(MobileEventTypes.ANIMATION_OUT_COMPLETE);
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
			_overlay.addEventListener(TouchEvent.TOUCH, onTouchOverlay);
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
			_overlay.removeEventListener(TouchEvent.TOUCH, onTouchOverlay);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function onResume(event:Event = null):void
		{
			animateOut();
			dispatchEventWith(MobileEventTypes.RESUME);
		}
		
		private function onExit(event:Event):void
		{
			animateOut();
			dispatchEventWith(MobileEventTypes.EXIT);
		}
		
		private function onTouchOverlay(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_overlay);
			if( touch && touch.phase == TouchPhase.ENDED )
				onResume();
			touch = null;
		}
		
	}
}