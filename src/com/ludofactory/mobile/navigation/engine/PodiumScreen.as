/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 13 Aoü 2013
*/
package com.ludofactory.mobile.navigation.engine
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
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
	import com.ludofactory.mobile.core.model.ScreenData;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManagerEventType;
	
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
		 * Facebook button that will associate the
		 * account or directly publish, depending on
		 * the actual state. */		
		private var _facebookButton:FacebookButton;
		/**
		 * The continue button. */		
		private var _continueButton:Button;
		
		/**
		 * Confettis. */		
		private var _confettis:PDParticleSystem;
		
		public function PodiumScreen()
		{
			super();
			
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
				InfoManager.show( _("Chargement...") );
				TweenMax.delayedCall(GlobalConfig.android ? 6:1, initContent);
			}
			else
			{
				initContent();
			}
		}
		
		private function initContent():void
		{
			InfoManager.forceClose();
			
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
			_podiumMessage.text = StringUtil.format( AbstractGameInfo.LANDSCAPE ? _("Bravo !\nVous êtes {0} du tournoi !") : _("Bravo !\n\nVous êtes\n{0} du tournoi !"), StringUtil.format(Utilities.translatePosition(ScreenData.getInstance().gameData.position), ScreenData.getInstance().gameData.position));
			addChild(_podiumMessage);
			var test:int = ((GlobalConfig.isPhone ? 50 : 76) * _podiumLogo.scaleX) << 0;
			_podiumMessage.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, test, Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_podiumMessage.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			_animArray = [];
			_numLetters = String(ScreenData.getInstance().gameData.top).length;
			var particleSystem:PDParticleSystem;
			var scoreLabel:Label;
			
			for(var i:int = 0; i < _numLetters; i++)
			{
				scoreLabel = createLabel( String(ScreenData.getInstance().gameData.top).charAt(i) );
				addChild(scoreLabel);
				scoreLabel.textRendererProperties.textFormat = Theme.labelPodiumTopTextFormat;
				scoreLabel.validate();
				scoreLabel.alignPivot();
				
				particleSystem = new PDParticleSystem(Theme.particleSparklesXml, Theme.particleSparklesTexture);
				particleSystem.touchable = false;
				particleSystem.capacity = 500;
				particleSystem.emitterXVariance = scoreLabel.width * 0.25;
				particleSystem.emitterYVariance = scoreLabel.height * 0.25;
				particleSystem.scaleX = particleSystem.scaleY = GlobalConfig.dpiScale;
				addChild(particleSystem);
				Starling.juggler.add(particleSystem);
				
				_animArray.push( { label:scoreLabel, particles:particleSystem } );
			}
			
			_continueButton = new Button();
			_continueButton.alpha = 0;
			_continueButton.addEventListener(starling.events.Event.TRIGGERED, onContinue);
			_continueButton.styleName = Theme.BUTTON_EMPTY;
			_continueButton.label = _("Continuer");
			addChild(_continueButton);
			_continueButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(30), Theme.COLOR_WHITE, true, true, null, null, null, TextFormatAlign.CENTER);
			_continueButton.height = _continueButton.minHeight = scaleAndRoundToDpi(60);
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Partager"), ButtonFactory.FACEBOOK_TYPE_SHARE, StringUtil.format(_("Je suis dans le TOP {0} sur le tournoi {1}"), ScreenData.getInstance().gameData.top, AbstractGameInfo.GAME_NAME),
					"",
					StringUtil.format(_("La fin du tournoi approche ! Rejoignez moi vite et remportez vous aussi cette récompense : {0}"), "test"),
					_("http://www.ludokado.com/"),
					StringUtil.format(_("http://img.ludokado.com/img/frontoffice/{0}/mobile/publication/publication_top_{1}.jpg"), LanguageManager.getInstance().lang, ScreenData.getInstance().gameData.top));
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
					
					_continueButton.validate();
					_continueButton.x = (actualWidth - _continueButton.width) * 0.5;
					_continueButton.y = actualHeight - _continueButton.height - scaleAndRoundToDpi(5);
					
					_facebookButton.width = actualWidth * 0.5;
					_facebookButton.validate();
					_facebookButton.y = _continueButton.y - _facebookButton.height;
					_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
					
					TweenMax.to(_facebookButton, 0.75, { delay:3, alpha:1 });
					TweenMax.to(_continueButton, 0.75, { delay:3.5, alpha:1 });
					
					_podiumMessage.width = this.actualWidth;
					_podiumMessage.validate();
					_podiumMessage.y = (_podiumLogo.y + _podiumLogo.height * 0.5) + ( ((_facebookButton.y - (_podiumLogo.y + _podiumLogo.height * 0.5)) - _podiumMessage.height ) * 0.5 );
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
					
					_continueButton.validate();
					_continueButton.x = (actualWidth - _continueButton.width) * 0.5;
					_continueButton.y = actualHeight - _continueButton.height - scaleAndRoundToDpi(20);
					
					_facebookButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_facebookButton.validate();
					_facebookButton.y = _continueButton.y - _facebookButton.height - scaleAndRoundToDpi(10);
					_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
					
					TweenMax.to(_facebookButton, 0.75, { delay:3, alpha:1 });
					TweenMax.to(_continueButton, 0.75, { delay:3.5, alpha:1 });
					
					_podiumMessage.width = this.actualWidth;
					_podiumMessage.validate();
					_podiumMessage.y = (_podiumLogo.y + _podiumLogo.height * 0.5) + ( ((_facebookButton.y - (_podiumLogo.y + _podiumLogo.height * 0.5)) - _podiumMessage.height ) * 0.5 );
					TweenMax.to(_podiumMessage, 0.75, { delay:2.5, alpha:1 } );
				}
				
				// FIXME Vérifier en portrait
				_confettis.emitterX = 0;
				_confettis.x = actualWidth * 0.5;
				_confettis.emitterXVariance = actualWidth * 2; // pourquoi * 2 ?
				_confettis.emitterY = scaleAndRoundToDpi(-100);
				_confettis.emitterYVariance = scaleAndRoundToDpi(25);
				TweenMax.delayedCall(0.5, _confettis.start, [_facebookButton ? Number.MAX_VALUE : 5]);
				
				_podiumLogo.scaleX = _podiumLogo.scaleY = 0;
				TweenMax.to(_podiumLogo, 0.75, { delay:0.5, scaleX:GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? (0.2 * GlobalConfig.dpiScale) : 0), scaleY:GlobalConfig.dpiScale - (AbstractGameInfo.LANDSCAPE ? (0.2 * GlobalConfig.dpiScale) : 0), ease:Back.easeOut, onComplete:displayPodiumLabel } );
			}
			
			super.draw();
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
			advancedOwner.replaceScreen( ScreenIds.DUEL_END_SCREEN );
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
		private function onContinue(event:starling.events.Event):void
		{
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
			_podiumGlow.removeFromParent(true);
			_podiumGlow = null;
			
			TweenMax.killTweensOf(_podiumLogo);
			_podiumLogo.removeFromParent(true);
			_podiumLogo = null;
			
			TweenMax.killTweensOf(_podiumMessage);
			_podiumMessage.removeFromParent(true);
			_podiumMessage = null;
			
			TweenMax.killDelayedCallsTo(_confettis.start);
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
				TweenMax.killDelayedCallsTo(particles.start);
				Starling.juggler.remove(particles);
				particles.stop(true);
				particles.removeFromParent(true);
				particles = null;
			}
			_animArray.length = 0;
			_animArray = null;
			
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