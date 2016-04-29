/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 2 déc. 2013
 */
package com.ludofactory.mobile.navigation.engine
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.Shaker;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
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
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.model.GameData;
	import com.ludofactory.mobile.core.model.ScreenData;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.newClasses.Analytics;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.StringUtil;
	import starling.utils.deg2rad;
	
	/**
	 * The pop up used to display a popup content.
	 */
	public class SoloEndScreen extends AdvancedScreen
	{
		
	// ---------- Layout and animation properties
		
		/**
		 * Padding top used to layout the container's content. */
		private var PADDING_TOP:Number;
		/**
		 * Padding bottom used to layout the container's content. */
		private var PADDING_BOTTOM:Number;
		
		/**
		 * Saved scale for the flag. */
		private var _savedScale:Number;
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
		 * Score label. */
		private var _scoreLabel:TextField;
		/**
		 * Points container. */
		private var _pointContainer:Image;
		/**
		 * Earned points label. */
		private var _earnedPointsLabel:TextField;
		/**
		 * Stamp displayed when the user played with credits. */
		private var _winMorePointsImage:Image;
		/**
		 * Points particles. */
		private var _pointsParticles:PDParticleSystem;
		
		/**
		 * The convert elements when logged in. */
		private var _convertShop:SoloEndElement;
		private var _convertTournament:SoloEndElement;
		/**
		 * This one when not loggd in.*/
		private var _convertShopNotLoggedIn:SoloEndElement;
		
		/**
		 * When the tournament have been unlocked. */
		private var _tournamentUnlockedContainer:ScrollContainer;
		private var _lockImage:Image;
		private var _lockLabel:TextField;
		private var _glow:ImageLoader;
		private var _lockerParticles:PDParticleSystem;
		
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
		
		public function SoloEndScreen()
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
			
			//advancedOwner.screenData.gameData.score = 0;
			//MemberManager.getInstance().isTournamentAnimPending = true;
			
			NavigationManager.resetNavigation(false);
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			
			if( !MemberManager.getInstance().isTournamentUnlocked )
			{
				MemberManager.getInstance().tournamentUnlockCounter--;
				if(MemberManager.getInstance().tournamentUnlockCounter <= 0)
				{
					MemberManager.getInstance().isTournamentUnlocked = true;
					MemberManager.getInstance().isTournamentAnimPending = true;
				}
			}
			
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
			_savedScale = _flag.scaleX;
			
			_title = new TextField(_flag.width - (scaleAndRoundToDpi(132*2)), _flag.height, _("FIN DE PARTIE"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), 0xffffff));
			_title.alignPivot();
			_title.alpha = 0;
			_title.autoScale = true;
			//_title.nativeFilters = [ new GlowFilter(0x7e0600, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
			//	new DropShadowFilter(2, 75, 0x7e0600, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
			addChild(_title);
			
			_scoreLabel = new TextField((_flag.width * 0.5), scaleAndRoundToDpi(50), StringUtil.format(_("Score final : {0}"), Utilities.splitThousands(ScreenData.getInstance().gameData.score)), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), 0x27220d));
			_scoreLabel.alpha = 0;
			_scoreLabel.autoSize = TextFieldAutoSize.HORIZONTAL;
			addChild(_scoreLabel);
			
			_pointContainer = new Image(AbstractEntryPoint.assets.getTexture("point-container"));
			_pointContainer.alpha = 0;
			_pointContainer.scaleX = _pointContainer.scaleY = GlobalConfig.dpiScale;
			addChild(_pointContainer);
			
			_earnedPointsLabel = new TextField(scaleAndRoundToDpi(129), _pointContainer.height, "+0", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(50), 0xffffff));
			_earnedPointsLabel.autoScale = true;
			_earnedPointsLabel.alpha = 0;
			addChild(_earnedPointsLabel);
			
			_pointsParticles = new PDParticleSystem(Theme.particleVortexXml, AbstractEntryPoint.assets.getTexture("particle-sparkle-end"));
			_pointsParticles.touchable = false;
			_pointsParticles.capacity = 250;
			//_pointsParticles.blendFactorSource = Context3DBlendFactor.DESTINATION_ALPHA;
			//_pointsParticles.blendFactorDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
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
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Partager"), ButtonFactory.FACEBOOK_TYPE_SHARE, StringUtil.format(_("J'ai obtenu {0} Points sur {1} !"), Utilities.splitThousands(ScreenData.getInstance().gameData.rewardInDuel), AbstractGameInfo.GAME_NAME),
					"",
					_("Je peux maintenant obtenir des tas de bonus en les convertissant dans la Boutique !"),
					_("http://www.ludokado.com/"),
					StringUtil.format(_("http://img.ludokado.com/img/frontoffice/{0}/mobile/publication/pyramid.jpg"), LanguageManager.getInstance().lang));
			_facebookButton.alpha = 0;
			addChild(_facebookButton);
			
			if( MemberManager.getInstance().isTournamentAnimPending )
			{
				// the tournement was unlocked, we need to animate it
				
				_tournamentUnlockedContainer = new ScrollContainer();
				_tournamentUnlockedContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_tournamentUnlockedContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_tournamentUnlockedContainer.alpha = 0;
				_tournamentUnlockedContainer.visible = false;
				_tournamentUnlockedContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_GREY;
				addChild(_tournamentUnlockedContainer);
				_tournamentUnlockedContainer.padding = 0;
				
				_lockLabel = new TextField(5, 5, _("Tournoi débloqué !"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 72), Theme.COLOR_WHITE));
				_lockLabel.autoScale = true;
				_tournamentUnlockedContainer.addChild( _lockLabel );
				
				_glow = new ImageLoader();
				_glow.source = AbstractEntryPoint.assets.getTexture("HighScoreGlow");
				_glow.textureScale = GlobalConfig.dpiScale * 0.5;
				_glow.includeInLayout = false;
				_tournamentUnlockedContainer.addChild(_glow);
				
				_lockImage = new Image( AbstractEntryPoint.assets.getTexture("lock-big") );
				_lockImage.scaleX = _lockImage.scaleY = GlobalConfig.dpiScale * 0.75;
				_tournamentUnlockedContainer.addChild(_lockImage);
				
				_lockerParticles = new PDParticleSystem(Theme.particleSparklesXml, Theme.particleSparklesTexture);
				_lockerParticles.touchable = false;
				_lockerParticles.capacity = 250;
				addChild(_lockerParticles);
				Starling.juggler.add(_lockerParticles);
			}
			else
			{
				if( MemberManager.getInstance().isLoggedIn() )
				{
					// logged in content
					
					_convertShop = new SoloEndElement("convert-shop-icon", AbstractGameInfo.LANDSCAPE ? _("Convertir mes Points en Crédits dans la boutique"):_("Convertir mes Points en\nCrédits dans la boutique") );
					_convertShop.alpha = 0;
					_convertShop.visible = false;
					addChild(_convertShop);
					
					_convertTournament = new SoloEndElement("convert-tournament-icon", (AbstractGameInfo.LANDSCAPE ? _("Utiliser mes Points sur le tournoi pour me classer"):_("Utiliser mes Points sur\nle tournoi pour me classer")));
					_convertTournament.alpha = 0;
					_convertTournament.visible = false;
					_convertTournament.addEventListener(TouchEvent.TOUCH, onGoTournament);
					addChild(_convertTournament);
				}
				else
				{
					// not logged in content
					
					var msg:String = _("Créez votre compte et convertissez\nvos Points en Crédits !");
					
					_convertShopNotLoggedIn = new SoloEndElement("points-to-gift-icon", msg);
					_convertShopNotLoggedIn.alpha = 0;
					_convertShopNotLoggedIn.visible = false;
					_convertShopNotLoggedIn.addEventListener(TouchEvent.TOUCH, onConvertInShop);
					addChild(_convertShopNotLoggedIn);
				}
			}
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

				_pointContainer.x = roundUp((actualWidth - _pointContainer.width) * 0.5);
				_earnedPointsLabel.x = _pointContainer.x;
				
				_container.height = PADDING_TOP + PADDING_BOTTOM + _scoreLabel.height + scaleAndRoundToDpi(5) + _pointContainer.height + scaleAndRoundToDpi(10);
				if( MemberManager.getInstance().isTournamentAnimPending )
				{
					_tournamentUnlockedContainer.width = _container.width * 0.8;
					_tournamentUnlockedContainer.x = (actualWidth - _tournamentUnlockedContainer.width) * 0.5;
					_tournamentUnlockedContainer.validate();
					_tournamentUnlockedContainer.height = _tournamentUnlockedContainer.height;
					_tournamentUnlockedContainer.layout = null;
					
					_lockImage.x = (_tournamentUnlockedContainer.width - _lockImage.width) * 0.5;
					_lockImage.y = (_tournamentUnlockedContainer.height - _lockImage.height) * 0.5;
					
					_lockLabel.width = _tournamentUnlockedContainer.width;
					_lockLabel.height = _tournamentUnlockedContainer.height;
					_lockLabel.x = (_tournamentUnlockedContainer.width - _lockLabel.width) * 0.5;
					_lockLabel.y = (_tournamentUnlockedContainer.height - _lockLabel.height) * 0.5;
					
					_glow.width = _tournamentUnlockedContainer.width;
					_glow.height = _tournamentUnlockedContainer.height;
					_glow.alignPivot();
					_glow.x = _tournamentUnlockedContainer.width * 0.5;
					_glow.y = _tournamentUnlockedContainer.height * 0.5;
					
					_lockerParticles.emitterXVariance = _lockImage.width * 0.5;
					_lockerParticles.emitterYVariance = _lockImage.height * 0.5;
					
					_tournamentUnlockedContainer.validate();
					_container.height += _tournamentUnlockedContainer.height;
				}
				else
				{
					if( MemberManager.getInstance().isLoggedIn() )
					{
						_convertShop.width = _convertTournament.width = _container.width * 0.8;
						_convertShop.x = _convertTournament.x = (actualWidth - _convertShop.width) * 0.5;
						_convertShop.validate();
						
						_container.height += _convertShop.height * 2 + scaleAndRoundToDpi(5);
					}
					else
					{
						_convertShopNotLoggedIn.width = _container.width * 0.8;
						_convertShopNotLoggedIn.x = (actualWidth - _convertShopNotLoggedIn.width) * 0.5;
						_convertShopNotLoggedIn.validate();
						
						_container.height += _convertShopNotLoggedIn.height;
					}
				}
				
				_containerSavedHeight = _container.height;
				_container.y = roundUp((actualHeight - _container.height) * 0.5);
				_container.height = 0;
				
				// start to animate
				TweenMax.to(_title, 0.5, { delay:0.75, autoAlpha:1 });
				TweenMax.to(_flag, 0.5, { delay:0.75, scaleX:_savedScale, onComplete:animateFlag });
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
			_scoreLabel.x = roundUp((actualWidth - _scoreLabel.width) * 0.5);
			_scoreLabel.y = _flag.y + scaleAndRoundToDpi(55);
			_pointContainer.y = _scoreLabel.y + _scoreLabel.height + scaleAndRoundToDpi(5);
			_earnedPointsLabel.y = _pointContainer.y;
			TweenMax.allTo([_pointContainer, _earnedPointsLabel, _scoreLabel], 0.5, { alpha:1 });
			
			// specific content
			if( MemberManager.getInstance().isTournamentAnimPending )
			{
				_tournamentUnlockedContainer.y = _pointContainer.y + _pointContainer.height + scaleAndRoundToDpi(10);
				_glow.alpha = 0;
				TweenMax.to(_tournamentUnlockedContainer, 0.5, { autoAlpha:1 });
			}
			else
			{
				if (MemberManager.getInstance().isLoggedIn())
				{
					_convertShop.y = _pointContainer.y + _pointContainer.height + scaleAndRoundToDpi(10);
					_convertTournament.y = _convertShop.y + _convertShop.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 10);
					TweenMax.allTo([_convertShop, _convertTournament], 0.5, { autoAlpha:1 });
				}
				else
				{
					_convertShopNotLoggedIn.y = _pointContainer.y + _pointContainer.height + scaleAndRoundToDpi(10);
					TweenMax.to(_convertShopNotLoggedIn, 0.5, { autoAlpha:1 });
				}
				_replayButton.addEventListener(Event.TRIGGERED, onPlayAgain);
				_homeButton.addEventListener(Event.TRIGGERED, onGoHome);
			}
			
			// everything is in place, we animate the score now
			_scoreLabel.text = StringUtil.format(_("Score final : {0}"), 0);
			_oldTweenValue = 0;
			_targetTweenValue = ScreenData.getInstance().gameData.score;
			if( _targetTweenValue == 0 )
				Starling.juggler.delayCall(animateLabelFromScoreToPoints, 1);
			else
				TweenMax.to(this, _targetTweenValue < 500 ? 1 : 2, { delay:0.5, _oldTweenValue : _targetTweenValue, onUpdate : function():void{ _scoreLabel.text = StringUtil.format(_("Score final : {0}"), Utilities.splitThousands(_oldTweenValue)); }, onComplete:animateLabelFromScoreToPoints, ease:Expo.easeInOut } );
		}
		
		/**
		 * The score have been animated, now we show the rewards
		 */
		private function animateLabelFromScoreToPoints():void
		{
			if(!_earnedPointsLabel) // if the screen changed after the starling juggler delayed call
				return;
			
			_earnedPointsLabel.text = StringUtil.format(_("+{0}"), ScreenData.getInstance().gameData.rewardInDuel);
			
			_pointsParticles.start(0.25);
			_pointsParticles.emitterX = _earnedPointsLabel.x + _earnedPointsLabel.width * 0.5;
			_pointsParticles.emitterY = _earnedPointsLabel.y + _earnedPointsLabel.height * 0.5;
			
			if( true )
			{
				_winMorePointsImage = new Image( AbstractEntryPoint.assets.getTexture("WinMorePointsX6" + LanguageManager.getInstance().lang));
				_winMorePointsImage.scaleX = _winMorePointsImage.scaleY = GlobalConfig.dpiScale;
				_winMorePointsImage.alignPivot();
				_winMorePointsImage.alpha = 0;
				_winMorePointsImage.x = _pointContainer.x + _pointContainer.width + scaleAndRoundToDpi(5) + (_winMorePointsImage.width * 0.5);
				_winMorePointsImage.y = _pointContainer.y + (_pointContainer.height * 0.5);
				addChild( _winMorePointsImage );
				_winMorePointsImage.scaleX = _winMorePointsImage.scaleY = 0;
				TweenMax.to(_winMorePointsImage, 0.5, { delay:0.5, alpha:1, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, ease:Bounce.easeOut, onComplete:multiplyReward } );
			}
			else
			{
				if( MemberManager.getInstance().isTournamentAnimPending )
					unlockTournament();
			}
		}
		
		private function unlockTournament():void
		{
			// the tournament have been unloacked
			const savedScaleX:Number = _glow.scaleX;
			const savedScaleY:Number = _glow.scaleY;
			_glow.scaleX = _glow.scaleY = 0;
			_glow.alpha = 1;
			TweenMax.to(_glow, 0.5, { delay:0.75, autoAlpha:1, scaleX:savedScaleX, scaleY:savedScaleY, ease:Linear.easeNone });
			TweenMax.to(_glow, 8, { rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 });
			TweenMax.delayedCall(2, Shaker.startShaking, [_lockImage, 12]);
			Shaker.dispatcher.addEventListener(Event.COMPLETE, onLockAnimComplete);
			
			_lockerParticles.emitterX = _tournamentUnlockedContainer.x + (_tournamentUnlockedContainer.width * 0.5);
			_lockerParticles.emitterY = _tournamentUnlockedContainer.y + (_tournamentUnlockedContainer.height * 0.5);
		}
		
		/**
		 * When the unlock animation is complete, we shake the home button and activate it once the shaking
		 * is finished (to avoid a potential bug : shake on a null element).
		 */
		private function onLockAnimComplete(event:Event):void
		{
			Shaker.dispatcher.removeEventListener(Event.COMPLETE, onLockAnimComplete);
			_lockImage.texture = AbstractEntryPoint.assets.getTexture("unlock-big");
			TweenMax.allTo([_lockImage, _glow], 0.75, { delay:1, autoAlpha:0, onComplete:function():void
			{
				// shake the home button
				TweenMax.killTweensOf(_glow);
				Shaker.startShaking(_replayButton, 5);
				Shaker.dispatcher.addEventListener(Event.COMPLETE, activateHome);
			} });
			_lockerParticles.start(0.25);
		}
		
		/**
		 * Once the shaking on the home button has finished, we enable it.
		 */
		private function activateHome(event:Event):void
		{
			Shaker.dispatcher.removeEventListener(Event.COMPLETE, activateHome);
			_replayButton.addEventListener(Event.TRIGGERED, onGoHome);
			_homeButton.addEventListener(Event.TRIGGERED, onGoHome);
		}
		
		private function multiplyReward():void
		{
			_earnedPointsLabel.text = StringUtil.format(_("+{0}"), ScreenData.getInstance().gameData.rewardInDuel);
			_pointsParticles.start(0.25);
			if( MemberManager.getInstance().isTournamentAnimPending )
				unlockTournament();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Navigation handlers
		
		/**
		 * Go to home screen.
		 */
		private function onGoHome(event:Event):void
		{
			//Flox.logEvent("Choix en fin de jeu solo", { Choix:"Accueil"} );
			
			ScreenData.getInstance().gameData = new GameData();
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_homeButton.enabled = false;
				_replayButton.enabled = false;
				_facebookButton.enabled = false;
				advancedOwner.replaceScreen( ScreenIds.HOME_SCREEN );
			}
			else
			{
				/*if(MemberManager.getInstance().tokens == 0)
				{
					NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(_("Vous n'avez plus assez de Jetons pour rejouer ?"), ScreenIds.HOME_SCREEN) );
				}
				else
				{*/
					_homeButton.enabled = false;
					_replayButton.enabled = false;
					_facebookButton.enabled = false;
					advancedOwner.replaceScreen( ScreenIds.HOME_SCREEN );
				//}
			}
		}
		
		/**
		 * Play again.
		 */
		private function onPlayAgain(event:Event):void
		{
			//Flox.logEvent("Choix en fin de jeu solo", { Choix:"Rejouer"} );
			
			ScreenData.getInstance().gameData = new GameData();
			if( MemberManager.getInstance().isLoggedIn() )
			{
				Analytics.trackEvent("Fin mode solo", "Rejouer");
				
				_homeButton.enabled = false;
				_replayButton.enabled = false;
				_facebookButton.enabled = false;
				advancedOwner.replaceScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN  );
			}
			else
			{
				/*if(MemberManager.getInstance().tokens == 0)
				{
					NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(_("Vous n'avez plus assez de Jetons pour rejouer ?"), ScreenIds.GAME_TYPE_SELECTION_SCREEN) );
				}
				else
				{*/
					_homeButton.enabled = false;
					_replayButton.enabled = false;
					_facebookButton.enabled = false;
					advancedOwner.replaceScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN  );
				//}
			}
		}
		
		/**
		 * Go to the tournament ranking screen.
		 */
		private function onGoTournament(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_convertTournament);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				Analytics.trackEvent("Fin mode solo", "Redirection tournoi");
				advancedOwner.replaceScreen( ScreenIds.TOURNAMENT_RANKING_SCREEN );
			}
			touch = null;
		}
		
		/**
		 * Go to the shop screen (when not logged in)
		 */
		private function onConvertInShop(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_convertShopNotLoggedIn);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				Analytics.trackEvent("Fin mode solo", "Redirection boutique (non connecté)");
				advancedOwner.replaceScreen( ScreenIds.REGISTER_SCREEN );
			}
			touch = null;
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
			
			TweenMax.killTweensOf(_scoreLabel);
			_scoreLabel.removeFromParent(true);
			_scoreLabel = null;
			
			TweenMax.killTweensOf(_pointContainer);
			_pointContainer.removeFromParent(true);
			_pointContainer = null;
			
			TweenMax.killTweensOf(_earnedPointsLabel);
			_earnedPointsLabel.removeFromParent(true);
			_earnedPointsLabel = null;
			
			if(_winMorePointsImage)
			{
				TweenMax.killTweensOf(_winMorePointsImage);
				_winMorePointsImage.removeFromParent(true);
				_winMorePointsImage = null;
			}
			
			Starling.juggler.remove(_pointsParticles);
			_pointsParticles.stop(true);
			_pointsParticles.removeFromParent(true);
			_pointsParticles = null;
			
			if(_tournamentUnlockedContainer)
			{
				TweenMax.killTweensOf(_tournamentUnlockedContainer);
				_tournamentUnlockedContainer.removeFromParent(true);
				_tournamentUnlockedContainer = null;
				
				TweenMax.killTweensOf(_lockImage);
				_lockImage.removeFromParent(true);
				_lockImage = null;
				
				TweenMax.killTweensOf(_lockLabel);
				_lockLabel.removeFromParent(true);
				_lockLabel = null;
				
				TweenMax.killTweensOf(_glow);
				_glow.removeFromParent(true);
				
				Starling.juggler.remove(_lockerParticles);
				_lockerParticles.stop(true);
				_lockerParticles.removeFromParent(true);
				_lockerParticles = null;
			}
			
			if(_convertShop)
			{
				TweenMax.killTweensOf(_convertShop);
				_convertShop.removeFromParent(true);
				_convertShop = null;
			}
			
			if(_convertTournament)
			{
				TweenMax.killTweensOf(_convertTournament);
				_convertTournament.removeEventListener(TouchEvent.TOUCH, onGoTournament);
				_convertTournament.removeFromParent(true);
				_convertTournament = null;
			}
			
			if(_convertShopNotLoggedIn)
			{
				TweenMax.killTweensOf(_convertShopNotLoggedIn);
				_convertShopNotLoggedIn.removeEventListener(TouchEvent.TOUCH, onConvertInShop);
				_convertShopNotLoggedIn.removeFromParent(true);
				_convertShopNotLoggedIn = null;
			}
			
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