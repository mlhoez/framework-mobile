/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 13 Août 2013
*/
package com.ludofactory.mobile.navigation.engine
{
	
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.model.GameData;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.EventPushNotificationContent;
	import com.ludofactory.mobile.core.notification.content.MarketingRegisterNotificationContent;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.display.Scale3Image;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalLayout;
	import feathers.textures.Scale3Textures;
	
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.formatString;
	
	public class TournamentEndScreen extends AdvancedScreen
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
		private var _flag:Scale3Image;
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
		 * Cumulated rubies. */
		private var _cumulatedRubiesLabel:TextField;
		/**
		 * Points particles. */
		private var _pointsParticles:PDParticleSystem;
		
		private var _rankingLabel:TextField;
		private var _tournamentEndLabel:TextField;
		private var _notConnectedLabel:TextField;
		
		/**
		 * The current gift container. */
		private var _currentGiftContainer:ScrollContainer;
		private var _currentGiftLabel:TextField;
		private var _currentGiftLoader:MovieClip;
		private var _currentGiftImage:ImageLoader;
		private var _currentGiftName:TextField;
		
		/**
		 * The next gift container. */
		private var _nextGiftContainer:ScrollContainer;
		private var _nextGiftLabel:TextField;
		private var _nextGiftLoader:MovieClip;
		private var _nextGiftImage:ImageLoader;
		private var _nextGiftName:TextField;
		
		/**
		 * The arrow displayed between the two gifts. */
		private var _resultArrowContainer:ScrollContainer;
		private var _resultArrowLabel:Label;
		private var _resultArrowStar:Image;
		
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
		
		public function TournamentEndScreen()
		{
			super();
			
			_fullScreen = true;
			_appDarkBackground = true;
			_canBack = false;
			
			PADDING_TOP = scaleAndRoundToDpi(100);
			PADDING_BOTTOM = scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 60);
			
			SoundManager.getInstance().stopPlaylist("music", 3);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			//advancedOwner.screenData.gameData.score = 999999;
			//advancedOwner.screenData.gameData.gameSessionPushed = false;
			
			NavigationManager.resetNavigation(false);
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			
			_overlay = new Quad(5, 5, 0x000000);
			_overlay.alpha = 0.75;
			addChild(_overlay);
			
			_container = new EndScreenContainer();
			_container.alpha = 0;
			addChild(_container);
			
			_flag = new Scale3Image(new Scale3Textures(AbstractEntryPoint.assets.getTexture("end-game-flag"), 10, 10), GlobalConfig.dpiScale);
			_flag.useSeparateBatch = false;
			addChild(_flag);
			_flag.alignPivot();
			_flag.validate();
			_savedScale = _flag.scaleX;
			
			_title = new TextField(_flag.width - (scaleAndRoundToDpi(132*2)), _flag.height, _("FIN DE PARTIE"), Theme.FONT_SANSITA, scaleAndRoundToDpi(40), 0xffffff);
			_title.alignPivot();
			_title.autoScale = true;
			_title.alpha = 0
			_title.nativeFilters = [ new GlowFilter(0x7e0600, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
				new DropShadowFilter(2, 75, 0x7e0600, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
			addChild(_title);
			
			_scoreLabel = new TextField((_flag.width * 0.5), scaleAndRoundToDpi(50), formatString(_("Score final : {0}"), Utilities.splitThousands(advancedOwner.screenData.gameData.score)), Theme.FONT_SANSITA, scaleAndRoundToDpi(40), 0x27220d);
			_scoreLabel.alpha = 0;
			_scoreLabel.autoSize = TextFieldAutoSize.HORIZONTAL;
			addChild(_scoreLabel);
			
			_pointContainer = new Image(AbstractEntryPoint.assets.getTexture("ruby-container"));
			_pointContainer.alpha = 0;
			_pointContainer.scaleX = _pointContainer.scaleY = GlobalConfig.dpiScale;
			addChild(_pointContainer);
			
			_earnedPointsLabel = new TextField(scaleAndRoundToDpi(129), (_pointContainer.height - scaleAndRoundToDpi(10)), "+0", Theme.FONT_SANSITA, scaleAndRoundToDpi(50), 0xffffff);
			_earnedPointsLabel.autoScale = true;
			_earnedPointsLabel.alpha = 0;
			addChild(_earnedPointsLabel);
			
			_cumulatedRubiesLabel = new TextField((_pointContainer.width - scaleAndRoundToDpi(190) - scaleAndRoundToDpi(10)), (_pointContainer.height - scaleAndRoundToDpi(10)),
					formatString(_("({0} au total)"), Utilities.splitThousands((MemberManager.getInstance().cumulatedRubies - advancedOwner.screenData.gameData.numStarsOrPointsEarned))),
					Theme.FONT_SANSITA, scaleAndRoundToDpi(50), 0xffffff);
			_cumulatedRubiesLabel.autoScale = true;
			_cumulatedRubiesLabel.alpha = 0;
			addChild(_cumulatedRubiesLabel);
			
			_pointsParticles = new PDParticleSystem(Theme.particleVortexXml, AbstractEntryPoint.assets.getTexture("particle-sparkle-end"));
			_pointsParticles.touchable = false;
			_pointsParticles.maxNumParticles = 300;
			//_pointsParticles.blendFactorSource = Context3DBlendFactor.DESTINATION_ALPHA;
			//_pointsParticles.blendFactorDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			addChild(_pointsParticles);
			Starling.juggler.add(_pointsParticles);
			
			if(advancedOwner.screenData.gameData.gameSessionPushed)
			{
				// pushé
				_rankingLabel = new TextField(5, 5, formatString(_("Vous êtes <font color='#eb0064'>{0}</font>"), (formatString( Utilities.translatePosition(advancedOwner.screenData.gameData.position), advancedOwner.screenData.gameData.position))) + " - ",
						Theme.FONT_SANSITA, scaleAndRoundToDpi(28), 0x27220d);
				_rankingLabel.isHtmlText = true;
				_rankingLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				_rankingLabel.alpha = 0;
				addChild(_rankingLabel);
				
				_tournamentEndLabel = new TextField(5, 5, "", Theme.FONT_SANSITA, scaleAndRoundToDpi(28), 0x27220d);
				_tournamentEndLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				_tournamentEndLabel.alpha = 0;
				addChild(_tournamentEndLabel);
				
				_currentGiftContainer = new ScrollContainer();
				_currentGiftContainer.alpha = 0;
				_currentGiftContainer.visible = false;
				_currentGiftContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_currentGiftContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_currentGiftContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_LEFT;
				addChild(_currentGiftContainer);
				_currentGiftContainer.layout["padding"] = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				_currentGiftContainer.layout["gap"] = scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 10);
				
				_currentGiftLabel = new TextField(5, scaleAndRoundToDpi(25), _("Gain actuel"), Theme.FONT_SANSITA, scaleAndRoundToDpi(28), 0x27220d);
				_currentGiftLabel.autoScale = true;
				_currentGiftContainer.addChild( _currentGiftLabel );
				
				_currentGiftLoader = new MovieClip( Theme.blackLoaderTextures );
				Starling.juggler.add( _currentGiftLoader );
				_currentGiftContainer.addChild( _currentGiftLoader );
				
				_currentGiftImage = new ImageLoader();
				_currentGiftImage.addEventListener(Event.COMPLETE, onCurrentGiftImageLoaded);
				_currentGiftImage.addEventListener(FeathersEventType.ERROR, onCurrentGiftImageNotLoaded);
				_currentGiftImage.source = advancedOwner.screenData.gameData.actualGiftImageUrl;
				_currentGiftContainer.addChild(_currentGiftImage);
				
				_currentGiftName = new TextField(5, scaleAndRoundToDpi(25), advancedOwner.screenData.gameData.actualGiftName, Theme.FONT_SANSITA, scaleAndRoundToDpi(28), 0x27220d);
				_currentGiftName.autoScale = true;
				_currentGiftContainer.addChild( _currentGiftName );
				
				_nextGiftContainer = new ScrollContainer();
				_nextGiftContainer.alpha = 0;
				_nextGiftContainer.visible = false;
				_nextGiftContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_nextGiftContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_nextGiftContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_RIGHT;
				addChild(_nextGiftContainer);
				_nextGiftContainer.layout["padding"] = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				_nextGiftContainer.layout["gap"] = scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 10);
				
				_nextGiftLabel = new TextField(5, scaleAndRoundToDpi(25), _("Gain suivant"), Theme.FONT_SANSITA, scaleAndRoundToDpi(28), 0x27220d);
				_nextGiftLabel.autoScale = true;
				_nextGiftContainer.addChild( _nextGiftLabel );
				
				_nextGiftLoader = new MovieClip( Theme.blackLoaderTextures );
				Starling.juggler.add( _nextGiftLoader );
				_nextGiftContainer.addChild( _nextGiftLoader );
				
				_nextGiftImage = new ImageLoader();
				_nextGiftImage.addEventListener(Event.COMPLETE, onNextGiftImageLoaded);
				_nextGiftImage.addEventListener(FeathersEventType.ERROR, onNextGiftImageNotLoaded);
				_nextGiftImage.source = advancedOwner.screenData.gameData.nextGiftImageUrl;
				_nextGiftContainer.addChild(_nextGiftImage);
				
				_nextGiftName = new TextField(5, scaleAndRoundToDpi(25), advancedOwner.screenData.gameData.nextGiftName, Theme.FONT_SANSITA, scaleAndRoundToDpi(28), 0x27220d);
				_nextGiftName.autoScale = true;
				_nextGiftContainer.addChild( _nextGiftName );
				
				// the arrow that displays the number of stars needed before the next gift
				const hlayoutArrow:HorizontalLayout = new HorizontalLayout();
				hlayoutArrow.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
				hlayoutArrow.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
				hlayoutArrow.gap = scaleAndRoundToDpi(5);
				
				_resultArrowContainer = new ScrollContainer();
				_resultArrowContainer.layout = hlayoutArrow;
				_resultArrowContainer.alpha = 0;
				_resultArrowContainer.visible = false;
				_resultArrowContainer.styleName = Theme.TOURNAMENT_END_ARROW_CONTAINER;
				addChild(_resultArrowContainer);
				
				_resultArrowLabel = new Label();
				_resultArrowLabel.text = "+" + advancedOwner.screenData.gameData.numStarsForNextGift;
				_resultArrowContainer.addChild(_resultArrowLabel);
				_resultArrowLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
				_resultArrowLabel.textRendererProperties.wordWrap = false;
				
				_resultArrowStar = new Image( AbstractEntryPoint.assets.getTexture("ruby") );
				_resultArrowStar.scaleX = _resultArrowStar.scaleY = Utilities.getScaleToFillHeight(_resultArrowStar.height, (scaleAndRoundToDpi(83) * 0.4)); // 83 = hauteur de la flèche
				_resultArrowContainer.addChild(_resultArrowStar);
				
				_totalTime = advancedOwner.screenData.gameData.timeUntilTournamentEnd * 1000;
				HeartBeat.registerFunction(update);
			}
			else
			{
				// pas pushé
				
				_notConnectedLabel = new TextField(5, 5, _("Impossible de déterminer votre classement et vos gains provisoires car vous n'êtes pas connecté à Internet."), Theme.FONT_ARIAL, scaleAndRoundToDpi(24), 0x666666, true);
				_notConnectedLabel.autoSize = TextFieldAutoSize.VERTICAL;
				_notConnectedLabel.alpha = 0;
				_notConnectedLabel.border = true;
				addChild(_notConnectedLabel);
			}
			
			// 
			
			_homeButton = new Button(AbstractEntryPoint.assets.getTexture("home-button"));
			_homeButton.alpha = 0;
			_homeButton.scaleX = _homeButton.scaleY = GlobalConfig.dpiScale;
			_homeButton.addEventListener(Event.TRIGGERED, onGoHome);
			addChild(_homeButton);
			
			_replayButton = new Button(AbstractEntryPoint.assets.getTexture("replay-button"));
			_replayButton.alpha = 0;
			_replayButton.scaleX = _replayButton.scaleY = GlobalConfig.dpiScale;
			_replayButton.addEventListener(Event.TRIGGERED, onPlayAgain);
			addChild(_replayButton);
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Partager"), ButtonFactory.FACEBOOK_TYPE_SHARE); // TODO
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
				
				_pointContainer.x = roundUp((actualWidth - _pointContainer.width) * 0.5);
				_earnedPointsLabel.x = _pointContainer.x;
				_cumulatedRubiesLabel.x = _pointContainer.x + scaleAndRoundToDpi(190); /* x after ruby */
				
				_container.height = PADDING_TOP + PADDING_BOTTOM + _scoreLabel.height + scaleAndRoundToDpi(5) + _pointContainer.height + scaleAndRoundToDpi(10);
				
				if(advancedOwner.screenData.gameData.gameSessionPushed)
				{
					_rankingLabel.x = roundUp((actualWidth - _rankingLabel.width - _tournamentEndLabel.width) * 0.5);
					_tournamentEndLabel.x = _rankingLabel.x + _rankingLabel.width;
					
					// ---
					
					_currentGiftContainer.width = _nextGiftContainer.width = _container.width * 0.4;
					_currentGiftContainer.validate();
					_nextGiftContainer.validate();
					
					// if the player is first, we display only the current gift
					if( advancedOwner.screenData.gameData.position == 1 )
					{
						_currentGiftContainer.x = roundUp((actualWidth - _currentGiftContainer.width) * 0.5);
					}
					else
					{
						_currentGiftContainer.x = roundUp((actualWidth - _currentGiftContainer.width - _nextGiftContainer.width - (_container.width * 0.05)) * 0.5);
						_nextGiftContainer.x = _currentGiftContainer.x + _currentGiftContainer.width + (_container.width * 0.05);
					}
					_nextGiftLabel.width = _nextGiftName.width = _currentGiftLabel.width = _currentGiftName.width = _currentGiftContainer.width - _currentGiftContainer.layout["padding"];
					
					const imageContainerHeight:int = scaleAndRoundToDpi(GlobalConfig.isPhone ? 80 : 180) + (_currentGiftContainer.layout["padding"] * 2) + (_currentGiftContainer.layout["gap"] * 2) + Math.max(_currentGiftLabel.height , _nextGiftLabel.height) + Math.max(_currentGiftName.height, _nextGiftName.height);
					
					if( _currentGiftImage.isLoaded )
					{
						_currentGiftImage.validate();
						_currentGiftImage.width = (_currentGiftContainer.width * 0.9 - _currentGiftContainer.layout["padding"]) << 0;
						_currentGiftImage.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 70 : 170);
					}
					
					if( _nextGiftImage.isLoaded )
					{
						_nextGiftImage.validate();
						_nextGiftImage.width = (_nextGiftContainer.width * 0.9 - _currentGiftContainer.layout["padding"]) << 0;
						_nextGiftImage.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 70 : 170);
					}
					
					_currentGiftContainer.height = _nextGiftContainer.height = imageContainerHeight;
					
					_resultArrowContainer.width = (_nextGiftContainer.x - (_currentGiftContainer.x + _currentGiftContainer.width)) + _currentGiftContainer.width * 0.4;
					_resultArrowContainer.validate();
					_resultArrowContainer.x = roundUp((actualWidth - _resultArrowContainer.width) * 0.5);
					
					_container.height += _rankingLabel.height + scaleAndRoundToDpi(5) + _currentGiftContainer.height //+ scaleAndRoundToDpi(10);
				}
				else
				{
					_notConnectedLabel.width = _container.width * 0.8;
					_notConnectedLabel.x = roundUp((actualWidth - _notConnectedLabel.width) * 0.5);
					
					_container.height += _notConnectedLabel.height + scaleAndRoundToDpi(5);
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
			_earnedPointsLabel.y = _cumulatedRubiesLabel.y = _pointContainer.y;
			TweenMax.allTo([_pointContainer, _earnedPointsLabel, _cumulatedRubiesLabel, _scoreLabel], 0.5, {alpha: 1});
			
			if(advancedOwner.screenData.gameData.gameSessionPushed)
			{
				_rankingLabel.y = _tournamentEndLabel.y = _pointContainer.y + _pointContainer.height + scaleAndRoundToDpi(5);
				TweenMax.allTo([_rankingLabel, _tournamentEndLabel], 0.5, {alpha: 1});
				
				_currentGiftContainer.y = _rankingLabel.y + _rankingLabel.height + scaleAndRoundToDpi(10);
				if( advancedOwner.screenData.gameData.position == 1 )
				{
					// the user is first, thus we only display one gift container
					TweenMax.to(_currentGiftContainer, 0.5, {autoAlpha: 1});
				}
				else
				{
					// otherwise we can display both
					_nextGiftContainer.y = _currentGiftContainer.y;
					_resultArrowContainer.y = _currentGiftContainer.y + (_currentGiftContainer.height * 0.5) - (_resultArrowContainer.height * 0.5);
					TweenMax.allTo([_currentGiftContainer, _nextGiftContainer, _resultArrowContainer], 0.5, {autoAlpha: 1});
				}
			}
			else
			{
				_notConnectedLabel.y = _pointContainer.y + _pointContainer.height + scaleAndRoundToDpi(5);
				TweenMax.to(_notConnectedLabel, 0.5, {autoAlpha: 1});
			}
			
			// everything is in place, we animate the score now
			_scoreLabel.text = formatString(_("Score final : {0}"), 0);
			_oldTweenValue = 0;
			_targetTweenValue = advancedOwner.screenData.gameData.score;
			if( _targetTweenValue == 0 )
				Starling.juggler.delayCall(animateLabelFromScoreToPoints, 1);
			else
				TweenMax.to(this, _targetTweenValue < 500 ? 1 : 2, { delay:0.5, _oldTweenValue : _targetTweenValue, onUpdate : function():void{ _scoreLabel.text = formatString(_("Score final : {0}"), Utilities.splitThousands(_oldTweenValue)); }, onComplete:animateLabelFromScoreToPoints, ease:Expo.easeInOut } );
			
		}
		
		/**
		 * The score have been animated, now we show the rewards
		 */
		private function animateLabelFromScoreToPoints():void
		{
			if(!_earnedPointsLabel) // if the screen changed after the starling juggler delayed call
				return;
			
			_earnedPointsLabel.text = formatString(_("+{0}"), advancedOwner.screenData.gameData.numStarsOrPointsEarned);
			_cumulatedRubiesLabel.text = formatString(_("({0} au total)"), Utilities.splitThousands(MemberManager.getInstance().cumulatedRubies));
			
			_pointsParticles.start(0.25);
			_pointsParticles.emitterX = _earnedPointsLabel.x + _earnedPointsLabel.width * 0.5;
			_pointsParticles.emitterY = _earnedPointsLabel.y + _earnedPointsLabel.height * 0.5;
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Go home.
		 */
		private function onGoHome(event:Event):void
		{
			Flox.logEvent("Choix en fin de jeu tournoi", {Choix:"Accueil"});
			
			this.advancedOwner.screenData.gameData = new GameData();
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( advancedOwner.screenData.gameData.displayPushAlert )
				{
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Fin mode tournoi", "Affichage popup notifications push", null, NaN, MemberManager.getInstance().id);
					NotificationPopupManager.addNotification( new EventPushNotificationContent(ScreenIds.HOME_SCREEN) );
				}
				else
				{
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Fin mode tournoi", "Redirection accueil", null, NaN, MemberManager.getInstance().id);
					this.advancedOwner.showScreen(ScreenIds.HOME_SCREEN);
				}
			}
			else
			{
				if(MemberManager.getInstance().tokens == 0)
				{
					NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(ScreenIds.HOME_SCREEN) );
				}
				else
				{
					_homeButton.enabled = false;
					_replayButton.enabled = false;
					_facebookButton.enabled = false;
					advancedOwner.showScreen( ScreenIds.HOME_SCREEN  );
				}
			}
		}
		
		/**
		 * Play again.
		 */
		private function onPlayAgain(event:Event):void
		{
			
			Flox.logEvent("Choix en fin de jeu tournoi", {Choix:"Rejouer"});
			
			this.advancedOwner.screenData.gameData = new GameData();
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( advancedOwner.screenData.gameData.displayPushAlert )
				{
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Fin mode tournoi", "Affichage popup notifications push", null, NaN, MemberManager.getInstance().id);
					NotificationPopupManager.addNotification( new EventPushNotificationContent(ScreenIds.GAME_TYPE_SELECTION_SCREEN) );
				}
				else
				{
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Fin mode tournoi", "Rejouer", null, NaN, MemberManager.getInstance().id);
					this.advancedOwner.showScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN  );
				}
			}
			else
			{
				if(MemberManager.getInstance().tokens == 0)
				{
					NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(MemberManager.getInstance().tokens >= Storage.getInstance().getProperty(StorageConfig.NUM_TOKENS_IN_TOURNAMENT_MODE) ? ScreenIds.GAME_TYPE_SELECTION_SCREEN : ScreenIds.HOME_SCREEN) );
				}
				else
				{
					_homeButton.enabled = false;
					_replayButton.enabled = false;
					_facebookButton.enabled = false;
					advancedOwner.showScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN  );
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Tournament timer
		
		/**
		 * Timer variables. */
		private var _totalTime:Number;
		private var _days:int;
		private var _hours:int;
		private var _minutes:int;
		private var _seconds:int;
		
		/**
		 * Updates the label indicating when the tournament will end.
		 */
		private function update(frameElapsedTime:int, totalElapsedTime:int):void
		{
			_totalTime -= totalElapsedTime;
			
			_days    = (Math.round(_totalTime / 1000) / 3600) / 24;
			_hours   = (Math.round(_totalTime / 1000) / 3600) % 24;
			_minutes = (Math.round(_totalTime / 1000) / 60) % 60;
			//_seconds = Math.round(_totalTime / 1000) % 60;
			
			if( _totalTime <= 0 )
			{
				HeartBeat.unregisterFunction(update);
				_tournamentEndLabel.text = _("Tournoi terminé");
			}
			else
			{
				if( _days <= 0 )
				{
					_tournamentEndLabel.text = formatString(_("Fin dans : {0}\"{1}'"), (_hours < 10 ? "0":"") + _hours, (_minutes < 10 ? "0":"") + _minutes );
				}
				else
				{
					_tournamentEndLabel.text = formatString(_n("Fin dans : {0} jour", "Fin dans : {0} jours", _days), _days );
				}
				
				if(!_isReplaced)
				{
					_isReplaced = true;
					_rankingLabel.x = roundUp((actualWidth - _rankingLabel.width - _tournamentEndLabel.width) * 0.5);
					_tournamentEndLabel.x = _rankingLabel.x + _rankingLabel.width;
				}
			}
		}
		
		private var _isReplaced:Boolean = false;
		
//------------------------------------------------------------------------------------------------------------
//	Image loading
		
		/**
		 * When the image is loaded
		 */
		protected function onNextGiftImageLoaded(event:Event):void
		{
			Starling.juggler.remove( _nextGiftLoader );
			_nextGiftLoader.removeFromParent(true);
			_nextGiftLoader = null;
			
			_nextGiftImage.alpha = 0;
			_nextGiftImage.visible = true;
			TweenMax.to(_nextGiftImage, 0.75, { alpha:1 });
			
			_nextGiftContainer.invalidate( INVALIDATION_FLAG_SIZE );
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * When the image could not be loaded.
		 */
		protected function onNextGiftImageNotLoaded(event:Event):void
		{
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		/**
		 * When the image is loaded
		 */
		protected function onCurrentGiftImageLoaded(event:Event):void
		{
			Starling.juggler.remove( _currentGiftLoader );
			_currentGiftLoader.removeFromParent(true);
			_currentGiftLoader = null;
			
			_currentGiftImage.alpha = 0;
			_currentGiftImage.visible = true;
			TweenMax.to(_currentGiftImage, 0.75, { alpha:1 });
			
			_currentGiftContainer.invalidate( INVALIDATION_FLAG_SIZE );
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * When the image could not be loaded.
		 */
		protected function onCurrentGiftImageNotLoaded(event:Event):void
		{
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			HeartBeat.unregisterFunction(update);
			
			TweenMax.killTweensOf(this);
			
			_overlay.removeFromParent(true);
			_overlay = null;
			
			_flag.removeFromParent(true);
			_flag = null;
			
			_title.removeFromParent(true);
			_title = null;
			
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
			
			TweenMax.killTweensOf(_cumulatedRubiesLabel);
			_cumulatedRubiesLabel.removeFromParent(true);
			_cumulatedRubiesLabel = null;
			
			Starling.juggler.remove(_pointsParticles);
			_pointsParticles.stop(true);
			_pointsParticles.removeFromParent(true);
			_pointsParticles = null;
			
			if(_rankingLabel)
			{
				TweenMax.killTweensOf(_rankingLabel);
				_rankingLabel.removeFromParent(true);
				_rankingLabel = null;
				
				TweenMax.killTweensOf(_tournamentEndLabel);
				_tournamentEndLabel.removeFromParent(true);
				_tournamentEndLabel = null;
				
				//
				
				TweenMax.killTweensOf(_currentGiftImage);
				_currentGiftImage.removeEventListener(Event.COMPLETE, onCurrentGiftImageLoaded);
				_currentGiftImage.removeEventListener(FeathersEventType.ERROR, onCurrentGiftImageNotLoaded);
				_currentGiftImage.removeFromParent(true);
				_currentGiftImage = null;
				
				_currentGiftLabel.removeFromParent(true);
				_currentGiftLabel = null;
				
				_currentGiftName.removeFromParent(true);
				_currentGiftName = null;
				
				if(_currentGiftLoader)
				{
					Starling.juggler.remove(_currentGiftLoader);
					_currentGiftLoader.removeFromParent(true);
					_currentGiftLoader = null;
				}
				
				TweenMax.killTweensOf(_currentGiftContainer);
				_currentGiftContainer.removeFromParent(true);
				_currentGiftContainer = null;
				
				//
				
				TweenMax.killTweensOf(_nextGiftImage);
				_nextGiftImage.removeEventListener(Event.COMPLETE, onCurrentGiftImageLoaded);
				_nextGiftImage.removeEventListener(FeathersEventType.ERROR, onCurrentGiftImageNotLoaded);
				_nextGiftImage.removeFromParent(true);
				_nextGiftImage = null;
				
				_nextGiftLabel.removeFromParent(true);
				_nextGiftLabel = null;
				
				_nextGiftName.removeFromParent(true);
				_nextGiftName = null;
				
				if(_nextGiftLoader)
				{
					Starling.juggler.remove(_nextGiftLoader);
					_nextGiftLoader.removeFromParent(true);
					_nextGiftLoader = null;
				}
				
				TweenMax.killTweensOf(_nextGiftContainer);
				_nextGiftContainer.removeFromParent(true);
				_nextGiftContainer = null;
				
				//
				
				_resultArrowStar.removeFromParent(true);
				_resultArrowStar = null;
				
				_resultArrowLabel.removeFromParent(true);
				_resultArrowLabel = null;
				
				TweenMax.killTweensOf(_resultArrowContainer);
				_resultArrowContainer.removeFromParent(true);
				_resultArrowContainer = null;
			}
			else
			{
				TweenMax.killTweensOf(_notConnectedLabel);
				_notConnectedLabel.removeFromParent(true);
				_notConnectedLabel = null;
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