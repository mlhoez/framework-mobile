/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 13 Août 2013
*/
package com.ludofactory.mobile.engine
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Expo;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.AlertManager;
	import com.ludofactory.mobile.core.manager.JugglerManager;
	import com.ludofactory.mobile.core.membership.MemberManager;
	import com.ludofactory.mobile.core.notification.NotificationManager;
	import com.ludofactory.mobile.core.notification.content.CreateAccountNotification;
	import com.ludofactory.mobile.core.scoring.ScoreToStarsData;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.utils.Shaker;
	import com.ludofactory.mobile.utils.TextAnimationManager;
	import com.ludofactory.mobile.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.utils.scaleToDpi;
	
	import flash.display.StageAspectRatio;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import app.AppEntryPoint;
	import com.ludofactory.mobile.config.GlobalConfig;
	import app.screens.ProgressPopup;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	
	public class TournamentEndScreen extends AdvancedScreen
	{
		// Top part
		/**
		 * The main container */		
		private var _mainContainer:ScrollContainer;
		
		/**
		 * The title */		
		private var _title:Label;
		
		/**
		 * The logo */		
		private var _logo:Image;
		
		/**
		 * Contains the two columns */		
		private var _resultsContainer:ScrollContainer;
		
		// left side
		
		/**
		 * The left column */		
		private var _leftContainer:ScrollContainer;
		/**
		 * The score and stars container */		
		private var _scoreAndStarsContainer:ScrollContainer;
		/**
		 * The first row of stars */		
		private var _firstRowStars:ScrollContainer;
		/**
		 * The second row of stars */		
		private var _secondRowStars:ScrollContainer;
		/**
		 * The third row of stars */		
		private var _thirdRowStars:ScrollContainer;
		/**
		 * The score label, which will animate */		
		private var _scoreLabel:Label;
		/**
		 * The vector of 10 stars */		
		private var _starsArray:Vector.<Image>;
		
		/**
		 * The tournament button container */		
		private var _tournamentContainer:ScrollContainer;
		/**
		 * The podium icon */		
		private var _podiumIcon:Image;
		/**
		 * The tournament label */		
		private var _tournamentLabel:Label;
		
		// right column
		
		/**
		 * The right column */		
		private var _rightContainer:ScrollContainer;
		
		/**
		 * The position container */		
		private var _positionContainer:ScrollContainer;
		/**
		 * The position label */		
		private var _positionLabel:Label;
		
		/**
		 * The gift container */		
		private var _giftContainer:ScrollContainer;
		/**
		 * The actual gift */		
		private var _actualGiftLabel:Label;
		
		// buttons
		
		/**
		 * Buttons container */		
		protected var _buttonsContainer:ScrollContainer;
		/**
		 * Home button */		
		private var _homeButton:Button;
		/**
		 * Play again button */		
		private var _playAgainButton:Button;
		
		// particles
		
		/**
		 * The particles that follow the star */		
		private var _particles:PDParticleSystem;
		/**
		 * The particules used to highlight the logo */		
		private var _particlesLogo:PDParticleSystem;
		/**
		 * The mini "lueur" image */		
		private var _miniLueurImage:Image;
		
		/**
		 * The index used to retreive the current level */		
		private var _count:int = 0;
		/**
		 * The score to stars array */		
		private var _scoreToStarsArray:Array;
		/**
		 * The current level's data (inf, sup, etc.) */		
		private var _currentScoreToSarsData:ScoreToStarsData;
		
		public function TournamentEndScreen()
		{
			super();
			
			_fullScreen = true;
			_whiteBackground = false;
			_appBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			if( GlobalConfig.stageWidth > GlobalConfig.stageHeight )
			{
				Starling.current.nativeStage.addEventListener(flash.events.Event.RESIZE, onResize, false, int.MAX_VALUE, true);
				Starling.current.nativeStage.setAspectRatio(StageAspectRatio.PORTRAIT);
			}
			else
			{
				onResize();
			}
		}
		
		/**
		 * The application has finished resizing.
		 */		
		private function onResize(event:flash.events.Event = null):void
		{
			if( event )
			{
				Starling.current.nativeStage.removeEventListener(flash.events.Event.RESIZE, onResize, false);
				AlertManager.show( Localizer.getInstance().translate("COMMON.LOADING") );
				TweenMax.delayedCall(GlobalConfig.android ? 5:1, initContent);
			}
			else
			{
				initContent();
			}
		}
		
		private function initContent():void
		{
			AlertManager.hide("", ProgressPopup.SUCCESS_ICON_NOTHING, 0);
			
			_scoreToStarsArray = (Storage.getInstance().getProperty( StorageConfig.PROPERTY_STARS_TABLE ) as Array).concat();
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.gap = scaleToDpi(20);
			
			_mainContainer = new ScrollContainer();
			_mainContainer.layout = vlayout;
			_mainContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_mainContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild( _mainContainer );
			
			_title = new Label();
			_title.text = Localizer.getInstance().translate("TOURNAMENT_END.TITLE");; 
			_title.nameList.add( Theme.LABEL_GLOBAL_TITLE );
			_mainContainer.addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA_ONE, scaleAndRoundToDpi(40), Theme.COLOR_WHITE, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_logo = new Image( AbstractEntryPoint.assets.getTexture("LogoGame") );
			_logo.scaleX = _logo.scaleY = GlobalConfig.dpiScalez;
			_mainContainer.addChild( _logo );
			
			_resultsContainer = new ScrollContainer();
			_resultsContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_resultsContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_mainContainer.addChild(_resultsContainer);
			
			const hlayoutt:HorizontalLayout = new HorizontalLayout();
			hlayoutt.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			hlayoutt.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			hlayoutt.gap = scaleToDpi(10);
			hlayoutt.paddingBottom = hlayoutt.paddingTop = scaleToDpi(40);
			_resultsContainer.layout = hlayoutt;
			
			// left and right containers
			
			const columnLayout:VerticalLayout = new VerticalLayout();
			columnLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			columnLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			columnLayout.gap = scaleToDpi(10);
			
			_leftContainer = new ScrollContainer();
			_leftContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_leftContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_leftContainer.layout = columnLayout;
			_resultsContainer.addChild(_leftContainer);
			
			_rightContainer = new ScrollContainer();
			_rightContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_rightContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_rightContainer.layout = columnLayout;
			_resultsContainer.addChild(_rightContainer);
			
			// score and stars
			
			_scoreAndStarsContainer = new ScrollContainer();
			_scoreAndStarsContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_scoreAndStarsContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_scoreAndStarsContainer.nameList.add( Theme.SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_RIGHT );
			_leftContainer.addChild(_scoreAndStarsContainer);
			
			_scoreLabel = new Label();
			_scoreLabel.nameList.add( Theme.LABEL_GLOBAL_TITLE );
			_scoreLabel.text = "0";
			_scoreAndStarsContainer.addChild(_scoreLabel);
			
			const hlayoutStars:HorizontalLayout = new HorizontalLayout();
			hlayoutStars.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			hlayoutStars.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hlayoutStars.paddingTop = hlayoutStars.paddingBottom = scaleToDpi(5);
			hlayoutStars.gap = scaleToDpi(10);
			
			_firstRowStars = new ScrollContainer();
			_firstRowStars.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_firstRowStars.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_firstRowStars.layout = hlayoutStars;
			_scoreAndStarsContainer.addChild( _firstRowStars );
			
			_secondRowStars = new ScrollContainer();
			_secondRowStars.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_secondRowStars.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_secondRowStars.layout = hlayoutStars;
			_scoreAndStarsContainer.addChild( _secondRowStars );
			
			_thirdRowStars = new ScrollContainer();
			_thirdRowStars.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_thirdRowStars.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_thirdRowStars.layout = hlayoutStars;
			_scoreAndStarsContainer.addChild( _thirdRowStars );
			
			_starsArray = new Vector.<Image>();
			
			const starTexture:Texture = AbstractEntryPoint.assets.getTexture("TournamentEndStarShadow");
			var starShadow:Image;
			var i:int;
			
			for(i = 3; i > 0; i--)
			{
				starShadow = new Image( starTexture );
				starShadow.scaleX = starShadow.scaleY = GlobalConfig.dpiScalez;
				_firstRowStars.addChild( starShadow );
				_starsArray.push( starShadow );
			}
			
			for(i = 4; i > 0; i--)
			{
				starShadow = new Image( starTexture );
				starShadow.scaleX = starShadow.scaleY = GlobalConfig.dpiScalez;
				_secondRowStars.addChild( starShadow );
				_starsArray.push( starShadow );
			}
			
			for(i = 3; i > 0; i--)
			{
				starShadow = new Image( starTexture );
				starShadow.scaleX = starShadow.scaleY = GlobalConfig.dpiScalez;
				_thirdRowStars.addChild( starShadow );
				_starsArray.push( starShadow );
			}
			
			_starsArray.fixed = true;
			
			// position
			
			_positionContainer = new ScrollContainer();
			_positionContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_positionContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_positionContainer.nameList.add( Theme.SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_LEFT );
			_rightContainer.addChild(_positionContainer);
			
			_positionLabel = new Label();
			_positionLabel.nameList.add( Theme.LABEL_GLOBAL_TITLE );
			if( AirNetworkInfo.networkInfo.isConnected() )
				_positionLabel.text = Localizer.getInstance().translate("TOURNAMENT_END.POSITION_PREFIX") + this.advancedOwner.screenData.position + ( this.advancedOwner.screenData.position > 1 ? Localizer.getInstance().translate("TOURNAMENT_END.POSITION_SUFFIX_OTHER"):Localizer.getInstance().translate("TOURNAMENT_END.POSITION_SUFFIX_FIRST") );
			else
				_positionLabel.text = Localizer.getInstance().translate("TOURNAMENT_END.NOT_CONNECTED");
			_positionContainer.addChild( _positionLabel );
			
			// tournament button
			
			_tournamentContainer = new ScrollContainer();
			_tournamentContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_tournamentContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_tournamentContainer.nameList.add( Theme.SCROLL_CONTAINER_RESULT_DARK_CORNER_TOP_RIGHT );
			_leftContainer.addChild( _tournamentContainer );
			
			_podiumIcon = new Image( AbstractEntryPoint.assets.getTexture("TournamentPodiumIcon") );
			_podiumIcon.scaleX = _podiumIcon.scaleY = GlobalConfig.dpiScalez;
			_tournamentContainer.addChild( _podiumIcon );
			
			_tournamentLabel = new Label();
			_tournamentLabel.nameList.add( Theme.LABEL_GREY_CENTER );
			_tournamentLabel.text = Localizer.getInstance().translate("TOURNAMENT_END.FULL_RANKING");
			_tournamentContainer.addChild( _tournamentLabel );
			
			// gift
			
			_giftContainer = new ScrollContainer();
			_giftContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_giftContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_giftContainer.nameList.add( Theme.SCROLL_CONTAINER_RESULT_DARK_CORNER_TOP_LEFT );
			_rightContainer.addChild( _giftContainer );
			
			_actualGiftLabel = new Label();
			_actualGiftLabel.nameList.add( Theme.LABEL_GREY_CENTER );
			if( AirNetworkInfo.networkInfo.isConnected() )
				_actualGiftLabel.text = Localizer.getInstance().translate("TOURNAMENT_END.ACTUAL_GIFT") + this.advancedOwner.screenData.actualGift + 
					Localizer.getInstance().translate("TOURNAMENT_END.ACTUAL_GIFT_PREFIX") + this.advancedOwner.screenData.nextGiftStars + 
					Localizer.getInstance().translate("TOURNAMENT_END.ACTUAL_GIFT_SUFFIX") + this.advancedOwner.screenData.nextGift;
			else
				_actualGiftLabel.text = Localizer.getInstance().translate("TOURNAMENT_END.CONNECT_TO_KNOW_YOUT_RANK");
			_giftContainer.addChild( _actualGiftLabel );
			
			// buttons
			
			_buttonsContainer = new ScrollContainer();
			_buttonsContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_buttonsContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_mainContainer.addChild(_buttonsContainer);
			
			const hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hlayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			_buttonsContainer.layout = hlayout;
			
			_homeButton = new Button();
			_homeButton.nameList.add( Theme.BUTTON_BLUE_SQUARED_RIGHT );
			_homeButton.label = Localizer.getInstance().translate("FREE_GAME_END.HOME_BUTTON_LABEL");
			_homeButton.addEventListener(starling.events.Event.TRIGGERED, onGoHome);
			_buttonsContainer.addChild(_homeButton);
			
			_playAgainButton = new Button();
			_playAgainButton.nameList.add( Theme.BUTTON_YELLOW_SQUARED_LEFT );
			_playAgainButton.label = Localizer.getInstance().translate("FREE_GAME_END.PLAY_AGAIN_BUTTON_LABEL");
			_playAgainButton.addEventListener(starling.events.Event.TRIGGERED, onPlayAgain);
			_buttonsContainer.addChild(_playAgainButton);
			
			// particles
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( File.applicationDirectory.resolvePath( "particles/particle_star.pex" ), FileMode.READ );
			var onTouchParticlesXml:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.open( File.applicationDirectory.resolvePath( "particles/particle_star_logo.pex" ), FileMode.READ );
			var logoParticlesXml:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			fileStream = null;
			
			_particles = new PDParticleSystem(onTouchParticlesXml, AbstractEntryPoint.assets.getTexture("ParticleStar"));
			_particles.touchable = false;
			_particles.maxNumParticles = 300;
			//_particles.scaleX = _particles.scaleY = Config.dpiScale; // Provoque un décalage sur les tablettes surtout
			addChild(_particles);
			JugglerManager.getJuggler(JugglerManager.IN_GAME).add(_particles);
			
			_particlesLogo = new PDParticleSystem(logoParticlesXml, AbstractEntryPoint.assets.getTexture("ParticleStar"));
			_particlesLogo.touchable = false;
			_particlesLogo.maxNumParticles = 500;
			//_particles.scaleX = _particles.scaleY = Config.dpiScale; // Provoque un décalage sur les tablettes surtout
			addChild(_particlesLogo);
			JugglerManager.getJuggler(JugglerManager.IN_GAME).add(_particlesLogo);
			
			_miniLueurImage = new Image( AbstractEntryPoint.assets.getTexture("MiniLueur") );
			_miniLueurImage.scaleX = _miniLueurImage.scaleY = 0;
			_miniLueurImage.alpha = 0;
			_miniLueurImage.alignPivot();
			addChild( _miniLueurImage );
			
			invalidate();
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( !_mainContainer )
				return;
			
			_mainContainer.width = _title.width = _resultsContainer.width = _buttonsContainer.width = this.actualWidth * (GlobalConfig.isPhone ? 0.9:0.7);
			_mainContainer.height = this.actualHeight;
			_mainContainer.x = (this.actualWidth - _mainContainer.width) * 0.5;
			
			_scoreLabel.width = _scoreAndStarsContainer.width = _positionContainer.width = _firstRowStars.width
				= _secondRowStars.width = _thirdRowStars.width = _positionLabel.width = _leftContainer.width
				= _rightContainer.width = _tournamentContainer.width = _giftContainer.width = _actualGiftLabel.width
				= (_resultsContainer.width * 0.5) - scaleToDpi(5);
			
			_tournamentLabel.width = _tournamentContainer.width - _podiumIcon.width - _tournamentContainer.paddingLeft - _tournamentContainer.paddingRight;
			
			
			_homeButton.width = _playAgainButton.width = (_mainContainer.width * 0.5);
			
			_mainContainer.validate();
			
			_scoreLabel.alignPivot();
			_scoreLabel.x = _scoreLabel.width * 0.5 - _scoreAndStarsContainer.padding;
			_scoreLabel.y = _scoreLabel.height * 0.5;
			
			_giftContainer.height = _leftContainer.height - scaleToDpi(10 /* = columnLayout's gap */) - _positionContainer.height;
			
			var pt:Point = _mainContainer.localToGlobal( new Point(_logo.x, _logo.y) );
			_miniLueurImage.x = _particlesLogo.emitterX = _particles.emitterX = pt.x + _logo.width * 0.5;
			_miniLueurImage.y = _particlesLogo.emitterY = _particles.emitterY = pt.y + _logo.height * 0.5;
			_particlesLogo.emitterYVariance = _logo.height * 0.15;
			
			_currentScoreToSarsData = _scoreToStarsArray[_count];
			TweenMax.delayedCall(0.75, TextAnimationManager.addTextNumberAnimation, [_scoreLabel, this.advancedOwner.screenData.score, onScoreUpdate]);
		}
		
		override protected function onBack():void
		{
			this.advancedOwner.showScreen( AdvancedScreen.HOME_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		
		private function onScoreUpdate(currentScore:int):void
		{
			if( currentScore >= _currentScoreToSarsData.inf )
			{
				_particles.emitterX = _miniLueurImage.x;
				_particles.emitterY = _miniLueurImage.y;
				_particlesLogo.emitterXVariance = 0;
				
				var star:Image = new Image( AbstractEntryPoint.assets.getTexture("TournamentEndStar") );
				star.scaleX = star.scaleY = 1.7;
				star.x = _miniLueurImage.x;
				star.y = _miniLueurImage.y;
				star.alpha = 0;
				star.alignPivot();
				addChild( star );
				
				var starShadow:Image = _starsArray[_count];
				var globalPoint:Point;
				if( _count < 3 )
					globalPoint = _firstRowStars.localToGlobal( new Point(starShadow.x, starShadow.y) );
				else if( _count < 7 )
					globalPoint = _secondRowStars.localToGlobal( new Point(starShadow.x, starShadow.y) );
				else
					globalPoint = _thirdRowStars.localToGlobal( new Point(starShadow.x, starShadow.y) );
					
				globalPoint.x += starShadow.width * 0.5;
				globalPoint.y += starShadow.height * 0.5;
				
				TweenMax.to(_miniLueurImage, 2, { rotation:deg2rad(360), ease:Expo.easeOut });
				TweenMax.to(_miniLueurImage, 0.5, { scaleX:GlobalConfig.dpiScalez, scaleY:GlobalConfig.dpiScalez, alpha:0.7, ease:Expo.easeOut });
				TweenMax.to(_miniLueurImage, 0.5, { delay:0.75, scaleX:0, scaleY:0, alpha:0, ease:Expo.easeIn });
				
				TweenMax.to(star, 0.5, { delay:0.5, alpha:1, x:globalPoint.x, y:globalPoint.y, ease:Expo.easeIn });
				TweenMax.to(star, 0.75, { delay:1, scaleX:GlobalConfig.dpiScalez, scaleY:GlobalConfig.dpiScalez, ease:Bounce.easeOut });
				TweenMax.to(_particles, 0.5, { delay:0.5, emitterX:globalPoint.x, emitterY:globalPoint.y, ease:Expo.easeIn });
				TweenMax.delayedCall(1.25, Shaker.startShaking, [this, 6]);
				TweenMax.delayedCall(0.75, _particles.start, [0.5]);
				TweenMax.to(starShadow, 0, { delay:1.5, alpha:0 } );
				_particlesLogo.start(0.5);
				TweenMax.to(_particlesLogo, 0.5, { emitterXVariance:(_logo.width*0.5) });
				TweenMax.to(_scoreLabel, 0.15, { scaleX:1.4, scaleY:1.4, yoyo:true, repeat:1});
				
				_count++;
				_currentScoreToSarsData = _scoreToStarsArray[_count];
				
				star = null;
				starShadow = null;
			}
		}
		
		/**
		 * Go home.
		 */		
		private function onGoHome(event:starling.events.Event):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				this.advancedOwner.screenData.startScreenId = AdvancedScreen.HOME_SCREEN;
				this.advancedOwner.screenData.previousScreenId = AdvancedScreen.HOME_SCREEN;
				this.advancedOwner.showScreen( AdvancedScreen.HOME_SCREEN  );
			}
			else
			{
				this.advancedOwner.screenData.startScreenId = AdvancedScreen.HOME_SCREEN;
				this.advancedOwner.screenData.previousScreenId = AdvancedScreen.HOME_SCREEN;
				this.advancedOwner.screenData.completeScreenId = AdvancedScreen.HOME_SCREEN;
				NotificationManager.addNotification( new CreateAccountNotification(this.advancedOwner, AdvancedScreen.HOME_SCREEN) );
			}
		}
		
		/**
		 * Play again.
		 */		
		private function onPlayAgain(event:starling.events.Event):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				this.advancedOwner.screenData.startScreenId = AdvancedScreen.HOME_SCREEN;
				this.advancedOwner.screenData.previousScreenId = AdvancedScreen.HOME_SCREEN;
				this.advancedOwner.showScreen( AdvancedScreen.GAME_TYPE_SELECTION_SCREEN  );
			}
			else
			{
				this.advancedOwner.screenData.startScreenId = AdvancedScreen.HOME_SCREEN;
				this.advancedOwner.screenData.previousScreenId = AdvancedScreen.HOME_SCREEN;
				this.advancedOwner.screenData.completeScreenId = AdvancedScreen.GAME_SCREEN;
				NotificationManager.addNotification( new CreateAccountNotification(this.advancedOwner, MemberManager.getInstance().getNumFreeGameSessions() > 0 ? AdvancedScreen.GAME_SCREEN : AdvancedScreen.HOME_SCREEN) );
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			TextAnimationManager.stop();
			
			_title.removeFromParent(true);
			_title = null;
			
			_logo.removeFromParent(true);
			_logo = null;
			
			_scoreLabel.removeFromParent(true);
			_scoreLabel = null;
			
			var star:Image;
			_starsArray.fixed = false;
			for(var i:int = 0; i < 10; i++)
			{
				star = _starsArray.pop();
				star.removeFromParent(true);
				star = null;
			}
			star = null;
			_starsArray = null;
			
			_firstRowStars.removeFromParent(true);
			_firstRowStars = null;
			
			_secondRowStars.removeFromParent(true);
			_secondRowStars = null;
			
			_thirdRowStars.removeFromParent(true);
			_thirdRowStars = null;
			
			_podiumIcon.removeFromParent(true);
			_podiumIcon = null;
			
			_tournamentLabel.removeFromParent(true);
			_tournamentLabel = null;
			
			_tournamentContainer.removeFromParent(true);
			_tournamentContainer = null;
			
			_leftContainer.removeFromParent(true);
			_leftContainer = null;
			
			_positionLabel.removeFromParent(true);
			_positionLabel = null;
			
			_positionContainer.removeFromParent(true);
			_positionContainer = null;
			
			_actualGiftLabel.removeFromParent(true);
			_actualGiftLabel = null;
			
			_giftContainer.removeFromParent(true);
			_giftContainer = null;
			
			_rightContainer.removeFromParent(true);
			_rightContainer = null;
			
			_resultsContainer.removeFromParent(true);
			_resultsContainer = null;
			
			_homeButton.removeEventListener(starling.events.Event.TRIGGERED, onGoHome);
			_homeButton.removeFromParent(true);
			_homeButton = null;
			
			_playAgainButton.removeEventListener(starling.events.Event.TRIGGERED, onPlayAgain);
			_playAgainButton.removeFromParent(true);
			_playAgainButton = null;
			
			_buttonsContainer.removeFromParent(true);
			_buttonsContainer = null;
			
			_mainContainer.removeFromParent(true);
			_mainContainer = null;
			
			_miniLueurImage.removeFromParent(true);
			_miniLueurImage = null;
			
			JugglerManager.getJuggler(JugglerManager.IN_GAME).remove( _particles );
			_particles.stop(true);
			_particles.removeFromParent(true);
			_particles = null;
			
			JugglerManager.getJuggler(JugglerManager.IN_GAME).remove( _particlesLogo );
			_particlesLogo.stop(true);
			_particlesLogo.removeFromParent(true);
			_particlesLogo = null;
			
			// DO NOT set length to 0 or the reference will be nulled in the SharedObject (if the array is not concatened) !
			// here we can because _scoreToStarsArray is a copy
			_scoreToStarsArray.length = 0;
			_scoreToStarsArray = null;
			
			_currentScoreToSarsData = null;
			
			super.dispose();
		}
		
	}
}