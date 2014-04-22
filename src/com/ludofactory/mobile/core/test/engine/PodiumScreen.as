/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 13 Aoü 2013
*/
package com.ludofactory.mobile.core.test.engine
{
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.utils.Utilities;
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
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.events.Event;
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
	
	public class PodiumScreen extends AdvancedScreen
	{
		/**
		 * Podium logo */		
		private var _podiumLogo:Image;
		/**
		 * Podium glow */		
		private var _podiumGlow:Image;
		/**
		 * Podium label */		
		private var _podiumMessage:Label;
		/**
		 * The array of animations to make (object { label, particles } */		
		private var _animArray:Array;
		/**
		 *  */		
		private var _numLetters:int;
		
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
		
		/**
		 * Confettis. */		
		private var _confettis:PDParticleSystem;
		
		private var _facebookManager:FacebookManager;
		
		public function PodiumScreen()
		{
			super();
			
			_fullScreen = true;
			_appDarkBackground = true;
			_canBack = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// FIXME A décommenter pour gérer l'orientation
			/*if( GlobalConfig.stageWidth > GlobalConfig.stageHeight )
			{
				Starling.current.nativeStage.addEventListener(flash.events.Event.RESIZE, onResize, false, int.MAX_VALUE, true);
				Starling.current.nativeStage.setAspectRatio(StageAspectRatio.PORTRAIT);
			}
			else
			{
				onResize();
			}*/
			
			initContent();
		}
		
		/**
		 * The application has finished resizing, we can start loading all the assets for
		 * the game. Depending on which type of device we are, we will load a specific
		 * size of the game assets so that it's big enough on any device.
		 */		
		private function onResize(event:flash.events.Event = null):void
		{
			if( event )
			{
				Starling.current.nativeStage.removeEventListener(flash.events.Event.RESIZE, onResize, false);
				InfoManager.show( Localizer.getInstance().translate("COMMON.LOADING") );
				TweenMax.delayedCall(GlobalConfig.android ? 6:1, initContent);
			}
			else
			{
				initContent();
			}
		}
		
		private function initContent():void
		{
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			
			_podiumGlow = new Image( AbstractEntryPoint.assets.getTexture("HighScoreGlow") );
			_podiumGlow.alpha = 0;
			_podiumGlow.scaleX = _podiumGlow.scaleY = GlobalConfig.stageWidth / (_podiumGlow.width * (AbstractGameInfo.LANDSCAPE ? 1.5 : 1));
			_podiumGlow.alignPivot();
			addChild( _podiumGlow );
			
			_podiumLogo = new Image( AbstractEntryPoint.assets.getTexture("Top") );
			_podiumLogo.scaleX = _podiumLogo.scaleY = GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? (0.2 * GlobalConfig.dpiScale) : 0);
			_podiumLogo.alignPivot();
			addChild( _podiumLogo );
			
			_podiumMessage = new Label();
			_podiumMessage.alpha = 0;
			_podiumMessage.text = formatString(Localizer.getInstance().translate("PODIUM.MESSAGE" + (AbstractGameInfo.LANDSCAPE ? "_LANDSCAPE" : "_PORTRAIT")), formatString(Localizer.getInstance().translate(Utilities.translatePosition(advancedOwner.screenData.gameData.position)), this.advancedOwner.screenData.gameData.position));
			addChild(_podiumMessage);
			var test:int = ((GlobalConfig.isPhone ? 50 : 76) * _podiumLogo.scaleX) << 0;
			_podiumMessage.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, test, Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_podiumMessage.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			_animArray = new Array();
			_numLetters = String(this.advancedOwner.screenData.gameData.top).length;
			var particleSystem:PDParticleSystem;
			var scoreLabel:Label;
			
			for(var i:int = 0; i < _numLetters; i++)
			{
				scoreLabel = createLabel( String(this.advancedOwner.screenData.gameData.top).charAt(i) );
				addChild(scoreLabel);
				scoreLabel.textRendererProperties.textFormat = Theme.labelPodiumTopTextFormat;
				scoreLabel.validate();
				scoreLabel.alignPivot();
				
				particleSystem = new PDParticleSystem(Theme.particleSparklesXml, Theme.particleSparklesTexture);
				particleSystem.touchable = false;
				particleSystem.maxNumParticles = 500;
				particleSystem.emitterXVariance = scoreLabel.width * 0.25;
				particleSystem.emitterYVariance = scoreLabel.height * 0.25;
				particleSystem.scaleX = particleSystem.scaleY = GlobalConfig.dpiScale;
				addChild(particleSystem);
				Starling.juggler.add(particleSystem);
				
				_animArray.push( { label:scoreLabel, particles:particleSystem } );
			}
			
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
			
			_confettis = new PDParticleSystem(Theme.particleConfettiXml, Theme.particleConfettiTexture);
			_confettis.touchable = false;
			_confettis.maxNumParticles = AbstractGameInfo.LANDSCAPE ? 750 : 500;
			_confettis.lifespan *= AbstractGameInfo.LANDSCAPE ? 1 : 2;
			_confettis.scaleX = _confettis.scaleY = GlobalConfig.dpiScale;
			addChild(_confettis);
			Starling.juggler.add(_confettis);
			
			//invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) && _podiumLogo )
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					_podiumLogo.x = this.actualWidth * 0.5;
					_podiumLogo.y = (_podiumLogo.height * 0.5) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 80);
					
					_podiumGlow.x = this.actualWidth * 0.5;
					_podiumGlow.y = _podiumLogo.y + _podiumLogo.height * 0.1;
					TweenMax.to(_podiumGlow, 0.75, { delay:0.75, alpha:1 } );
					TweenMax.to(_podiumGlow, 10, { delay:0.75, rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 } );
					
					if( _facebookButton )
					{
						_continueButton.validate();
						_continueButton.x = (actualWidth - _continueButton.width) * 0.5;
						_continueButton.y = actualHeight - _continueButton.height - scaleAndRoundToDpi(5);
						
						_facebookButton.width = actualWidth * 0.5;
						_facebookButton.validate();
						_facebookButton.y = _continueButton.y - _facebookButton.height;
						_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
						
						TweenMax.to(_facebookButton, 0.75, { delay:3, alpha:1 });
						TweenMax.to(_continueButton, 0.75, { delay:3.5, alpha:1 });
					}
					
					_podiumMessage.width = this.actualWidth;
					_podiumMessage.validate();
					if( _facebookButton )
						_podiumMessage.y = (_podiumLogo.y + _podiumLogo.height * 0.5) + ( ((_facebookButton.y - (_podiumLogo.y + _podiumLogo.height * 0.5)) - _podiumMessage.height ) * 0.5 )
					else
						_podiumMessage.y = (( (this.actualHeight - (_podiumLogo.y + _podiumLogo.height * 0.5)) - _podiumMessage.height ) * 0.5) + _podiumLogo.y + _podiumLogo.height * 0.5;
					TweenMax.to(_podiumMessage, 0.75, { delay:2.5, alpha:1 } );
				}
				else
				{
					_podiumGlow.x = this.actualWidth * 0.5;
					_podiumGlow.y = this.actualHeight * (_facebookButton ? 0.3 : 0.4) + _podiumLogo.height * 0.1;
					TweenMax.to(_podiumGlow, 0.75, { delay:0.75, alpha:1 } );
					TweenMax.to(_podiumGlow, 10, { delay:0.75, rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 } );
					
					_podiumLogo.x = this.actualWidth * 0.5;
					_podiumLogo.y = this.actualHeight * (_facebookButton ? 0.3 : 0.4);
					
					if( _facebookButton )
					{
						_continueButton.validate();
						_continueButton.x = (actualWidth - _continueButton.width) * 0.5;
						_continueButton.y = actualHeight - _continueButton.height - scaleAndRoundToDpi(20);
						
						_facebookButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
						_facebookButton.validate();
						_facebookButton.y = _continueButton.y - _facebookButton.height - scaleAndRoundToDpi(10);
						_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
						
						TweenMax.to(_facebookButton, 0.75, { delay:3, alpha:1 });
						TweenMax.to(_continueButton, 0.75, { delay:3.5, alpha:1 });
					}
					
					_podiumMessage.width = this.actualWidth;
					_podiumMessage.validate();
					if( _facebookButton )
						_podiumMessage.y = (_podiumLogo.y + _podiumLogo.height * 0.5) + ( ((_facebookButton.y - (_podiumLogo.y + _podiumLogo.height * 0.5)) - _podiumMessage.height ) * 0.5 )
					else
						_podiumMessage.y = (( (this.actualHeight - (_podiumLogo.y + _podiumLogo.height * 0.5)) - _podiumMessage.height ) * 0.5) + _podiumLogo.y + _podiumLogo.height * 0.5;
					TweenMax.to(_podiumMessage, 0.75, { delay:2.5, alpha:1 } );
				}
				
				_confettis.emitterX =_confettis.emitterXVariance = actualWidth * 0.6;
				_confettis.emitterY = scaleAndRoundToDpi(-100);
				_confettis.emitterYVariance = scaleAndRoundToDpi(25);
				TweenMax.delayedCall(0.5, _confettis.start, [_facebookButton ? Number.MAX_VALUE : 5]);
				
				_podiumLogo.scaleX = _podiumLogo.scaleY = 0;
				TweenMax.to(_podiumLogo, 0.75, { delay:0.5, scaleX:GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? (0.2 * GlobalConfig.dpiScale) : 0), scaleY:GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? (0.2 * GlobalConfig.dpiScale) : 0), ease:Back.easeOut, onComplete:displayPodiumLabel } );
				
				if( !_facebookButton )
					Starling.juggler.delayCall(onContinue, 5);
			}
		}
		
		private function displayPodiumLabel():void
		{
			const startX:int = (_podiumLogo.x - _podiumLogo.width * 0.5 + (60 * _podiumLogo.scaleX)) << 0;
			const startY:int = (_podiumLogo.y + (80 * _podiumLogo.scaleX)) << 0;
			const itemWidth:int = (_podiumLogo.width - (60 * _podiumLogo.scaleX)) << 0;
			const step:int = itemWidth / (_numLetters + 1);
			
			var particles:PDParticleSystem;
			var label:Label;
			var delay:Number = 0;
			var decY:int = 0;
			
			for( var i:int = 0; i < _numLetters; i++)
			{
				particles = _animArray[i].particles;
				label = _animArray[i].label;
				
				label.x = particles.x = startX + (step * (i + 1));
				label.y = particles.y = startY - decY;
				
				if( _numLetters == 2)
					label.x += i == 0 ? (label.width * 0.1) : -(label.width * 0.1);
				
				TweenMax.delayedCall(delay + 0.17, particles.start, [0.17]);
				TweenMax.to(label, 0.5, { delay:delay, alpha:1, scaleX:1, scaleY:1, ease:Bounce.easeOut });
				
				delay += 0.3;
				decY += (6 * _podiumLogo.scaleX) << 0;
			}
		}
		
		private function createLabel(text:String):Label
		{
			var label:Label = new Label();
			label.alpha = 0;
			label.text = text;
			label.rotation = deg2rad(-3);
			label.scaleX = label.scaleY = 2;
			return label;
		}
		
		/**
		 * If we are here, there is just one possibility : go the the result screen
		 * (which, in this case, can only be the tournament result screen).
		 */		
		private function goToNextScreen():void
		{
			TweenMax.killAll();
			advancedOwner.showScreen( ScreenIds.TOURNAMENT_GAME_END_SCREEN );
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
			
			GoViral.goViral.showFacebookFeedDialog( formatString(Localizer.getInstance().translate("FACEBOOK_PODIUM_PUBLICATION.NAME"), advancedOwner.screenData.gameData.top),
				"", "",
				formatString(Localizer.getInstance().translate("FACEBOOK_PODIUM_PUBLICATION.DESCRIPTION"), advancedOwner.screenData.gameData.topDotationName),
				Localizer.getInstance().translate("FACEBOOK_PODIUM_PUBLICATION.LINK"),
				formatString(Localizer.getInstance().translate("FACEBOOK_PODIUM_PUBLICATION.IMAGE"), Localizer.getInstance().lang, advancedOwner.screenData.gameData.top));
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
			
			for each(var element:Object in _animArray)
			TweenMax.to(element.label, 0.3, { alpha:0, scaleX:0, scaleY:0, ease:Back.easeIn } );
			
			TweenMax.to(_confettis, 0.25, { alpha:0 } );
			TweenMax.allTo([_podiumGlow, _podiumMessage], 0.5, { alpha:0 } );
			TweenMax.to(_podiumGlow, 1, { rotation:deg2rad(360) } );
			TweenMax.to(_podiumLogo, 0.5, { alpha:0, scaleX:0, scaleY:0, ease:Back.easeIn, onComplete:goToNextScreen } );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			TweenMax.killTweensOf(_podiumGlow);
			TweenMax.killTweensOf(_podiumLogo);
			TweenMax.killTweensOf(_podiumMessage);
			
			_podiumGlow.removeFromParent(true);
			_podiumGlow = null;
			
			_podiumLogo.removeFromParent(true);
			_podiumLogo = null;
			
			_podiumMessage.removeFromParent(true);
			_podiumMessage = null;
			
			Starling.juggler.remove( _confettis );
			_confettis.stop(true);
			_confettis.removeFromParent(true);
			_confettis = null;
			
			var label:Label;
			var particles:PDParticleSystem;
			for each(var element:Object in _animArray)
			{
				label = element.label;
				delete element["label"];
				TweenMax.killTweensOf(label);
				label.removeFromParent(true);
				label = null;
				
				particles = element.particles;
				delete element["particles"];
				Starling.juggler.remove(particles);
				particles.stop(true);
				particles.removeFromParent(true);
				particles = null;
			}
			_animArray.length = 0;
			_animArray = null;
			
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