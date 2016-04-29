/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 19 juin 2013
*/
package com.ludofactory.mobile.navigation.engine
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.model.ScreenData;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManagerEventType;
	import com.milkmangames.nativeextensions.GoViral;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.utils.StringUtil;
	import starling.utils.deg2rad;
	
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
		 * Confettis. */		
		private var _confettis:PDParticleSystem;
		/**
		 * Logo particles. */		
		private var _particles:PDParticleSystem;
		
		/**
		 * Facebook button that will associate the account or directly publish, depending on the actual state. */		
		private var _facebookButton:FacebookButton;
		/**
		 * The continue button. */		
		private var _continueButton:Button;
		
		public function HighScoreScreen()
		{
			super();
			
			_canBack = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// FIXME A décommenter pour gérer l'orientation
			//Starling.current.nativeStage.addEventListener(flash.events.Event.RESIZE, onResize, false, int.MAX_VALUE, true);
			//Starling.current.nativeStage.setAspectRatio(StageAspectRatio.PORTRAIT);
			
			initContent();
		}
		
		/**
		 * The application has finished resizing, we can start loading all the assets for
		 * the game. Depending on which type of device we are, we will load a specific
		 * size of the game assets so that it's big enough on any device.
		 */		
		private function onResize(event:flash.events.Event):void
		{
			Starling.current.nativeStage.removeEventListener(flash.events.Event.RESIZE, onResize, false);
			
			InfoManager.show( _("Chargement...") );
			TweenMax.delayedCall(GlobalConfig.android ? 6:1, initContent);
		}
		
		private function initContent():void
		{
			InfoManager.forceClose();
			
			_highScoreGlow = new Image( AbstractEntryPoint.assets.getTexture("HighScoreGlow") );
			_highScoreGlow.alpha = 0;
			_highScoreGlow.scaleX = _highScoreGlow.scaleY = GlobalConfig.stageWidth / (_highScoreGlow.width * (AbstractGameInfo.LANDSCAPE ? 1.5 : 1));
			_highScoreGlow.alignPivot();
			addChild( _highScoreGlow );
			
			_highScoreLogo = new Image( AbstractEntryPoint.assets.getTexture("HighScoreLogo") );
			_highScoreLogo.scaleX = _highScoreLogo.scaleY = GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? (0.1 * GlobalConfig.dpiScale) : 0);
			_highScoreLogo.alignPivot();
			addChild( _highScoreLogo );
			
			_highScoreLabel = new Label();
			_highScoreLabel.alpha = 0;
			_highScoreLabel.text = StringUtil.format(_("Nouveau High Score !\n{0}"), Utilities.splitThousands( ScreenData.getInstance().gameData.score ));
			addChild(_highScoreLabel);
			_highScoreLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 76), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_highScoreLabel.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			_particles = new PDParticleSystem(Theme.particleSparklesXml, Theme.particleSparklesTexture);
			_particles.touchable = false;
			_particles.capacity = 500;
			_particles.scaleX = _particles.scaleY = GlobalConfig.dpiScale;
			addChild(_particles);
			Starling.juggler.add(_particles);
			
			_continueButton = new Button();
			_continueButton.alpha = 0;
			_continueButton.addEventListener(starling.events.Event.TRIGGERED, onContinue);
			_continueButton.styleName = Theme.BUTTON_EMPTY;
			_continueButton.label = _("Continuer");
			addChild(_continueButton);
			_continueButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(30), Theme.COLOR_WHITE, true, true, null, null, null, TextFormatAlign.CENTER);
			_continueButton.height = _continueButton.minHeight = scaleAndRoundToDpi(60);
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Partager mon exploit !"), ButtonFactory.FACEBOOK_TYPE_SHARE, StringUtil.format(_("Nouveau meilleur score : {0} !"), ScreenData.getInstance().gameData.score),
					"",
					StringUtil.format(_("Venez me défier et tenter de battre mon score de {0} sur {1} !"), ScreenData.getInstance().gameData.score, AbstractGameInfo.GAME_NAME),
					_("http://www.ludokado.com/"),
					StringUtil.format(_("http://img.ludokado.com/img/frontoffice/{0}/mobile/publication/publication_highscore.jpg"), LanguageManager.getInstance().lang));
			_facebookButton.alpha = 0;
			_facebookButton.addEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
			addChild(_facebookButton);
			
			_confettis = new PDParticleSystem(Theme.particleConfettiXml, Theme.particleConfettiTexture);
			_confettis.touchable = false;
			_confettis.capacity = scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 750 : 500);
			_confettis.lifespan *= AbstractGameInfo.LANDSCAPE ? 1 : 2;
			_confettis.scaleX = _confettis.scaleY = GlobalConfig.dpiScale;
			addChild(_confettis);
			Starling.juggler.add(_confettis);
			
			if( MemberManager.getInstance().isLoggedIn() && GoViral.isSupported() && GoViral.goViral.isFacebookSupported() && MemberManager.getInstance().facebookId != 0 )
				GoViral.goViral.postFacebookHighScore(ScreenData.getInstance().gameData.score);
			
			// FIXME A décommenter pour gérer l'orientation
			//this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		override protected function draw():void
		{
			// FIXME A décommenter pour gérer l'orientation
			if( isInvalid(INVALIDATION_FLAG_SIZE) /* && _highScoreLogo */)
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					_highScoreLogo.x = this.actualWidth * 0.5;
					_highScoreLogo.y = (_highScoreLogo.height * 0.5) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 80);
					
					_highScoreGlow.x = this.actualWidth * 0.5;
					_highScoreGlow.y = _highScoreLogo.y + _highScoreLogo.height * 0.1;
					TweenMax.to(_highScoreGlow, 0.75, { delay:0.75, alpha:1 } );
					TweenMax.to(_highScoreGlow, 10, { delay:0.75, rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 } );
					
					_continueButton.validate();
					_continueButton.x = (actualWidth - _continueButton.width) * 0.5;
					_continueButton.y = actualHeight - _continueButton.height - scaleAndRoundToDpi(10);
					
					_facebookButton.width = actualWidth * 0.5;
					_facebookButton.validate();
					_facebookButton.y = _continueButton.y - _facebookButton.height - scaleAndRoundToDpi(10);
					_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
					
					TweenMax.to(_facebookButton, 0.75, { delay:2, alpha:1 });
					TweenMax.to(_continueButton, 0.75, { delay:2.5, alpha:1 });
					
					_highScoreLabel.width = this.actualWidth;
					_highScoreLabel.validate();
					if( _facebookButton )
						_highScoreLabel.y = (_highScoreLogo.y + _highScoreLogo.height * 0.5) + ( ((_facebookButton.y - (_highScoreLogo.y + _highScoreLogo.height * 0.5)) - _highScoreLabel.height ) * 0.5 )
					else
						_highScoreLabel.y = (( (this.actualHeight - (_highScoreLogo.y + _highScoreLogo.height * 0.5)) - _highScoreLabel.height ) * 0.5) + _highScoreLogo.y + _highScoreLogo.height * 0.5;
					TweenMax.to(_highScoreLabel, 0.75, { delay:1.5, alpha:1 } );
				}
				else
				{
					_highScoreGlow.x = this.actualWidth * 0.5;
					_highScoreGlow.y = this.actualHeight * (_facebookButton ? 0.3 : 0.4) + _highScoreLogo.height * 0.1;
					TweenMax.to(_highScoreGlow, 0.75, { delay:0.75, alpha:1 } );
					TweenMax.to(_highScoreGlow, 10, { delay:0.75, rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 } );
					
					_highScoreLogo.x = this.actualWidth * 0.5;
					_highScoreLogo.y = this.actualHeight * (_facebookButton ? 0.3 : 0.4);
					
					_continueButton.validate();
					_continueButton.x = (actualWidth - _continueButton.width) * 0.5;
					_continueButton.y = actualHeight - _continueButton.height - scaleAndRoundToDpi(20);
					
					_facebookButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_facebookButton.validate();
					_facebookButton.y = _continueButton.y - _facebookButton.height - scaleAndRoundToDpi(10);
					_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
					
					TweenMax.to(_facebookButton, 0.75, { delay:2, alpha:1 });
					TweenMax.to(_continueButton, 0.75, { delay:2.5, alpha:1 });
					
					_highScoreLabel.width = this.actualWidth;
					_highScoreLabel.validate();
					_highScoreLabel.y = (_highScoreLogo.y + _highScoreLogo.height * 0.5) + ( ((_facebookButton.y - (_highScoreLogo.y + _highScoreLogo.height * 0.5)) - _highScoreLabel.height ) * 0.5 );
					TweenMax.to(_highScoreLabel, 0.75, { delay:1.5, alpha:1 } );
				}
				
				_particles.x = _highScoreLogo.x;
				_particles.y = _highScoreLogo.y;
				_particles.emitterXVariance = _highScoreLogo.width * 0.5;
				_particles.emitterYVariance = _highScoreLogo.height * 0.5;
				TweenMax.delayedCall(0.5, _particles.start, [0.2]);
				
				// FIXME Vérifier en portrait
				_confettis.emitterX = 0;
				_confettis.x = actualWidth * 0.5;
				_confettis.emitterXVariance = actualWidth * 2; // pourquoi * 2 ?
				_confettis.emitterY = scaleAndRoundToDpi(-100);
				_confettis.emitterYVariance = scaleAndRoundToDpi(25);
				TweenMax.delayedCall(0.5, _confettis.start, [_facebookButton ? Number.MAX_VALUE : 5]);
				
				_highScoreLogo.scaleX = _highScoreLogo.scaleY = 0;
				TweenMax.to(_highScoreLogo, 0.75, { delay:0.5, scaleX:GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? (0.1 * GlobalConfig.dpiScale) : 0), scaleY:GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? (0.1 * GlobalConfig.dpiScale) : 0), ease:Back.easeOut } );
				
				SoundManager.getInstance().playSound("new-highscore", "sfx");
			}
			
			super.draw();
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
			if( ScreenData.getInstance().gameData.facebookFriends )
			{
				// animation des amis
				advancedOwner.replaceScreen( ScreenIds.FACEBOOK_END_SCREEN );
			}
			else
			{
				advancedOwner.replaceScreen( ScreenData.getInstance().gameData.hasReachNewTop ? ScreenIds.PODIUM_SCREEN : (ScreenData.getInstance().gameMode == GameMode.SOLO ? ScreenIds.SOLO_END_SCREEN:ScreenIds.TOURNAMENT_END_SCREEN) );
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Facebook
		
		/**
		 * Publication posted.
		 */		
		private function onPublished(event:starling.events.Event):void
		{
			_facebookButton.removeEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
			Starling.juggler.delayCall(onContinue, 1);
			touchable = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Next screen
		
		/**
		 * Continue.
		 */		
		private function onContinue(event:starling.events.Event = null):void
		{
			TweenMax.allTo([_facebookButton, _continueButton], 0.5, { alpha:0 } );
			
			TweenMax.to(_confettis, 0.25, { alpha:0 } );
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
			
			TweenMax.killDelayedCallsTo(_particles.start);
			Starling.juggler.remove( _particles );
			_particles.stop(true);
			_particles.removeFromParent(true);
			_particles = null;
			
			TweenMax.killDelayedCallsTo(_confettis.start);
			Starling.juggler.remove( _confettis );
			_confettis.stop(true);
			_confettis.removeFromParent(true);
			_confettis = null;
			
			TweenMax.killTweensOf(_continueButton);
			_continueButton.removeEventListener(starling.events.Event.TRIGGERED, onContinue);
			_continueButton.removeFromParent(true);
			_continueButton = null;
			
			TweenMax.killTweensOf(_facebookButton);
			_facebookButton.removeEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			super.dispose();
		}
		
	}
}