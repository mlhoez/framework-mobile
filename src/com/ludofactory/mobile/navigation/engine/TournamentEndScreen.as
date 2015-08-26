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
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Expo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.Shaker;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.model.GameData;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.EventPushNotificationContent;
	import com.ludofactory.mobile.core.notification.content.MarketingRegisterNotificationContent;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	import starling.utils.formatString;
	
	public class TournamentEndScreen extends AdvancedScreen
	{
		/**
		 * The logo */		
		private var _logo:ImageLoader;
		
		/**
		 * Score container. */		
		private var _scoreContainer:LayoutGroup;
		private var _scoreTitleLabel:Label;
		private var _scoreValueLabel:Label;
		
		/**
		 * Stars container. */		
		private var _starsContainer:LayoutGroup;
		private var _starsTitleLabel:Label;
		private var _starsArray:Vector.<Image>;
		private var _starsRowsContainer:LayoutGroup;	
		private var _firstRowStars:LayoutGroup;
		private var _secondRowStars:LayoutGroup;
		private var _starTexture:Texture;
		private var _starsOverlayContainer:Sprite;
		private var _starsToAddLabel:Label;
		
		/**
		 * Cumukated stars container. */		
		private var _cumulatedStarsContainer:LayoutGroup;
		private var _cumulatedStarsTitleLabel:Label;
		private var _cumulatedStarsValueLabel:Label;
		private var _star:Image;
		
		
		/** Buttons container */		
		private var _buttonsContainer:ScrollContainer;
		private var _continueButton:Button;
		private var _homeButton:Button;	
		private var _playAgainButton:Button;
		
		/**
		 * The particles. */		
		private var _particles:PDParticleSystem;
		private var _particlesLogo:PDParticleSystem;
		
		/**
		 * The index used to retreive the current level */		
		private var _count:int = 0;
		
		// Step 2 - Gift animation
		
		/**
		 * The current tournament position. */		
		private var _positionContainer:LayoutGroup;
		private var _positionTitleLabel:Label;
		private var _positionValueLabel:Label;
		
		/**
		 * The current gift container. */		
		private var _currentGiftContainer:ScrollContainer;
		private var _currentGiftLabel:Label;
		private var _currentGiftLoader:MovieClip;
		private var _currentGiftImage:ImageLoader;
		private var _currentGiftName:Label;
		
		/**
		 * The next gift container. */		
		private var _nextGiftContainer:ScrollContainer;
		private var _nextGiftLabel:Label;
		private var _nextGiftLoader:MovieClip;
		private var _nextGiftImage:ImageLoader;
		private var _nextGiftName:Label;
		
		/**
		 * The arrow displayed between the two gifts. */		
		private var _resultArrowContainer:ScrollContainer;
		private var _resultArrowLabel:Label;
		private var _resultArrowStar:Image;
		
		/**
		 * The tournament info container that displays the
		 * time left before the end of the tournement */		
		private var _tournamentTimeLeftContainer:ScrollContainer;
		private var _tournamentTimeLeftLabel:Label;
		private var _tournamentTimeLeftIcon:Image;
		
		/**
		 * The not connected container. */		
		private var _notConnectedContainer:ScrollContainer;
		private var _notConnectedIcon:Image;
		private var _notConnectedLabel:Label;
		
		public var _oldTweenValue:int;
		public var _targetTweenValue:int;
		
		public function TournamentEndScreen()
		{
			super();
			
			_fullScreen = true;
			_appDarkBackground = true;
			_canBack = false;
			
			SoundManager.getInstance().stopPlaylist("music", 3);
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
		 * The application has finished resizing.
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
			NavigationManager.resetNavigation(false);
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			
			var starTexture:Texture = AbstractEntryPoint.assets.getTexture("ruby-shadow");
			_starTexture = AbstractEntryPoint.assets.getTexture("ruby-front");
			var dropShadowFilter:DropShadowFilter = new DropShadowFilter(0, 75, 0x000000, 1, 7, 7);
			var titleTextFormat:TextFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 46 : 72), 0xffffff);
			var valueTextFormat:TextFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 68), 0xffdf00);
			var giftTextFormat:TextFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 32 : 36), 0xff4a00, false, false, null, null, null, TextFormatAlign.CENTER);
			var giftNameTextFormat:TextFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 34), 0xff4a00, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_logo = new ImageLoader();
			_logo.source = Theme.gameLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			addChild(_logo);
			
		// Step 1 ----
			
			const hlayoutBase:HorizontalLayout = new HorizontalLayout();
			hlayoutBase.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hlayoutBase.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hlayoutBase.paddingTop = hlayoutBase.paddingBottom = scaleAndRoundToDpi(5);
			hlayoutBase.gap = scaleAndRoundToDpi(10);
			
			_scoreContainer = new LayoutGroup();
			_scoreContainer.layout = hlayoutBase;
			addChild(_scoreContainer);
			
			_scoreTitleLabel = new Label();
			_scoreTitleLabel.text = _("Score final :");
			_scoreContainer.addChild(_scoreTitleLabel);
			_scoreTitleLabel.textRendererProperties.textFormat = titleTextFormat
			_scoreTitleLabel.textRendererProperties.nativeFilters = [ dropShadowFilter ];
			
			_scoreValueLabel = new Label();
			_scoreValueLabel.text = "0";
			_scoreContainer.addChild(_scoreValueLabel);
			_scoreValueLabel.textRendererProperties.textFormat = valueTextFormat;
			_scoreValueLabel.textRendererProperties.nativeFilters = [ dropShadowFilter ];
			
			// Stars
			
			const hlayoutScore:HorizontalLayout = new HorizontalLayout();
			hlayoutScore.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hlayoutScore.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			hlayoutScore.paddingTop = hlayoutScore.paddingBottom = scaleAndRoundToDpi(5);
			hlayoutScore.gap = scaleAndRoundToDpi(10);
			
			_starsContainer = new LayoutGroup();
			_starsContainer.layout = hlayoutScore;
			addChild( _starsContainer );
			
			_starsTitleLabel = new Label();
			_starsTitleLabel.text = _("Rubis :");
			_starsContainer.addChild( _starsTitleLabel );
			_starsTitleLabel.textRendererProperties.textFormat = titleTextFormat;
			_starsTitleLabel.textRendererProperties.wordWrap = false;
			_starsTitleLabel.textRendererProperties.nativeFilters = [ dropShadowFilter ];
			
			const vlayoutStars:VerticalLayout = new VerticalLayout();
			vlayoutStars.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayoutStars.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayoutStars.gap = scaleAndRoundToDpi(10);
			
			_starsRowsContainer = new LayoutGroup();
			_starsRowsContainer.layout = vlayoutStars;
			_starsContainer.addChild( _starsRowsContainer );
			
			const hlayoutStars:HorizontalLayout = new HorizontalLayout();
			hlayoutStars.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			hlayoutStars.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hlayoutStars.paddingTop = hlayoutStars.paddingBottom = scaleAndRoundToDpi(5);
			hlayoutStars.gap = scaleAndRoundToDpi(10);
			
			_firstRowStars = new LayoutGroup();
			_firstRowStars.layout = hlayoutStars;
			_starsRowsContainer.addChild( _firstRowStars );
			
			_secondRowStars = new LayoutGroup();
			_secondRowStars.layout = hlayoutStars;
			_starsRowsContainer.addChild( _secondRowStars );
			
			_starsArray = new Vector.<Image>();
			
			var starShadow:Image;
			for(var i:int = 10; i > 0; i--)
			{
				starShadow = new Image( starTexture );
				starShadow.scaleX = starShadow.scaleY = GlobalConfig.dpiScale;
				if( i > 5 )
					_firstRowStars.addChild( starShadow );
				else
					_secondRowStars.addChild( starShadow );
				_starsArray.push( starShadow );
			}
			starTexture.dispose();
			starTexture = null;
			_starsArray.fixed = true;
			
			// Cumulated stars
			
			_cumulatedStarsContainer = new LayoutGroup();
			_cumulatedStarsContainer.layout = hlayoutBase;
			addChild(_cumulatedStarsContainer);
			
			_cumulatedStarsTitleLabel = new Label();
			_cumulatedStarsTitleLabel.text = _("Rubis cumulés :");
			_cumulatedStarsContainer.addChild(_cumulatedStarsTitleLabel);
			_cumulatedStarsTitleLabel.textRendererProperties.textFormat = titleTextFormat
			_cumulatedStarsTitleLabel.textRendererProperties.nativeFilters = [ dropShadowFilter ];
			
			_cumulatedStarsValueLabel = new Label();
			_cumulatedStarsValueLabel.text = "10";
			_cumulatedStarsContainer.addChild(_cumulatedStarsValueLabel);
			_cumulatedStarsValueLabel.textRendererProperties.textFormat = valueTextFormat;
			_cumulatedStarsValueLabel.textRendererProperties.nativeFilters = [ dropShadowFilter ];
			_cumulatedStarsValueLabel.textRendererProperties.wordWrap = false;
			
			_star = new Image( _starTexture );
			_star.scaleX = _star.scaleY = GlobalConfig.dpiScale - 0.2;
			_cumulatedStarsContainer.addChild(_star);
			
			_starsOverlayContainer = new Sprite();
			addChild(_starsOverlayContainer);
			
			_starsToAddLabel = new Label();
			_starsToAddLabel.text = "+" + advancedOwner.screenData.gameData.numStarsOrPointsEarned;
			_starsToAddLabel.alpha = 0;
			_starsToAddLabel.visible = false;
			addChild(_starsToAddLabel);
			_starsToAddLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(80), 0xffdf00);
			_starsToAddLabel.textRendererProperties.nativeFilters = [ dropShadowFilter ];
			
		// Step 2 ----
			
			_positionContainer = new LayoutGroup();
			_positionContainer.alpha = 0;
			_positionContainer.visible = false;
			_positionContainer.layout = hlayoutBase;
			addChild(_positionContainer);
			
			_positionTitleLabel = new Label();
			_positionTitleLabel.text = _("Classement :");
			_positionContainer.addChild(_positionTitleLabel);
			_positionTitleLabel.textRendererProperties.textFormat = titleTextFormat
			_positionTitleLabel.textRendererProperties.nativeFilters = [ dropShadowFilter ];
			_positionTitleLabel.textRendererProperties.wordWrap = false;
			
			_positionValueLabel = new Label();
			if( advancedOwner.screenData.gameData.gameSessionPushed )
			{
				_positionValueLabel.text = formatString( Utilities.translatePosition(advancedOwner.screenData.gameData.position), advancedOwner.screenData.gameData.position);
			}
			else
			{
				_positionValueLabel.text = _("--");
			}
			_positionContainer.addChild(_positionValueLabel);
			_positionValueLabel.textRendererProperties.textFormat = valueTextFormat;
			_positionValueLabel.textRendererProperties.wordWrap = false;
			_positionValueLabel.textRendererProperties.nativeFilters = [ dropShadowFilter ];
			
			var hlayoutInfo:HorizontalLayout = new HorizontalLayout();
			hlayoutInfo.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_RIGHT;
			hlayoutInfo.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			
			// the tournament info container that displays the time left before the end of the tournement
			_tournamentTimeLeftContainer = new ScrollContainer();
			_tournamentTimeLeftContainer.alpha = 0;
			_tournamentTimeLeftContainer.visible = false;
			_tournamentTimeLeftContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_GREY;
			addChild(_tournamentTimeLeftContainer);
			_tournamentTimeLeftContainer.layout = hlayoutInfo;
			_tournamentTimeLeftContainer.padding = scaleAndRoundToDpi(-5);
			
			_tournamentTimeLeftLabel = new Label();
			_tournamentTimeLeftContainer.addChild(_tournamentTimeLeftLabel);
			_tournamentTimeLeftLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 34), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_tournamentTimeLeftIcon = new Image( AbstractEntryPoint.assets.getTexture("clock") );
			_tournamentTimeLeftIcon.alpha = 0;
			_tournamentTimeLeftIcon.visible = false;
			_tournamentTimeLeftIcon.scaleX = _tournamentTimeLeftIcon.scaleY = GlobalConfig.dpiScale;
			addChild(_tournamentTimeLeftIcon);
			
			// buttons
			
			_buttonsContainer = new ScrollContainer();
			_buttonsContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_buttonsContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild(_buttonsContainer);
			
			const hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hlayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			_buttonsContainer.layout = hlayout;
			
			_continueButton = new Button();
			_continueButton.label = _("Continuer");
			_continueButton.addEventListener(starling.events.Event.TRIGGERED, onSkipAnimation);
			_buttonsContainer.addChild(_continueButton);
			
			_homeButton = new Button();
			_homeButton.styleName = Theme.BUTTON_BLUE;
			_homeButton.label = _("Accueil");
			_homeButton.addEventListener(starling.events.Event.TRIGGERED, onGoHome);
			_buttonsContainer.addChild(_homeButton);
			
			_playAgainButton = new Button();
			_playAgainButton.label = _("Rejouer");
			_playAgainButton.addEventListener(starling.events.Event.TRIGGERED, onPlayAgain);
			_buttonsContainer.addChild(_playAgainButton);
			
			// particles
			
			_particles = new PDParticleSystem(Theme.particleStarsXml, Theme.particleStarTexture);
			_particles.touchable = false;
			_particles.maxNumParticles = 300;
			//_particles.scaleX = _particles.scaleY = Config.dpiScale; // Provoque un décalage sur les tablettes surtout
			addChild(_particles);
			Starling.juggler.add(_particles);
			
			_particlesLogo = new PDParticleSystem(Theme.particleStarsLogoXml, Theme.particleStarTexture);
			_particlesLogo.touchable = false;
			_particlesLogo.maxNumParticles = 500;
			//_particles.scaleX = _particles.scaleY = Config.dpiScale; // Provoque un décalage sur les tablettes surtout
			addChild(_particlesLogo);
			Starling.juggler.add(_particlesLogo);
			
			// timer
			
			if( advancedOwner.screenData.gameData.gameSessionPushed )
			{
				_currentGiftContainer = new ScrollContainer();
				_currentGiftContainer.alpha = 0;
				_currentGiftContainer.visible = false;
				_currentGiftContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_currentGiftContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_currentGiftContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_LEFT;
				addChild(_currentGiftContainer);
				_currentGiftContainer.layout["padding"] = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				_currentGiftContainer.layout["gap"] = scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 10);
				
				_currentGiftLabel = new Label();
				_currentGiftLabel.text = _("Gain actuel");
				_currentGiftContainer.addChild( _currentGiftLabel );
				_currentGiftLabel.textRendererProperties.textFormat = giftTextFormat;
				
				_currentGiftLoader = new MovieClip( Theme.blackLoaderTextures );
				Starling.juggler.add( _currentGiftLoader );
				_currentGiftContainer.addChild( _currentGiftLoader );
				
				_currentGiftImage = new ImageLoader();
				_currentGiftImage.addEventListener(starling.events.Event.COMPLETE, onCurrentGiftImageLoaded);
				_currentGiftImage.addEventListener(FeathersEventType.ERROR, onCurrentGiftImageNotLoaded);
				_currentGiftContainer.addChild(_currentGiftImage);
				
				_currentGiftName = new Label();
				_currentGiftName.text = advancedOwner.screenData.gameData.actualGiftName;
				_currentGiftContainer.addChild( _currentGiftName );
				_currentGiftName.textRendererProperties.textFormat = giftNameTextFormat;
				
				_nextGiftContainer = new ScrollContainer();
				_nextGiftContainer.alpha = 0;
				_nextGiftContainer.visible = false;
				_nextGiftContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_nextGiftContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_nextGiftContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_RIGHT;
				addChild(_nextGiftContainer);
				_nextGiftContainer.layout["padding"] = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				_nextGiftContainer.layout["gap"] = scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 10);
				
				_nextGiftLabel = new Label();
				_nextGiftLabel.text = _("Gain suivant");
				_nextGiftContainer.addChild( _nextGiftLabel );
				_nextGiftLabel.textRendererProperties.textFormat = giftTextFormat;
				
				_nextGiftLoader = new MovieClip( Theme.blackLoaderTextures );
				Starling.juggler.add( _nextGiftLoader );
				_nextGiftContainer.addChild( _nextGiftLoader );
				
				_nextGiftImage = new ImageLoader();
				_nextGiftImage.addEventListener(starling.events.Event.COMPLETE, onNextGiftImageLoaded);
				_nextGiftImage.addEventListener(FeathersEventType.ERROR, onNextGiftImageNotLoaded);
				_nextGiftContainer.addChild(_nextGiftImage);
				
				_nextGiftName = new Label();
				_nextGiftName.text = advancedOwner.screenData.gameData.nextGiftName;
				_nextGiftContainer.addChild( _nextGiftName );
				_nextGiftName.textRendererProperties.textFormat = giftNameTextFormat;
				
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
				
				_resultArrowStar = new Image( _starTexture );
				_resultArrowStar.scaleX = _resultArrowStar.scaleY = Utilities.getScaleToFillHeight(_resultArrowStar.height, (scaleAndRoundToDpi(83) * 0.4)); // 83 = hauteur de la flèche
				_resultArrowContainer.addChild(_resultArrowStar);
				
				_totalTime = advancedOwner.screenData.gameData.timeUntilTournamentEnd * 1000;
				_previousTime = getTimer();
				HeartBeat.registerFunction(update);
			}
			else
			{
				_tournamentTimeLeftLabel.text = _("Fin du tournoi dans : --");
				
				const hlayoutNotConnectedInfo:HorizontalLayout = new HorizontalLayout();
				hlayoutNotConnectedInfo.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
				hlayoutNotConnectedInfo.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
				hlayoutNotConnectedInfo.padding = scaleAndRoundToDpi(20);
				hlayoutNotConnectedInfo.gap = scaleAndRoundToDpi(20);
				
				_notConnectedContainer = new ScrollContainer();
				_notConnectedContainer.alpha = 0;
				_notConnectedContainer.visible = false;
				_notConnectedContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_LEFT;
				addChild( _notConnectedContainer );
				_notConnectedContainer.padding = 0;
				_notConnectedContainer.layout = hlayoutNotConnectedInfo;
				
				_notConnectedIcon = new Image( AbstractEntryPoint.assets.getTexture("tournament-end-wifi-icon") );
				_notConnectedIcon.scaleX = _notConnectedIcon.scaleY = GlobalConfig.dpiScale;
				_notConnectedContainer.addChild( _notConnectedIcon );
				
				_notConnectedLabel = new Label();
				_notConnectedLabel.text = MemberManager.getInstance().isLoggedIn() ? _("Pas de connexion Internet") : _("Vous n'êtes pas identifié") + "\n" +  MemberManager.getInstance().isLoggedIn() ? _("Les informations indiquées sont à titre informatives.") : _("Connectez vous à votre compte.");
				_notConnectedContainer.addChild( _notConnectedLabel );
				_notConnectedLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 27 : 42), Theme.COLOR_LIGHT_GREY);
				//_notConnectedLabel.textRendererProperties.insideTextFormat = new InsideTextFormatProperties(new TextFormat(Theme.FONT_SANSITA_ONE, scaleAndRoundToDpi(GlobalConfig.isPhone ? 32 : 42), Theme.COLOR_DARK_GREY), 0, Localizer.getInstance().translate("TOURNAMENT_END.NOT_CONNECTED_INFO_TITLE").length);
				// FIXME Checker la ligne ua dessus
			}
			
			// FIXME A décommenter pour gérer l'orientation
			//invalidate(); // Flag size ?
		}
		
		override protected function draw():void
		{
			// FIXME A décommenter pour gérer l'orientation
			if( isInvalid(INVALIDATION_FLAG_SIZE) /* && _logo */ )
			{
				// position common elements
				
				if( !_animationSkipped )
				{
					if( AbstractGameInfo.LANDSCAPE )
					{
						_logo.visible = false;
						_logo.x = _logo.y = _logo.width = _logo.height = 0;
					}
					else
					{
						_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.75 : 0.6);
						_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
						_logo.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
						_logo.validate();
					}
					
					_buttonsContainer.width = _continueButton.width = actualWidth * (GlobalConfig.isPhone ? 0.9 : 0.8);
					_homeButton.width = _playAgainButton.width = (_buttonsContainer.width * 0.5);
					_buttonsContainer.validate();
					_buttonsContainer.x = (actualWidth - _buttonsContainer.width) * 0.5;
					_buttonsContainer.y = actualHeight - _buttonsContainer.height - scaleAndRoundToDpi(40);
				}
				
				// calculate the maximum available height
				const maxElementsHeight:int = _buttonsContainer.y - _logo.y - _logo.height;
				
			// Step 1 --------------------------------------------------
				
				_scoreContainer.width = _starsContainer.width = _cumulatedStarsContainer.width = _buttonsContainer.width;
				_scoreContainer.x = _starsContainer.x = _cumulatedStarsContainer.x = _positionContainer.x = _buttonsContainer.x;
				
				_scoreContainer.validate();
				_scoreTitleLabel.validate();
				_starsContainer.validate();
				_cumulatedStarsContainer.validate();
				_scoreValueLabel.width = _scoreContainer.width - _scoreTitleLabel.width;
				
				_cumulatedStarsValueLabel.text = String(MemberManager.getInstance().getCumulatedStars()) + " ";
				_cumulatedStarsValueLabel.validate();
				_cumulatedStarsValueLabel.width = _cumulatedStarsValueLabel.width;
				_cumulatedStarsValueLabel.text = "" + ( MemberManager.getInstance().getCumulatedStars() - advancedOwner.screenData.gameData.numStarsOrPointsEarned );
				
				_scoreContainer.y = (((_logo.y + _logo.height) + (maxElementsHeight - (_scoreContainer.height + _starsContainer.height + _cumulatedStarsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 60 : 140))) * 0.5)) << 0;
				_starsContainer.y = _scoreContainer.y + _scoreContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 70);
				_cumulatedStarsContainer.y = _starsContainer.y + _starsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 70);
				
			// Step 2 --------------------------------------------------
				
				_tournamentTimeLeftContainer.height = scaleAndRoundToDpi(70);
				_tournamentTimeLeftContainer.width = _buttonsContainer.width;
				_tournamentTimeLeftLabel.width = _buttonsContainer.width - scaleAndRoundToDpi(10) - _tournamentTimeLeftIcon.width;
				_tournamentTimeLeftContainer.x = _buttonsContainer.x;
				
				// the game session have been pushed, then we display the gifts
				if( advancedOwner.screenData.gameData.gameSessionPushed )
				{
					// if the player is first, we display only the current gift
					if( advancedOwner.screenData.gameData.position == 1 )
					{
						_currentGiftContainer.width = _buttonsContainer.width;
					}
					else
					{
						_currentGiftContainer.width = _nextGiftContainer.width = _buttonsContainer.width * 0.45;
						_nextGiftContainer.x = _buttonsContainer.x + _buttonsContainer.width - _nextGiftContainer.width;
					}
					
					// current gift image
					_currentGiftContainer.x = _buttonsContainer.x;
					//_currentGiftContainer.y = _nextGiftContainer.y = _positionContainer.y + _positionContainer.height;
					_nextGiftLabel.width = _nextGiftName.width = _currentGiftLabel.width = _currentGiftName.width = _currentGiftContainer.width - _currentGiftContainer.layout["padding"];
					_nextGiftLabel.validate();
					_nextGiftName.validate();
					_currentGiftLabel.validate();
					_currentGiftName.validate();
					
					const imageContainerHeight:int = scaleAndRoundToDpi(GlobalConfig.isPhone ? 125 : 225) + (_currentGiftContainer.layout["padding"] * 2) + (_currentGiftContainer.layout["gap"] * 2) + Math.max(_currentGiftLabel.height , _nextGiftLabel.height) + Math.max(_currentGiftName.height, _nextGiftName.height);
					
					if( _currentGiftImage.isLoaded )
					{
						if( _animationSkipped )
						{
							TweenMax.killTweensOf(_cumulatedStarsContainer);
							_cumulatedStarsContainer.y = _cumulatedScoreContainerTargetY;
						}
							
						_currentGiftImage.validate();
						_currentGiftImage.width = (_currentGiftContainer.width * 0.9 - _currentGiftContainer.layout["padding"]) << 0;
						_currentGiftImage.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 125 : 225);
					}
					
					if( _nextGiftImage.isLoaded )
					{
						if( _animationSkipped )
						{
							TweenMax.killTweensOf(_cumulatedStarsContainer);
							_cumulatedStarsContainer.y = _cumulatedScoreContainerTargetY;
						}
						
						_nextGiftImage.validate();
						_nextGiftImage.width = (_nextGiftContainer.width * 0.9 - _currentGiftContainer.layout["padding"]) << 0;
						_nextGiftImage.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 125 : 225);
					}
					
					_currentGiftContainer.height = _nextGiftContainer.height = imageContainerHeight;
					
					if( !_animationSkipped )
					{
						_cumulatedStarsContainer.validate();
						_tournamentTimeLeftContainer.validate();
						_positionContainer.validate();
						
						_cumulatedScoreContainerTargetY = (((_logo.y + _logo.height) + (maxElementsHeight - (_cumulatedStarsContainer.height + _positionContainer.height + imageContainerHeight + _tournamentTimeLeftContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 15 : 40))) * 0.5)) << 0;
						_positionContainer.y = _cumulatedScoreContainerTargetY + _cumulatedStarsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 0 : 10);
						_currentGiftContainer.y = _nextGiftContainer.y = _positionContainer.y + _positionContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 10);
					}
					_tournamentTimeLeftContainer.y = _currentGiftContainer.y + imageContainerHeight + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					
					if( !_animationSkipped )
					{
						_resultArrowContainer.width = (_nextGiftContainer.x - (_currentGiftContainer.x + _currentGiftContainer.width)) + _currentGiftContainer.width * 0.4;
						_resultArrowContainer.validate();
						_resultArrowContainer.x = (_buttonsContainer.width - _resultArrowContainer.width) * 0.5;
						_resultArrowContainer.y = _currentGiftContainer.y + (_currentGiftContainer.height * 0.5) - (_resultArrowContainer.height * 0.5);
					}
				}
				else
				{
					_notConnectedContainer.width = _buttonsContainer.width;
					_notConnectedContainer.x = _buttonsContainer.x;
					_notConnectedLabel.width = _buttonsContainer.width - (_notConnectedContainer.layout["padding"] * 2) - _notConnectedContainer.layout["gap"] - _notConnectedIcon.width;
					
					_cumulatedStarsContainer.validate();
					_notConnectedContainer.validate();
					_tournamentTimeLeftContainer.validate();
					_positionContainer.validate();
					
					_cumulatedScoreContainerTargetY = (((_logo.y + _logo.height) + (maxElementsHeight - (_cumulatedStarsContainer.height + _positionContainer.height + _tournamentTimeLeftContainer.height + _notConnectedContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 70 : 120))) * 0.5)) << 0;
					
					_positionContainer.y = _cumulatedScoreContainerTargetY + _cumulatedStarsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 40);
					_tournamentTimeLeftContainer.y = _positionContainer.y + _positionContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
					_notConnectedContainer.y = _tournamentTimeLeftContainer.y + _tournamentTimeLeftContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				}
				
				_tournamentTimeLeftIcon.x = _tournamentTimeLeftContainer.x + scaleAndRoundToDpi(20);
				_tournamentTimeLeftIcon.y = _tournamentTimeLeftContainer.y + (_tournamentTimeLeftContainer.height - _tournamentTimeLeftIcon.height) * 0.5;
				
				if( _currentGiftImage && !_currentGiftImage.source )
				{
					_currentGiftImage.source = advancedOwner.screenData.gameData.actualGiftImageUrl;
					_nextGiftImage.source = advancedOwner.screenData.gameData.nextGiftImageUrl;
				}
				
				var dataInvalid:Boolean = isInvalid( INVALIDATION_FLAG_DATA );
				if( dataInvalid )
				{
					
					_oldTweenValue = 0;
					_targetTweenValue = this.advancedOwner.screenData.gameData.score;
					TweenMax.to(this, _targetTweenValue < 500 ? 1 : 2, { delay:0.75, _oldTweenValue : _targetTweenValue, onUpdate : function():void{ _scoreValueLabel.text = String(_oldTweenValue); }, onComplete:onContinueAnimation, ease:Expo.easeInOut } );
				}
				
				var pt:Point = _scoreContainer.localToGlobal( new Point(_scoreValueLabel.x, _scoreValueLabel.y) );
				_particlesLogo.emitterX = _particles.emitterX = pt.x + _scoreValueLabel.width * 0.25;
				_particlesLogo.emitterY = _particles.emitterY = pt.y + _scoreValueLabel.height * 0.25;
				_particlesLogo.emitterYVariance = _scoreValueLabel.height * 0.15;
			}
			
			super.draw();
		}
		
		private var _cumulatedScoreContainerTargetY:int;
		
//------------------------------------------------------------------------------------------------------------
//	Animation
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the first text animation (for the score) is over, we
		 * launch the stars into their container with particles.
		 */		
		private function onContinueAnimation():void
		{
			if( !_continueButton.isEnabled )
				return;
			
			var animDelay:Number = 0;
			for(_count; _count < advancedOwner.screenData.gameData.numStarsOrPointsEarned; _count++)
			{
				TweenMax.delayedCall(animDelay, launchStar, [_count]);
				animDelay += 0.75;
			}
			TweenMax.delayedCall(animDelay, animateAddStars);
		}
		
		/**
		 * Launch a star to its container.
		 */		
		private function launchStar(index:int):void
		{
			if( !_continueButton.isEnabled )
				return;
			
			_particlesLogo.emitterXVariance = 0;
			
			var starShadow:Image = _starsArray[index];
			var globalPoint:Point = ( index < 5 ? _firstRowStars : _secondRowStars).localToGlobal( new Point(starShadow.x + starShadow.width * 0.5, starShadow.y + starShadow.height * 0.5) );
			
			var star:Image = new Image( _starTexture );
			star.scaleX = star.scaleY = 1.7;
			star.alpha = 0;
			star.alignPivot();
			_starsOverlayContainer.addChild( star );
			
			_particles.emitterX = star.x = _particlesLogo.emitterX;
			_particles.emitterY = star.y = _particlesLogo.emitterY;
			
			// fade the star in, then scale it with a bounce ease
			TweenMax.to(star, 0.5, { alpha:1, x:globalPoint.x, y:globalPoint.y, ease:Expo.easeIn });
			TweenMax.to(star, 0.75, { delay:0.5, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, ease:Bounce.easeOut });
			// then display particles
			_particles.start(0.75);
			TweenMax.to(_particles, 0.5, { emitterX:globalPoint.x, emitterY:globalPoint.y, ease:Expo.easeIn });
			// shake the screen when the star is bouncing
			TweenMax.delayedCall(0.75, Shaker.startShaking, [this, 6]);
			// fade out the star shadow
			TweenMax.to(starShadow, 0, { delay:0.75, alpha:0 } );
			// particle logo
			_particlesLogo.start(0.25);
			TweenMax.to(_particlesLogo, 0.5, { emitterXVariance:(_scoreValueLabel.width * 0.5) });
			
			star = null;
			starShadow = null;
			globalPoint = null;
		}
		
		private function animateAddStars():void
		{
			if( !_continueButton.isEnabled )
				return;
			
			_starsToAddLabel.validate();
			_starsToAddLabel.alignPivot();
			_starsToAddLabel.scaleX = _starsToAddLabel.scaleY = 0;
			_starsToAddLabel.x = _starsContainer.x + _starsRowsContainer.x + _starsRowsContainer.width * 0.5;
			_starsToAddLabel.y = _starsContainer.y + _starsContainer.height * 0.5;
			TweenMax.to(_starsToAddLabel, 0.75, { autoAlpha:1, scaleX:1, scaleY:1 });
			TweenMax.to(_starsToAddLabel, 0.75, { delay:0.75, x:(_cumulatedStarsContainer.x + _cumulatedStarsValueLabel.x + _cumulatedStarsValueLabel.width * 0.5), y:(_cumulatedStarsContainer.y + _cumulatedStarsContainer.height * 0.5) });
			TweenMax.to(_starsToAddLabel, 0.25, { delay:1.5, autoAlpha:0 });
			
			/*_oldTweenValue =  ( MemberManager.getInstance().getCumulatedStars() - advancedOwner.screenData.gameData.numStarsOrPointsEarned < 0 ? 0:(MemberManager.getInstance().getCumulatedStars() - advancedOwner.screenData.gameData.numStarsOrPointsEarned) );
			_targetTweenValue =  MemberManager.getInstance().getCumulatedStars();
			TweenMax.to(this, 0.5, { delay:1.5, _oldTweenValue : _targetTweenValue, onUpdate : function():void{ _cumulatedStarsValueLabel.text = Utility.splitThousands(_oldTweenValue); }, onComplete:onCumulatedStarsAnimationFinished, ease:Expo.easeInOut } );*/
			TweenMax.delayedCall(1.5, function():void{ _cumulatedStarsValueLabel.text = Utilities.splitThousands( MemberManager.getInstance().getCumulatedStars()); });
			TweenMax.delayedCall(1.5, onCumulatedStarsAnimationFinished);
		}
		
		/**
		 * The cumulated stars text animation is finished, we can launch
		 * with a very short delay the next animation (related to the gifts).
		 */		
		private function onCumulatedStarsAnimationFinished():void
		{
			if( !_continueButton.isEnabled )
				return;
			
			TweenMax.delayedCall(0.5, advancedOwner.screenData.gameData.gameSessionPushed ? transitionConnected : transitionNotConnected);
		}
		
		/**
		 * The "Continue" button have been clicked, in this case we need to
		 * skip the first part animation.
		 */		
		private function onSkipAnimation(event:starling.events.Event = null):void
		{
			_continueButton.isEnabled = false;
			
			_scoreValueLabel.text = String(advancedOwner.screenData.gameData.score);
			_cumulatedStarsValueLabel.text = "" + MemberManager.getInstance().getCumulatedStars();
			
			var starShadow:Image;
			var globalPoint:Point;
			var star:Image;
			for(_count; _count < advancedOwner.screenData.gameData.numStarsOrPointsEarned; _count++)
			{
				starShadow = _starsArray[_count];
				globalPoint = ( _count < 5 ? _firstRowStars : _secondRowStars ).localToGlobal( new Point(starShadow.x, starShadow.y) );
				
				star = new Image( _starTexture );
				star.scaleX = star.scaleY = GlobalConfig.dpiScale;
				star.x = globalPoint.x;
				star.y = globalPoint.y;
				_starsOverlayContainer.addChild( star );
				starShadow.alpha = 0;
			}
			
			advancedOwner.screenData.gameData.gameSessionPushed ? transitionConnected() : transitionNotConnected();
		}
		
		/**
		 * Displays gifts
		 */		
		private function transitionConnected():void
		{
			// fade out unused elements
			TweenMax.allTo([_scoreContainer, _starsContainer, _starsOverlayContainer, _particles, _particlesLogo, _starsToAddLabel], 0.5, { autoAlpha:0 });
			// hide continue button
			TweenMax.to(_continueButton, 0.5, { width:0, autoAlpha:0 });
			// fade in new elements
			TweenMax.to(_positionContainer, 0.5, { delay:0.5, autoAlpha:1 });
			// tournament info container
			TweenMax.allTo([_tournamentTimeLeftContainer, _tournamentTimeLeftIcon], 0.5, { delay:1, autoAlpha:1 });
			// move elements that still needs to be displayed
			TweenMax.to(_cumulatedStarsContainer, 0.5, { y:_cumulatedScoreContainerTargetY });
			
			if( advancedOwner.screenData.gameData.position == 1 )
			{
				TweenMax.to(_currentGiftContainer, 0.5, { delay:0.75, autoAlpha:1 });
			}
			else
			{
				TweenMax.allTo([_currentGiftContainer, _nextGiftContainer], 0.5, { delay:0.75, autoAlpha:1 });
				TweenMax.to(_resultArrowContainer, 0.75, { delay:1.5, autoAlpha:1, x:(roundUp(actualWidth - _resultArrowContainer.width) * 0.5) });
			}
			_animationSkipped = true;
		}
		
		private var _animationSkipped:Boolean = false;
		
		private function transitionNotConnected():void
		{
			// fade out unused elements
			TweenMax.allTo([_scoreContainer, _starsContainer, _starsOverlayContainer], 0.5, { autoAlpha:0 });
			// hide continue button
			TweenMax.to(_continueButton, 0.5, { width:0, autoAlpha:0 });
			// fade in new elements
			TweenMax.to(_positionContainer, 0.5, { delay:0.5, autoAlpha:1 });
			TweenMax.allTo([_tournamentTimeLeftContainer, _tournamentTimeLeftIcon], 0.5, { delay:1, autoAlpha:1 });
			TweenMax.to(_notConnectedContainer, 0.5, { delay:1.5, autoAlpha:1 });
			// move elements that still needs to be displayed
			TweenMax.to(_cumulatedStarsContainer, 0.5, { y:_scoreContainer.y });
		}
//------------------------------------------------------------------------------------------------------------
//	Image loading
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the image is loaded
		 */		
		protected function onNextGiftImageLoaded(event:starling.events.Event):void
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
		protected function onNextGiftImageNotLoaded(event:starling.events.Event):void
		{
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		/**
		 * When the image is loaded
		 */		
		protected function onCurrentGiftImageLoaded(event:starling.events.Event):void
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
		protected function onCurrentGiftImageNotLoaded(event:starling.events.Event):void
		{
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Tournament timer
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Timer variables. */		
		private var _previousTime:Number;
		private var _elapsedTime:Number;
		private var _totalTime:Number;
		
		private var _days:int;
		private var _hours:int;
		private var _minutes:int;
		private var _seconds:int;
		
		/**
		 * Updates the label indicating when the tournament will end.
		 */		
		private function update(elapsedTime:Number):void
		{
			_elapsedTime = getTimer() - _previousTime;
			_previousTime = getTimer();
			_totalTime -= _elapsedTime;
			
			_days    = (Math.round(_totalTime / 1000) / 3600) / 24;
			_hours   = (Math.round(_totalTime / 1000) / 3600) % 24;
			_minutes = (Math.round(_totalTime / 1000) / 60) % 60;
			//_seconds = Math.round(_totalTime / 1000) % 60;
			
			if( _totalTime <= 0 )
			{
				HeartBeat.unregisterFunction(update);
				_tournamentTimeLeftLabel.text = _("Tournoi terminé");
			}
			else
			{
				if( _days <= 0 )
				{
					_tournamentTimeLeftLabel.text = formatString(_("Fin du tournoi dans : {0}\"{1}'"), (_hours < 10 ? "0":"") + _hours, (_minutes < 10 ? "0":"") + _minutes );
				}
				else
				{
					_tournamentTimeLeftLabel.text = formatString(_n("Fin du tournoi dans : {0} jour", "Fin du tournoi dans : {0} jours", _days), _days );
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Buttons handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Go home.
		 */		
		private function onGoHome(event:starling.events.Event):void
		{
			Flox.logEvent("Choix en fin de jeu tournoi", {Choix:"Accueil"});
			
			this.advancedOwner.screenData.gameData = new GameData();
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( advancedOwner.screenData.gameData.displayPushAlert )
				{
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Fin mode tournoi", "Affichage popup notifications push", null, NaN, MemberManager.getInstance().getId());
					//NotificationManager.addNotification( new EventPushNotification(ScreenIds.HOME_SCREEN) );
					NotificationPopupManager.addNotification( new EventPushNotificationContent(ScreenIds.HOME_SCREEN) );
				}
				else
				{
					TweenMax.killAll();
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Fin mode tournoi", "Redirection accueil", null, NaN, MemberManager.getInstance().getId());
					this.advancedOwner.showScreen( ScreenIds.HOME_SCREEN  );
				}
			}
			else
			{
				//NotificationManager.addNotification( new MarketingRegisterNotification(ScreenIds.HOME_SCREEN) );
				NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(ScreenIds.HOME_SCREEN) );
			}
		}
		
		/**
		 * Play again.
		 */		
		private function onPlayAgain(event:starling.events.Event):void
		{
			
			Flox.logEvent("Choix en fin de jeu tournoi", {Choix:"Rejouer"});
			
			this.advancedOwner.screenData.gameData = new GameData();
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( advancedOwner.screenData.gameData.displayPushAlert )
				{
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Fin mode tournoi", "Affichage popup notifications push", null, NaN, MemberManager.getInstance().getId());
					//NotificationManager.addNotification( new EventPushNotification(ScreenIds.GAME_TYPE_SELECTION_SCREEN) );
					NotificationPopupManager.addNotification( new EventPushNotificationContent(ScreenIds.GAME_TYPE_SELECTION_SCREEN) );
				}
				else
				{
					TweenMax.killAll();
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Fin mode tournoi", "Rejouer", null, NaN, MemberManager.getInstance().getId());
					this.advancedOwner.showScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN  );
				}
			}
			else
			{
				//NotificationManager.addNotification( new MarketingRegisterNotification(MemberManager.getInstance().getNumFreeGameSessions() >= Storage.getInstance().getProperty(StorageConfig.NUM_TOKENS_IN_TOURNAMENT_MODE) ? ScreenIds.GAME_TYPE_SELECTION_SCREEN : ScreenIds.HOME_SCREEN) );
				NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(MemberManager.getInstance().getNumTokens() >= Storage.getInstance().getProperty(StorageConfig.NUM_TOKENS_IN_TOURNAMENT_MODE) ? ScreenIds.GAME_TYPE_SELECTION_SCREEN : ScreenIds.HOME_SCREEN) );
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			HeartBeat.unregisterFunction(update);
			
			_logo.removeFromParent(true);
			_logo = null;
			
			_scoreValueLabel.removeFromParent(true);
			_scoreValueLabel = null;
			
			_scoreTitleLabel.removeFromParent(true);
			_scoreTitleLabel = null;
			
			_scoreContainer.removeFromParent(true);
			_scoreContainer = null;
			
			
			var star:Image;
			_starsArray.fixed = false;
			while(_starsArray.length != 0)
			{
				star = _starsArray.pop();
				star.removeFromParent(true);
				star = null;
			}
			_starsArray = null;
			
			_firstRowStars.removeFromParent(true);
			_firstRowStars = null;
			
			_secondRowStars.removeFromParent(true);
			_secondRowStars = null;
			
			_starsRowsContainer.removeFromParent(true);
			_starsRowsContainer = null;
			
			_starsTitleLabel.removeFromParent(true);
			_starsTitleLabel = null;
			
			_starsContainer.removeFromParent(true);
			_starsContainer = null;
			
			_starsOverlayContainer.removeFromParent(true);
			_starsOverlayContainer = null;
			
			_starTexture.dispose();
			_starTexture = null;
			
			_starsToAddLabel.removeFromParent(true);
			_starsToAddLabel = null;
			
			_positionValueLabel.removeFromParent(true);
			_positionValueLabel = null;
			
			_positionTitleLabel.removeFromParent(true);
			_positionTitleLabel = null;
			
			_positionContainer.removeFromParent(true);
			_positionContainer = null;
			
			if( _currentGiftImage )
			{
				_currentGiftImage.removeEventListener(starling.events.Event.COMPLETE, onCurrentGiftImageLoaded);
				_currentGiftImage.removeEventListener(FeathersEventType.ERROR, onCurrentGiftImageNotLoaded);
				_currentGiftImage.removeFromParent(true);
				_currentGiftImage = null;
			}
			
			if( _currentGiftLoader )
			{
				Starling.juggler.remove( _currentGiftLoader );
				_currentGiftLoader.removeFromParent(true);
				_currentGiftLoader = null;
			}
			
			if( _currentGiftLabel )
			{
				_currentGiftLabel.removeFromParent(true);
				_currentGiftLabel = null;
			}
			
			if( _currentGiftContainer )
			{
				_currentGiftContainer.removeFromParent(true);
				_currentGiftContainer = null;
			}
			
			if( _nextGiftImage )
			{
				_nextGiftImage.removeEventListener(starling.events.Event.COMPLETE, onNextGiftImageLoaded);
				_nextGiftImage.removeEventListener(FeathersEventType.ERROR, onNextGiftImageNotLoaded);
				_nextGiftImage.removeFromParent(true);
				_nextGiftImage = null;
			}
			
			if( _nextGiftLoader )
			{
				Starling.juggler.remove( _nextGiftLoader );
				_nextGiftLoader.removeFromParent(true);
				_nextGiftLoader = null;
			}
			
			if( _nextGiftLabel )
			{
				_nextGiftLabel.removeFromParent(true);
				_nextGiftLabel = null;
			}
			
			if( _nextGiftContainer )
			{
				_nextGiftContainer.removeFromParent(true);
				_nextGiftContainer = null;
			}
			
			if( _resultArrowStar )
			{
				_resultArrowStar.removeFromParent(true);
				_resultArrowStar = null;
			}
			
			if( _resultArrowLabel )
			{
				_resultArrowLabel.removeFromParent(true);
				_resultArrowLabel = null;
			}
			
			if( _resultArrowContainer )
			{
				_resultArrowContainer.removeFromParent(true);
				_resultArrowContainer = null;
			}
			
			if( _notConnectedIcon )
			{
				_notConnectedIcon.removeFromParent(true);
				_notConnectedIcon = null;
			}
			
			if( _notConnectedLabel )
			{
				_notConnectedLabel.removeFromParent(true);
				_notConnectedLabel = null;
			}
			
			if( _notConnectedContainer )
			{
				_notConnectedContainer.removeFromParent(true);
				_notConnectedContainer = null;
			}
			
			_tournamentTimeLeftIcon.removeFromParent(true);
			_tournamentTimeLeftIcon = null;
			
			_tournamentTimeLeftLabel.removeFromParent(true);
			_tournamentTimeLeftLabel = null;
			
			_tournamentTimeLeftContainer.removeFromParent(true);
			_tournamentTimeLeftContainer = null;
			
			_continueButton.removeEventListener(starling.events.Event.TRIGGERED, onSkipAnimation);
			_continueButton.removeFromParent(true);
			_continueButton = null;
			
			_homeButton.removeEventListener(starling.events.Event.TRIGGERED, onGoHome);
			_homeButton.removeFromParent(true);
			_homeButton = null;
			
			_playAgainButton.removeEventListener(starling.events.Event.TRIGGERED, onPlayAgain);
			_playAgainButton.removeFromParent(true);
			_playAgainButton = null;
			
			_buttonsContainer.removeFromParent(true);
			_buttonsContainer = null;
			
			Starling.juggler.remove( _particles );
			_particles.stop(true);
			_particles.removeFromParent(true);
			_particles = null;
			
			Starling.juggler.remove( _particlesLogo );
			_particlesLogo.stop(true);
			_particlesLogo.removeFromParent(true);
			_particlesLogo = null;
			
			super.dispose();
		}
		
	}
}