/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 2 déc. 2013
 */
package com.ludofactory.mobile.navigation.engine
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.model.GameData;
	import com.ludofactory.mobile.core.model.ScreenData;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobileNew.core.analytics.Analytics;
	
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.StringUtil;
	
	/**
	 * The pop up used to display a popup content.
	 */
	public class DuelEndScreen extends AdvancedScreen
	{
		
	// ---------- Layout and animation properties
		
		/**
		 * Padding top used to layout the container's content. */
		private var PADDING_TOP:Number;
		/**
		 * Padding bottom used to layout the container's content. */
		private var PADDING_BOTTOM:Number;
		/**
		 * Container saved final height used to tween it. */
		private var _containerSavedHeight:Number;
		
		/**
		 * Values used to tween the score. */
		public var _oldTweenValue:int;
		public var _targetTweenValue:int;
		
	// ---------- Common
		
		/**
		 * Black overlay. */
		private var _overlay:Quad;
		/**
		 * The flag. */
		private var _flag:Image;
		/**
		 * Title above the flag. */
		private var _title:TextField;
		/**
		 * The main container. */
		private var _container:EndScreenContainer;
		
	// ---------- Content
		
		/**
		 * Points container. */
		private var _scoreContainer:Image;
		/**
		 * Earned points label. */
		private var _scoreLabel:TextField;
		/**
		 * Points particles. */
		private var _pointsParticles:PDParticleSystem;
		
	// ---------- Buttons
		
		/**
		 * Home button. */
		private var _homeButton:Button;
		/**
		 * Replay button. */
		private var _replayButton:Button;
		/**
		 * Facebook button. */
		private var _facebookButton:FacebookButton;
		
		public function DuelEndScreen()
		{
			super();
			
			_canBack = false;
			
			PADDING_TOP = scaleAndRoundToDpi(110);
			PADDING_BOTTOM = scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 70);

			SoundManager.getInstance().stopPlaylist("music", 3);
		}

		override protected function initialize():void
		{
			super.initialize();
			
			// reset the navigation
			NavigationManager.resetNavigation(false);
			// just in case
			InfoManager.forceClose();
			
			_overlay = new Quad(5, 5, 0x000000);
			_overlay.alpha = 0.75;
			addChild(_overlay);

			_container = new EndScreenContainer();
			_container.alpha = 0;
			addChild(_container);
			
			_flag = new Image(AbstractEntryPoint.assets.getTexture("end-game-flag"));
			_flag.scale = GlobalConfig.dpiScale;
			_flag.scale9Grid = new Rectangle(10, 0, 10, _flag.texture.frameHeight);
			addChild(_flag);
			_flag.alignPivot();
			
			_title = new TextField(_flag.width - (scaleAndRoundToDpi(132*2)), _flag.height, _("FIN DE PARTIE"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), 0xffffff));
			_title.alignPivot();
			_title.alpha = 0;
			_title.autoScale = true;
			addChild(_title);
			
			_scoreContainer = new Image(AbstractEntryPoint.assets.getTexture("result-container"));
			_scoreContainer.scale9Grid = new Rectangle(30, 0, 6, _scoreContainer.texture.frameHeight);
			_scoreContainer.alpha = 0;
			_scoreContainer.scale = GlobalConfig.dpiScale;
			addChild(_scoreContainer);
			
			_scoreLabel = new TextField(5, _scoreContainer.height, StringUtil.format(_("Score final : {0}"), Utilities.splitThousands(ScreenData.getInstance().gameData.finalScore)), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(50), 0xffffff));
			_scoreLabel.autoScale = true;
			_scoreLabel.alpha = 0;
			_scoreLabel.border = true;
			addChild(_scoreLabel);
			
			_pointsParticles = new PDParticleSystem(Theme.particleVortexXml, AbstractEntryPoint.assets.getTexture("particle-sparkle-end"));
			_pointsParticles.touchable = false;
			_pointsParticles.capacity = 250;
			addChild(_pointsParticles);
			Starling.juggler.add(_pointsParticles);
			
			_replayButton = new Button(AbstractEntryPoint.assets.getTexture("replay-button"));
			_replayButton.alpha = 0;
			_replayButton.scaleX = _replayButton.scaleY = GlobalConfig.dpiScale;
			addChild(_replayButton);
			
			_homeButton = new Button(AbstractEntryPoint.assets.getTexture("home-button"));
			_homeButton.alpha = 0;
			_homeButton.scaleX = _homeButton.scaleY = GlobalConfig.dpiScale;
			addChild(_homeButton);
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Partager"), ButtonFactory.FACEBOOK_TYPE_SHARE, StringUtil.format(_("J'ai obtenu {0} trophées sur {1} !"), Utilities.splitThousands(ScreenData.getInstance().gameData.duelReward), AbstractGameInfo.GAME_NAME),
					"",
					_("Je peux maintenant obtenir des tas de bonus en les convertissant dans la Boutique !"),
					_("http://www.ludokado.com/"),
					StringUtil.format(_("http://img.ludokado.com/img/frontoffice/{0}/mobile/publication/pyramid.jpg"), LanguageManager.getInstance().lang));
			_facebookButton.alpha = 0;
			addChild(_facebookButton);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_overlay.width = actualWidth;
				_overlay.height = actualHeight;
				
				_container.width = _flag.width + scaleAndRoundToDpi(40);
				_container.x = (actualWidth - _container.width) * 0.5;
				
				_flag.scaleX = 0;
				_title.x = _flag.x = actualWidth * 0.5;
				_title.y = actualHeight * 0.49;
				_flag.y = actualHeight * 0.5 + _flag.height * 0.15;
				
				_scoreContainer.width = _scoreLabel.width = _container.width * 0.7;
				_scoreContainer.x = roundUp((actualWidth - _scoreContainer.width) * 0.5);
				_scoreLabel.x = _scoreContainer.x;
				
				_container.height = PADDING_TOP + PADDING_BOTTOM + scaleAndRoundToDpi(10) + _scoreContainer.height + scaleAndRoundToDpi(10);
				
				_containerSavedHeight = _container.height;
				_container.y = roundUp((actualHeight - _container.height) * 0.5);
				_container.height = 0;
				
				// start to animate
				TweenMax.to(_title, 0.5, { delay:0.75, autoAlpha:1 });
				TweenMax.to(_flag, 0.5, { delay:0.75, scaleX:GlobalConfig.dpiScale, onComplete:animateFlag });
			}

			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Animation
		
		/**
		 * Animates the flag, title and container.
		 */
		private function animateFlag():void
		{
			TweenMax.to(_flag, 0.5, { y:(_container.y + _flag.height * 0.15) } );
			TweenMax.to(_title, 0.5, { y:(_container.y) } );
			TweenMax.to(_container, 0.5, { delay:0.5, height:_containerSavedHeight, alpha:1, onComplete:displayContent });
		}
		
		/**
		 * Adds the content and animate it
		 */
		private function displayContent():void
		{
			// buttons
			_homeButton.x = _container.x + _container.width - _homeButton.width * 0.75;
			_homeButton.y = _container.y - _homeButton.height * 0.25;
			
			_replayButton.x = roundUp((actualWidth - _replayButton.width - _facebookButton.width) * 0.5);
			_facebookButton.x = roundUp(_replayButton.x + _replayButton.width);
			_replayButton.y = _container.y + _containerSavedHeight - (_replayButton.height * 0.5);
			_facebookButton.y = _container.y + _containerSavedHeight - (_facebookButton.height * 0.5);
			TweenMax.allTo([_replayButton, _facebookButton], 0.5, { alpha:1 });
			
			// common elements (score and earned points
			_scoreContainer.y = _flag.y + scaleAndRoundToDpi(55) + scaleAndRoundToDpi(5);
			_scoreLabel.y = _scoreContainer.y;
			TweenMax.allTo([_scoreContainer, _scoreLabel], 0.5, { alpha:1 });
			
			_replayButton.addEventListener(Event.TRIGGERED, onPlayAgain);
			_homeButton.addEventListener(Event.TRIGGERED, onGoHome);
			
			// everything is in place, we animate the score now
			_scoreLabel.text = StringUtil.format(_("Score final : {0}"), 0);
			_oldTweenValue = 0;
			_targetTweenValue = ScreenData.getInstance().gameData.finalScore;
			if(_targetTweenValue == 0)
			{
				Starling.juggler.delayCall(animateLabelFromScoreToPoints, 1);
			}
			else
			{
				TweenMax.to(this, _targetTweenValue < 500 ? 1 : 2, { delay:0.5, _oldTweenValue : _targetTweenValue, onUpdate : function():void
				{
					_scoreLabel.text = StringUtil.format(_("Score final : {0}"), Utilities.splitThousands(_oldTweenValue));
				}, onComplete:animateLabelFromScoreToPoints, ease:Expo.easeInOut } );
			}
		}
		
		/**
		 * The score have been animated, now we show the rewards
		 */
		private function animateLabelFromScoreToPoints():void
		{
			if(!_scoreLabel) // if the screen changed after the starling juggler delayed call
				return;
			
			_scoreLabel.text = StringUtil.format(_("Score final : {0}"), Utilities.splitThousands(ScreenData.getInstance().gameData.finalScore));
			
			_pointsParticles.start(0.25);
			_pointsParticles.emitterX = _scoreLabel.x + _scoreLabel.width * 0.5;
			_pointsParticles.emitterY = _scoreLabel.y + _scoreLabel.height * 0.5;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Navigation handlers
		
		/**
		 * Go to home screen.
		 */
		private function onGoHome(event:Event):void
		{
			// track the event
			Analytics.trackEvent("Fin mode solo", "Choix accueil");
			
			// reset the game data
			ScreenData.getInstance().gameData = new GameData();
			//disable all button
			_homeButton.enabled = false;
			_replayButton.enabled = false;
			_facebookButton.enabled = false;
			// then redirect
			advancedOwner.replaceScreen(ScreenIds.HOME_SCREEN);
		}
		
		/**
		 * Play again.
		 */
		private function onPlayAgain(event:Event):void
		{
			// track the event
			Analytics.trackEvent("Fin mode solo", "Choix rejouer");
			// reset the game data
			ScreenData.getInstance().gameData = new GameData();
			// disable all buttons
			_homeButton.enabled = false;
			_replayButton.enabled = false;
			_facebookButton.enabled = false;
			// then redirect
			advancedOwner.replaceScreen(ScreenIds.GAME_SCREEN);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose

		override public function dispose():void
		{
			TweenMax.killTweensOf(this);
			
			_overlay.removeFromParent(true);
			_overlay = null;
			
			TweenMax.killTweensOf(_flag);
			_flag.removeFromParent(true);
			_flag = null;
			
			TweenMax.killTweensOf(_title);
			_title.removeFromParent(true);
			_title = null;
			
			TweenMax.killTweensOf(_container);
			_container.removeFromParent(true);
			_container = null;
			
			TweenMax.killTweensOf(_scoreContainer);
			_scoreContainer.removeFromParent(true);
			_scoreContainer = null;
			
			TweenMax.killTweensOf(_scoreLabel);
			_scoreLabel.removeFromParent(true);
			_scoreLabel = null;
			
			Starling.juggler.remove(_pointsParticles);
			_pointsParticles.stop(true);
			_pointsParticles.removeFromParent(true);
			_pointsParticles = null;
			
			TweenMax.killTweensOf(_replayButton);
			_replayButton.removeEventListener(Event.TRIGGERED, onGoHome);
			_replayButton.removeEventListener(Event.TRIGGERED, onPlayAgain);
			_replayButton.removeFromParent(true);
			_replayButton = null;
			
			TweenMax.killTweensOf(_homeButton);
			_homeButton.removeEventListener(Event.TRIGGERED, onGoHome);
			_homeButton.removeFromParent(true);
			_homeButton = null;
			
			TweenMax.killTweensOf(_facebookButton);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;

			super.dispose();
		}

	}
}