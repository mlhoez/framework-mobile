/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 19 juin 2013
*/
package com.ludofactory.mobile.core.test.engine
{
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.Utility;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.test.FacebookManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.display.StageAspectRatio;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.utils.deg2rad;
	import starling.utils.formatString;
	
	public class HighScoreScreen extends AdvancedScreen
	{
		/**
		 * High score logo (cup) */		
		private var _highScoreLogo:Image;
		/**
		 * High score glow */		
		private var _highScoreGlow:Image;
		/**
		 * High score label */		
		private var _highScoreLabel:Label;
		/**
		 * Particles */		
		private var _particles:PDParticleSystem;
		
		/**
		 * Facebook icon for the button. */		
		private var _facebookIcon:ImageLoader;
		/**
		 * Facebook button that will associate the
		 * account or directly publish, depending on
		 * the actual state. */		
		private var _facebookButton:Button;
		/**
		 * The continue button. */		
		private var _continueButton:Button;
		
		private var _facebookManager:FacebookManager;
		
		public function HighScoreScreen()
		{
			super();
			
			_fullScreen = true;
			_appDarkBackground = true;
			_canBack = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			Starling.current.nativeStage.addEventListener(flash.events.Event.RESIZE, onResize, false, int.MAX_VALUE, true);
			Starling.current.nativeStage.setAspectRatio(StageAspectRatio.PORTRAIT);
		}
		
		/**
		 * The application has finished resizing, we can start loading all the assets for
		 * the game. Depending on which type of device we are, we will load a specific
		 * size of the game assets so that it's big enough on any device.
		 */		
		private function onResize(event:flash.events.Event):void
		{
			Starling.current.nativeStage.removeEventListener(flash.events.Event.RESIZE, onResize, false);
			
			InfoManager.show( Localizer.getInstance().translate("COMMON.LOADING") );
			TweenMax.delayedCall(GlobalConfig.android ? 6:1, initContent);
		}
		
		private function initContent():void
		{
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			
			_highScoreGlow = new Image( AbstractEntryPoint.assets.getTexture("HighScoreGlow") );
			_highScoreGlow.alpha = 0;
			_highScoreGlow.scaleX = _highScoreGlow.scaleY = GlobalConfig.stageWidth / _highScoreGlow.width;
			_highScoreGlow.alignPivot();
			addChild( _highScoreGlow );
			
			_highScoreLogo = new Image( AbstractEntryPoint.assets.getTexture("HighScoreLogo") );
			_highScoreLogo.scaleX = _highScoreLogo.scaleY = GlobalConfig.dpiScale;
			_highScoreLogo.alignPivot();
			addChild( _highScoreLogo );
			
			_highScoreLabel = new Label();
			_highScoreLabel.alpha = 0;
			_highScoreLabel.text = formatString(Localizer.getInstance().translate("HIGH_SCORE.TITLE"), Utility.splitThousands( advancedOwner.screenData.gameData.score ));
			addChild(_highScoreLabel);
			_highScoreLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 76), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_highScoreLabel.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( File.applicationDirectory.resolvePath( "assets/particles/particles_sparkles.pex" ), FileMode.READ );
			var onTouchParticlesXml:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			fileStream = null;
			
			_particles = new PDParticleSystem(onTouchParticlesXml, AbstractEntryPoint.assets.getTexture("ParticleGui"));
			_particles.touchable = false;
			_particles.maxNumParticles = 500;
			_particles.scaleX = _particles.scaleY = GlobalConfig.dpiScale;
			addChild(_particles);
			Starling.juggler.add(_particles);
			
			if( MemberManager.getInstance().isLoggedIn() && GoViral.isSupported() && GoViral.goViral.isFacebookSupported() )
			{
				_facebookManager = new FacebookManager();
				_facebookManager.addEventListener(FacebookManager.ACCOUNT_ASSOCIATED, onAccountAssociated);
				_facebookManager.addEventListener(FacebookManager.AUTHENTICATED, onPublish);
					
				_continueButton = new Button();
				_continueButton.alpha = 0;
				_continueButton.addEventListener(starling.events.Event.TRIGGERED, onContinue);
				_continueButton.styleName = Theme.BUTTON_EMPTY;
				_continueButton.label = Localizer.getInstance().translate("COMMON.CONTINUE");
				addChild(_continueButton);
				_continueButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(30), Theme.COLOR_WHITE, true, true, null, null, null, TextFormatAlign.CENTER);
				_continueButton.height = _continueButton.minHeight = scaleAndRoundToDpi(60);
				
				_facebookIcon = new ImageLoader();
				_facebookIcon.source = AbstractEntryPoint.assets.getTexture( GlobalConfig.isPhone ? "facebook-icon" : "facebook-icon-hd");
				_facebookIcon.textureScale = GlobalConfig.dpiScale;
				_facebookIcon.snapToPixels = true;
				
				_facebookButton = new Button();
				_facebookButton.alpha = 0;
				_facebookButton.defaultIcon = _facebookIcon;
				_facebookButton.label = Localizer.getInstance().translate( MemberManager.getInstance().getFacebookId() != 0 ? "COMMON.PUBLISH" : "COMMON.ASSOCIATE")
				_facebookButton.addEventListener(starling.events.Event.TRIGGERED, onAssociateOrPublish);
				addChild(_facebookButton);
				_facebookButton.iconPosition = Button.ICON_POSITION_LEFT;
				_facebookButton.gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
			}
			
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) && _highScoreLogo)
			{
				_highScoreGlow.x = this.actualWidth * 0.5;
				_highScoreGlow.y = this.actualHeight * (_facebookButton ? 0.3 : 0.4) + _highScoreLogo.height * 0.1;
				TweenMax.to(_highScoreGlow, 0.75, { delay:0.75, alpha:1 } );
				TweenMax.to(_highScoreGlow, 10, { delay:0.75, rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 } );
				
				_highScoreLogo.x = this.actualWidth * 0.5;
				_highScoreLogo.y = this.actualHeight * (_facebookButton ? 0.3 : 0.4);
				
				if( _facebookButton )
				{
					_continueButton.validate();
					_continueButton.x = (actualWidth - _continueButton.width) * 0.5;
					_continueButton.y = actualHeight - _continueButton.height - scaleAndRoundToDpi(20);
					
					_facebookButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_facebookButton.validate();
					_facebookButton.y = _continueButton.y - _facebookButton.height - scaleAndRoundToDpi(10);
					_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
					
					TweenMax.to(_facebookButton, 0.75, { delay:2, alpha:1 });
					TweenMax.to(_continueButton, 0.75, { delay:2.5, alpha:1 });
				}
				
				_highScoreLabel.width = this.actualWidth;
				_highScoreLabel.validate();
				if( _facebookButton )
					_highScoreLabel.y = (_highScoreLogo.y + _highScoreLogo.height * 0.5) + ( ((_facebookButton.y - (_highScoreLogo.y + _highScoreLogo.height * 0.5)) - _highScoreLabel.height ) * 0.5 )
				else
					_highScoreLabel.y = (( (this.actualHeight - (_highScoreLogo.y + _highScoreLogo.height * 0.5)) - _highScoreLabel.height ) * 0.5) + _highScoreLogo.y + _highScoreLogo.height * 0.5;
				TweenMax.to(_highScoreLabel, 0.75, { delay:1.5, alpha:1 } );
				
				_particles.x = _highScoreLogo.x;
				_particles.y = _highScoreLogo.y;
				_particles.emitterXVariance = _highScoreLogo.width * 0.5;
				_particles.emitterYVariance = _highScoreLogo.height * 0.5;
				TweenMax.delayedCall(0.5, _particles.start, [0.2]);
				
				_highScoreLogo.scaleX = _highScoreLogo.scaleY = 0;
				TweenMax.to(_highScoreLogo, 0.75, { delay:0.5, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, ease:Back.easeOut } );
				
				SoundManager.getInstance().playSound("highscore_bis", "sfx");
				
				if( !_facebookButton )
					Starling.juggler.delayCall(onContinue, 5);
			}
		}
		
		/**
		 * There are two possibilities when the animation is over :
		 *  - First, the member was in tournament and change level. In this case
		 * 	  we need to show him the podium animation and then go to the result screen.
		 * 	- Second, the member was in tournament but didn't change level OR he was in
		 * 	  free mode. In this case, we just need to redirect him to the result screen.
		 */		
		private function goToNextScreen():void
		{
			TweenMax.killAll();
			if( advancedOwner.screenData.gameData.facebookFriends )
			{
				// animation des amis
				advancedOwner.showScreen( ScreenIds.FACEBOOK_END_SCREEN );
			}
			else
			{
				advancedOwner.showScreen( advancedOwner.screenData.gameData.hasReachNewTop ? ScreenIds.PODIUM_SCREEN : (advancedOwner.screenData.gameType == GameSession.TYPE_CLASSIC ? ScreenIds.FREE_GAME_END_SCREEN:ScreenIds.TOURNAMENT_GAME_END_SCREEN) );
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Facebook
		
		private function onAssociateOrPublish(event:starling.events.Event):void
		{
			_facebookManager.associateForPublish();
		}
		
		private function onAccountAssociated(event:starling.events.Event):void
		{
			_facebookButton.label = Localizer.getInstance().translate("COMMON.PUBLISH");
		}
		
		/**
		 * Publish on Facebook.
		 */		
		private function onPublish(event:starling.events.Event):void
		{
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
			
			GoViral.goViral.showFacebookFeedDialog( formatString(Localizer.getInstance().translate("FACEBOOK_HIGHSCORE_PUBLICATION.NAME"), AbstractGameInfo.GAME_NAME),
				"", "",
				formatString(Localizer.getInstance().translate("FACEBOOK_HIGHSCORE_PUBLICATION.DESCRIPTION"), advancedOwner.screenData.gameData.score),
				Localizer.getInstance().translate("FACEBOOK_HIGHSCORE_PUBLICATION.LINK"),
				formatString(Localizer.getInstance().translate("FACEBOOK_HIGHSCORE_PUBLICATION.IMAGE"), Localizer.getInstance().lang));
		}
		
		/**
		 * Publication cancelled or failed.
		 */		
		private function onPublishCancelledOrFailed(event:GVFacebookEvent):void
		{
			Flox.logEvent("Publications Facebook", {Etat:"Annulee"});
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
		}
		
		/**
		 * Publication posted.
		 */		
		private function onPublishOver(event:GVFacebookEvent):void
		{
			Flox.logEvent("Publications Facebook", {Etat:"Validee"});
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
			Starling.juggler.delayCall(onContinue, 1);
			touchable = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Next screen
		
		/**
		 * Continue.
		 */		
		private function onContinue():void
		{
			if( _facebookButton )
				TweenMax.allTo([_facebookButton, _continueButton], 0.5, { alpha:0 } );
			TweenMax.allTo([_highScoreGlow, _highScoreLabel], 0.5, { alpha:0 } );
			TweenMax.to(_highScoreGlow, 1, { rotation:deg2rad(360) } );
			TweenMax.to(_highScoreLogo, 0.5, { alpha:0, scaleX:0, scaleY:0, ease:Back.easeIn, onComplete:goToNextScreen } );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			TweenMax.killTweensOf(_highScoreGlow);
			_highScoreGlow.removeFromParent(true);
			_highScoreGlow = null;
			
			TweenMax.killTweensOf(_highScoreLabel);
			_highScoreLabel.removeFromParent(true);
			_highScoreLabel = null;
			
			TweenMax.killTweensOf(_highScoreLogo);
			_highScoreLogo.removeFromParent(true);
			_highScoreLogo = null;
			
			Starling.juggler.remove( _particles );
			_particles.stop(true);
			_particles.removeFromParent(true);
			_particles = null;
			
			if( _facebookButton )
			{
				_facebookManager.removeEventListener(FacebookManager.ACCOUNT_ASSOCIATED, onAccountAssociated);
				_facebookManager.removeEventListener(FacebookManager.AUTHENTICATED, onPublish);
				_facebookManager.dispose();
				_facebookManager = null;
				
				_continueButton.removeEventListener(starling.events.Event.TRIGGERED, onContinue);
				_continueButton.removeFromParent(true);
				_continueButton = null;
				
				_facebookIcon.removeFromParent(true);
				_facebookIcon = null;
				
				_facebookButton.removeEventListener(starling.events.Event.TRIGGERED, onAssociateOrPublish);
				_facebookButton.removeFromParent(true);
				_facebookButton = null;
				
				// just in case
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
			}
			
			super.dispose();
		}
		
	}
}