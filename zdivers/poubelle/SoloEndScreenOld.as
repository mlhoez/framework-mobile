/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 20 juin 2013
*/
package com.ludofactory.mobile.navigation.engine
{
	
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.Shaker;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.model.GameData;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.model.StakeType;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
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
	import feathers.layout.HorizontalLayout;
	
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.utils.deg2rad;
	
	public class SoloEndScreenOld extends AdvancedScreen
	{
		/**
		 * The logo */		
		private var _logo:ImageLoader;
		
		/**
		 * COMMON : The game score. */		
		private var _scoreContainer:ScrollContainer;
		private var _scoreTitle:Label;
		private var _scoreValue:Label;
		private var _miniCoinImage:Image;
		private var _miniLueurImage:Image;
		
		/**
		 * COMMON : The earned points. */		
		private var _pointsContainer:ScrollContainer;
		private var _pointsTitle:Label;
		private var _pointsValue:Label;
		private var _miniScoreImage:Image;
		private var _winMorePointsImage:Image; // only when played with credits
		
		/**
		 * COMMON : Cumulated points container. */		
		private var _cumulatedPointsContainer:LayoutGroup;
		private var _cumulatedPointsTitle:Label;
		private var _cumulatedPointsValue:Label;
		private var _pointsIcon:Image;
		
		/**
		 * COMMON : The label that moves. */		
		private var _pointsToAddLabel:Label;
		
		/**
		 * The convert container when not logged in */		
		private var _convertContainer:ScrollContainer;
		private var _convertIcon:Image;
		private var _convertLabel:Label;
		private var _lockImage:Image; // when the tournament have been unlocked
		private var _lockLabel:Label; // when the tournament have been unlocked
		
		/**
		 * The convert elements when logged in. */		
		private var _convertShop:SoloEndElement;
		private var _convertTournament:SoloEndElement;
		
		// buttons
		
		/**
		 * Buttons container. */		
		private var _buttonsContainer:LayoutGroup;
		private var _continueButton:Button;	
		private var _homeButton:Button;
		private var _playAgainButton:Button;
		
		public var _oldTweenValue:int;
		public var _targetTweenValue:int;
		private var _elementsPositioned:Boolean = false;
		
		private var _glow:ImageLoader;
		
		/**
		 * Particles */		
		private var _particles:PDParticleSystem;
		
		public function SoloEndScreenOld()
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
		
		/**
		 * Initializes the screen content
		 */		
		private function initContent():void
		{
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
			
			_logo = new ImageLoader();
			_logo.source = Theme.gameLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			addChild(_logo);
			
		// score
			
			_scoreContainer = new ScrollContainer();
			_scoreContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_scoreContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_scoreContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_RIGHT;
			addChild(_scoreContainer);
			
			_scoreTitle = new Label();
			_scoreTitle.text = _("Score");
			_scoreContainer.addChild(_scoreTitle);
			_scoreTitle.textRendererProperties.textFormat = Theme.freeGameEndScreenContainerTitleTextFormat;
			
			_scoreValue = new Label();
			_scoreValue.text = "0";
			_scoreContainer.addChild(_scoreValue);
			_scoreValue.textRendererProperties.textFormat = Theme.freeGameEndScreenContainerTitleTextFormat;
			
			_miniLueurImage = new Image( AbstractEntryPoint.assets.getTexture("MiniLueur") );
			_miniLueurImage.scaleX = _miniLueurImage.scaleY = GlobalConfig.dpiScale + 0.2;
			addChild( _miniLueurImage );
			
			_miniScoreImage = new Image( AbstractEntryPoint.assets.getTexture("MiniScore") );
			_miniScoreImage.scaleX = _miniScoreImage.scaleY = GlobalConfig.dpiScale;
			addChild(_miniScoreImage);
			
		// points
			
			_pointsContainer = new ScrollContainer();
			_pointsContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_pointsContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_pointsContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_LEFT;
			addChild(_pointsContainer);
			
			_pointsTitle = new Label();
			_pointsTitle.text = _("Points");
			_pointsContainer.addChild(_pointsTitle);
			_pointsTitle.textRendererProperties.textFormat = Theme.freeGameEndScreenContainerTitleTextFormat;
			
			_pointsValue = new Label();
			_pointsValue.text = "0"; //Utility.splitThousands( this.advancedOwner.screenData.gameData.numStarsOrPointsEarned );
			_pointsContainer.addChild(_pointsValue);
			_pointsValue.textRendererProperties.textFormat = Theme.freeGameEndScreenContainerTitleTextFormat;
			
			_miniCoinImage = new Image( AbstractEntryPoint.assets.getTexture("MiniCoin") );
			_miniCoinImage.scaleX = _miniCoinImage.scaleY = GlobalConfig.dpiScale;
			addChild(_miniCoinImage);
			
		// cumulated points
			
			const hlayoutBase:HorizontalLayout = new HorizontalLayout();
			hlayoutBase.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hlayoutBase.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hlayoutBase.paddingTop = hlayoutBase.paddingBottom = scaleAndRoundToDpi(5);
			hlayoutBase.gap = scaleAndRoundToDpi(5);
			
			_cumulatedPointsContainer = new LayoutGroup();
			_cumulatedPointsContainer.layout = hlayoutBase;
			addChild(_cumulatedPointsContainer);
			
			_cumulatedPointsTitle = new Label();
			_cumulatedPointsTitle.text = _("Points cumulés : ");
			_cumulatedPointsContainer.addChild(_cumulatedPointsTitle);
			_cumulatedPointsTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 38 : 54), Theme.COLOR_WHITE);
			_cumulatedPointsTitle.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			_cumulatedPointsValue = new Label();
			_cumulatedPointsContainer.addChild(_cumulatedPointsValue);
			_cumulatedPointsValue.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 38 : 54), 0xffdf00);
			_cumulatedPointsValue.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			_cumulatedPointsValue.textRendererProperties.wordWrap = false;
			
			_pointsIcon = new Image( AbstractEntryPoint.assets.getTexture("MiniCoin") );
			_pointsIcon.scaleX = _pointsIcon.scaleY = GlobalConfig.dpiScale;
			_cumulatedPointsContainer.addChild(_pointsIcon);
			
			_pointsToAddLabel = new Label();
			_pointsToAddLabel.text = "+" + (advancedOwner.screenData.gameData.numStarsOrPointsEarned / ( advancedOwner.screenData.gamePrice == StakeType.CREDIT ? ((Storage.getInstance().getProperty(StorageConfig.PROPERTY_COEF) as Array)[MemberManager.getInstance().rank < 5 ? 0 : 1]) : 1 ));
			_pointsToAddLabel.alpha = 0;
			_pointsToAddLabel.visible = false;
			addChild(_pointsToAddLabel);
			_pointsToAddLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(80), 0xffdf00);
			_pointsToAddLabel.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			// Step 2 - Not logged in ----
			
			if( MemberManager.getInstance().isTournamentAnimPending )
			{
				_convertContainer = new ScrollContainer();
				_convertContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_convertContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				_convertContainer.alpha = 0;
				_convertContainer.visible = false;
				_convertContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_GREY;
				addChild(_convertContainer);
				_convertContainer.padding = 0;
				
				_lockLabel = new Label();
				_lockLabel.text = _("Tournoi débloqué !");
				_convertContainer.addChild( _lockLabel );
				_lockLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 72), Theme.COLOR_WHITE);
				_lockLabel.textRendererProperties.wordWrap = false;
				
				_glow = new ImageLoader();
				_glow.source = AbstractEntryPoint.assets.getTexture("HighScoreGlow");
				_glow.textureScale = GlobalConfig.dpiScale;
				_glow.includeInLayout = false;
				_convertContainer.addChild(_glow);
				
				_lockImage = new Image( AbstractEntryPoint.assets.getTexture("lock-big") );
				_lockImage.scaleX = _lockImage.scaleY = GlobalConfig.dpiScale;
				_convertContainer.addChild(_lockImage);
				
				_particles = new PDParticleSystem(Theme.particleSparklesXml, Theme.particleSparklesTexture);
				_particles.touchable = false;
				_particles.maxNumParticles = 250;
				//_particles.scaleX = _particles.scaleY = GlobalConfig.dpiScalez;
				addChild(_particles);
				Starling.juggler.add(_particles);
			}
			else
			{
				if( MemberManager.getInstance().isLoggedIn() )
				{
					// Logged in content
					
					_convertShop = new SoloEndElement("convert-shop-icon", (MemberManager.getInstance().getGiftsEnabled() ? (AbstractGameInfo.LANDSCAPE ? _("Convertir mes Points en Cadeaux dans la boutique"):_("Convertir mes Points en\nCadeaux dans la boutique")) : (AbstractGameInfo.LANDSCAPE ? _("Convertir mes Points en Crédits dans la boutique"):_("Convertir mes Points en\nCrédits dans la boutique"))) ) ;
					_convertShop.alpha = 0;
					_convertShop.visible = false;
					_convertShop.addEventListener(TouchEvent.TOUCH, onGoShop);
					addChild(_convertShop);
					
					_convertTournament = new SoloEndElement("convert-tournament-icon", (AbstractGameInfo.LANDSCAPE ? _("Utiliser mes Points sur le tournoi pour me classer"):_("Utiliser mes Points sur\nle tournoi pour me classer")));
					_convertTournament.alpha = 0;
					_convertTournament.visible = false;
					_convertTournament.addEventListener(TouchEvent.TOUCH, onGoTournament);
					addChild(_convertTournament);
				}
				else
				{
					// NOT logged in content
					
					_convertContainer = new ScrollContainer();
					_convertContainer.addEventListener(TouchEvent.TOUCH, onConvertInShop);
					_convertContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
					_convertContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
					_convertContainer.alpha = 0;
					_convertContainer.visible = false;
					_convertContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_GREY;
					addChild(_convertContainer);
					
					_convertIcon = new Image( AbstractEntryPoint.assets.getTexture("points-to-gift-icon") );
					_convertIcon.scaleX = _convertIcon.scaleY = GlobalConfig.dpiScale;
					_convertContainer.addChild(_convertIcon);
					
					_convertLabel = new Label();
					
					log("Number of anonymous game sessions : " + MemberManager.getInstance().getNumTokenUsedInAnonymousGameSessions());
					
					if(MemberManager.getInstance().getNumTokenUsedInAnonymousGameSessions() > StorageConfig.DEFAULT_NUM_TOKENS_ALLOWED_TO_COUNT_POINTS)
						_convertLabel.text = MemberManager.getInstance().getGiftsEnabled() ? _("Créez votre compte pour continuer à cumuler des Points à convertir en Cadeaux !") : _("Créez votre compte pour continuer à cumuler des Points à convertir en Crédits !");
					else
						_convertLabel.text = MemberManager.getInstance().getGiftsEnabled() ? _("Créez votre compte et convertissez\nvos Points en Cadeaux !") : _("Créez votre compte et convertissez\nvos Points en Crédits !");
					_convertContainer.addChild(_convertLabel);
					_convertLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 32 : 38), Theme.COLOR_WHITE, true, false, null, null, null, TextFormatAlign.CENTER);
				}
			}
			
			// Common part : buttons
			
			const buttonsLayout:HorizontalLayout = new HorizontalLayout();
			buttonsLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			buttonsLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			
			_buttonsContainer = new LayoutGroup();
			_buttonsContainer.clipContent = true;
			_buttonsContainer.layout = buttonsLayout;
			addChild(_buttonsContainer);
			
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
			
			if( advancedOwner.screenData.gamePrice == StakeType.CREDIT )
			{
				_winMorePointsImage = new Image( AbstractEntryPoint.assets.getTexture( "WinMorePoints" + (MemberManager.getInstance().rank < 5 ? "X5" : "X6") + LanguageManager.getInstance().lang ) );
				_winMorePointsImage.scaleX = _winMorePointsImage.scaleY = GlobalConfig.dpiScale;
				_winMorePointsImage.alignPivot();
				_winMorePointsImage.alpha = 0;
				addChild( _winMorePointsImage );
			}
			
			// FIXME A décommenter pour gérer l'orientation
			//invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		override protected function draw():void
		{
			// FIXME A décommenter pour gérer l'orientation
			if( isInvalid(INVALIDATION_FLAG_SIZE) /* && _logo */)
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
				
				_pointsToAddLabel.validate();
				_pointsToAddLabel.alignPivot();
				
				_buttonsContainer.width = _continueButton.width = _cumulatedPointsContainer.width = actualWidth * (GlobalConfig.isPhone ? 0.9 : 0.8);
				_buttonsContainer.validate();
				_buttonsContainer.x = (actualWidth - _buttonsContainer.width) * 0.5;
				_buttonsContainer.y = actualHeight - _buttonsContainer.height - scaleAndRoundToDpi(40);
				
				if( MemberManager.getInstance().isTournamentAnimPending )
				{
					_homeButton.width = _buttonsContainer.width;
					_playAgainButton.width = 0;
				}
				else
				{
					_homeButton.width = _playAgainButton.width = (_buttonsContainer.width * 0.5);
				}
				
				// calculate the maximum available height
				const maxElementsHeight:int = _buttonsContainer.y - _logo.y - _logo.height;
				
			// Step 1 --------------------------------------------------
				
				// score and poitns earned
				_scoreTitle.width = _scoreValue.width = _pointsTitle.width = _pointsValue.width = _scoreContainer.width = _pointsContainer.width = (_buttonsContainer.width * 0.5) - scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				
				// cumulated points
				_cumulatedPointsValue.text = String(MemberManager.getInstance().points) + "  ";
				_cumulatedPointsValue.validate();
				_cumulatedPointsValue.width = _cumulatedPointsValue.width;
				_cumulatedPointsValue.text = Utilities.splitThousands( (MemberManager.getInstance().points - advancedOwner.screenData.gameData.numStarsOrPointsEarned) );
				
				_scoreContainer.validate();
				_pointsContainer.validate();
				_pointsContainer.layout = null;
				_pointsContainer.height = _scoreContainer.height;
				_cumulatedPointsContainer.validate();
				
				_scoreContainer.x = (actualWidth * 0.5) - _scoreContainer.width - scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 10);
				_pointsContainer.x = (actualWidth * 0.5) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 5 : 10);
				_scoreContainer.y = _pointsContainer.y = (((_logo.y + _logo.height) + (maxElementsHeight - (_scoreContainer.height + _cumulatedPointsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80))) * 0.5)) << 0;
				
				if( _pointsValue.pivotX == 0 )
				{
					_pointsValue.validate();
					_pointsValue.alignPivot();
					_pointsValue.x = _pointsValue.width * 0.5;
					_pointsValue.y += _pointsValue.height * 0.5;
				}
				
				_cumulatedPointsContainer.x = (actualWidth - _cumulatedPointsContainer.width) * 0.5;
				_cumulatedPointsContainer.y = _scoreContainer.y + _scoreContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80);
				
				_miniCoinImage.alignPivot();
				_miniCoinImage.x = _pointsContainer.x + _pointsContainer.width - scaleAndRoundToDpi(10);
				_miniCoinImage.y = _pointsContainer.y;
				
				_miniScoreImage.alignPivot();
				_miniLueurImage.alignPivot();
				_miniScoreImage.x = _scoreContainer.x + scaleAndRoundToDpi(5);
				_miniScoreImage.y = _scoreContainer.y;
				_miniLueurImage.x = _scoreContainer.x + scaleAndRoundToDpi(10);
				_miniLueurImage.y = _scoreContainer.y + scaleAndRoundToDpi(15);
				
			// Step 2 --------------------------------------------------
				
				if( MemberManager.getInstance().isTournamentAnimPending )
				{
					_convertContainer.width = _buttonsContainer.width;
					_convertContainer.x = (actualWidth - _convertContainer.width) * 0.5;
					_convertContainer.validate();
					_convertContainer.height = _convertContainer.height;
					_convertContainer.layout = null;
					
					_lockImage.x = (_convertContainer.width - _lockImage.width) * 0.5;
					_lockImage.y = (_convertContainer.height - _lockImage.height) * 0.5;
					
					_lockLabel.validate();
					_lockLabel.x = (_convertContainer.width - _lockLabel.width) * 0.5;
					_lockLabel.y = (_convertContainer.height - _lockLabel.height) * 0.5;
					
					_glow.width = _convertContainer.width;
					_glow.height = _convertContainer.height;
					_glow.alignPivot();
					_glow.x = _convertContainer.width * 0.5;
					_glow.y = _convertContainer.height * 0.5 + scaleAndRoundToDpi(15);
					
					_cumulatedScoreContainerTargetY = (((_logo.y + _logo.height) + (maxElementsHeight - (_cumulatedPointsContainer.height + _convertContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80))) * 0.5)) << 0;
					_convertContainer.y = _cumulatedScoreContainerTargetY + _cumulatedPointsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80);
					
					_particles.emitterX = _convertContainer.x + (_convertContainer.width * 0.5);
					_particles.emitterY = _convertContainer.y + (_convertContainer.height * 0.5);
					_particles.emitterXVariance = _lockImage.width * 0.5;
					_particles.emitterYVariance = _lockImage.height * 0.5;
				}
				else
				{
					if( MemberManager.getInstance().isLoggedIn() )
					{
						_convertShop.width = _convertTournament.width = _buttonsContainer.width;
						_convertShop.x = _convertTournament.x = (actualWidth - _buttonsContainer.width) * 0.5;
						_convertShop.validate();
						
						_cumulatedScoreContainerTargetY = (((_logo.y + _logo.height) + (maxElementsHeight - (_cumulatedPointsContainer.height + _convertShop.height + _convertShop.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 60 : 140))) * 0.5)) << 0;
						_convertShop.y = _cumulatedScoreContainerTargetY + _cumulatedPointsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 70);
						_convertTournament.y = _convertShop.y + _convertShop.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 70);
					}
					else
					{
						_convertContainer.width = _convertLabel.width = _buttonsContainer.width;
						_convertContainer.x = (actualWidth - _convertContainer.width) * 0.5;
						_convertContainer.validate();
						
						_cumulatedScoreContainerTargetY = (((_logo.y + _logo.height) + (maxElementsHeight - (_cumulatedPointsContainer.height + _convertContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80))) * 0.5)) << 0;
						_convertContainer.y = _cumulatedScoreContainerTargetY + _cumulatedPointsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80);
					}
				}
				
				if( !_elementsPositioned )
				{
					_oldTweenValue = 0;
					_targetTweenValue = advancedOwner.screenData.gameData.score;
					if( _targetTweenValue == 0 )
						Starling.juggler.delayCall(animateLabelFromScoreToPoints, 1);
					else
						TweenMax.to(this, _targetTweenValue < 500 ? 1 : 2, { delay:0.5, _oldTweenValue : _targetTweenValue, onUpdate : function():void{ _scoreValue.text = Utilities.splitThousands(_oldTweenValue); }, onComplete:animateLabelFromScoreToPoints, ease:Expo.easeInOut } );
					TweenMax.to(_miniLueurImage, 10, { rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 } );
				}
				
				_elementsPositioned = true;
			}
			
			super.draw();
		}
		
		private var _cumulatedScoreContainerTargetY:int;
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the score is displayed, we need to animate a label from the score to
		 * the number of points earned.
		 */		
		private function animateLabelFromScoreToPoints():void
		{
			if( !_continueButton.isEnabled )
				return;
			
			_pointsToAddLabel.scaleX = _pointsToAddLabel.scaleY = 0;
			_pointsToAddLabel.x = _scoreContainer.x + _scoreContainer.width * 0.5;
			_pointsToAddLabel.y = _scoreContainer.y + _scoreContainer.height * 0.65;
			TweenMax.to(_pointsToAddLabel, 0.75, { autoAlpha:1, scaleX:1, scaleY:1 });
			TweenMax.to(_pointsToAddLabel, 0.75, { delay:0.75, x:(_pointsContainer.x + _pointsContainer.width * 0.5), y:(_pointsContainer.y + _pointsContainer.height * 0.65) });
			TweenMax.to(_pointsToAddLabel, 0.25, { delay:1.5, autoAlpha:0, onComplete:onAddLabelAnimatedFromScoreToPoints });
		}
		
		private function onAddLabelAnimatedFromScoreToPoints():void
		{
			if( _continueButton && !_continueButton.isEnabled )
				return;
			
			_oldTweenValue = 0;
			_targetTweenValue = (advancedOwner.screenData.gameData.numStarsOrPointsEarned / ( advancedOwner.screenData.gamePrice == StakeType.CREDIT ? ((Storage.getInstance().getProperty(StorageConfig.PROPERTY_COEF) as Array)[MemberManager.getInstance().rank < 5 ? 0 : 1]) : 1 ));
			TweenMax.to(this, 0.25, { _oldTweenValue : _targetTweenValue, onUpdate : function():void{ _pointsValue.text = Utilities.splitThousands(_oldTweenValue); }, onComplete:animateLabelFromPointsToCumulatedPoints, ease:Linear.easeNone } );
		}
		
		private var _step:int;
		
		private function animateLabelFromPointsToCumulatedPoints():void
		{
			if( !_continueButton.isEnabled )
				return;
			
			if( advancedOwner.screenData.gamePrice == StakeType.CREDIT )
			{
				_winMorePointsImage.x = _scoreContainer.x + _pointsContainer.x + _pointsContainer.width * 0.75;
				_winMorePointsImage.y = _scoreContainer.y;
				_winMorePointsImage.scaleX = _winMorePointsImage.scaleY = 0;
				TweenMax.to(_winMorePointsImage, 0.5, { delay:0.5, alpha:1, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, ease:Bounce.easeOut } );
				
				_step = advancedOwner.screenData.gameData.numStarsOrPointsEarned / (Storage.getInstance().getProperty(StorageConfig.PROPERTY_COEF) as Array)[MemberManager.getInstance().rank < 5 ? 0 : 1];
				_pointsValue.includeInLayout = false;
				animateBonus();
				
				// recup tab correspondance point
				// animer étape par étape puis passer à l'anim normale du else quand terminé
			}
			else
			{
				//_pointsToAddLabel.validate();
				//_pointsToAddLabel.alignPivot();
				test();
			}
		}
		
		private function test():void
		{
			if( !_continueButton.isEnabled )
				return;
			
			_pointsToAddLabel.text = "+" + advancedOwner.screenData.gameData.numStarsOrPointsEarned;
			_pointsToAddLabel.scaleX = _pointsToAddLabel.scaleY = 0;
			_pointsToAddLabel.x = _pointsContainer.x + _pointsContainer.width * 0.5;
			_pointsToAddLabel.y = _pointsContainer.y + _pointsContainer.height * 0.65;
			TweenMax.to(_pointsToAddLabel, 0.75, { autoAlpha:1, scaleX:1, scaleY:1 });
			TweenMax.to(_pointsToAddLabel, 0.75, { delay:0.75, x:(_cumulatedPointsContainer.x + _cumulatedPointsValue.x + _cumulatedPointsValue.width * 0.5), y:(_cumulatedPointsContainer.y + _cumulatedPointsContainer.height * 0.5) });
			
			TweenMax.to(_pointsToAddLabel, 0.25, { delay:1.5, autoAlpha:0 });
			TweenMax.delayedCall(1.75, onLabelAnimatedFromPointsToCumulatedPoints);
		}
		
		/**
		 * 
		 */		
		private function animateBonus():void
		{
			if( !_continueButton.isEnabled )
				return;
			
			var value:int = int(_pointsValue.text.split(" ").join(""));
			if( value == advancedOwner.screenData.gameData.numStarsOrPointsEarned )
			{
				test();
			}
			else
			{
				value += _step;
				_pointsValue.text = Utilities.splitThousands( value );
				TweenMax.to(_pointsValue, 0.25, { scaleX:(GlobalConfig.dpiScale + 0.2), scaleY:(GlobalConfig.dpiScale + 0.2), yoyo:true, repeat:1 } );
				TweenMax.delayedCall(0.5, animateBonus);
			}
		}
		
		/**
		 * When the earned points are displayed, we need to animate a label that
		 * will fly to the cumulated score label.
		 */		
		private function onLabelAnimatedFromPointsToCumulatedPoints():void
		{
			if( !_continueButton.isEnabled )
				return;
			
			_cumulatedPointsValue.text = Utilities.splitThousands( MemberManager.getInstance().points );
			TweenMax.delayedCall(0.5, onSkipAnimation);
		}
		
		/**
		 * The "Continue" button have been clicked, in this case we need to skip the first part of the animation.
		 */		
		private function onSkipAnimation(event:starling.events.Event = null):void
		{
			TweenMax.killDelayedCallsTo(onLabelAnimatedFromPointsToCumulatedPoints);
			TweenMax.killDelayedCallsTo(animateBonus);
			TweenMax.killDelayedCallsTo(onSkipAnimation);
			TweenMax.killTweensOf(_winMorePointsImage);
			TweenMax.killTweensOf(_pointsToAddLabel);
			TweenMax.killTweensOf(_pointsValue);
			TweenMax.killTweensOf(this);
			
			// display the final values (score, points and cumulated points)
			_scoreValue.text = Utilities.splitThousands( advancedOwner.screenData.gameData.score );
			_pointsValue.text = Utilities.splitThousands( advancedOwner.screenData.gameData.numStarsOrPointsEarned );
			_cumulatedPointsValue.text = Utilities.splitThousands( MemberManager.getInstance().points );
			
			// hide everything not needed for the next animation part
			TweenMax.allTo([_scoreContainer, _pointsContainer, _miniCoinImage, _miniLueurImage, _miniScoreImage, _pointsToAddLabel], 0.5, { autoAlpha:0 });
			if( _winMorePointsImage ) TweenMax.to(_winMorePointsImage, 0.5, { autoAlpha:0 });
			
			// move the cumulated points container up
			TweenMax.to(_cumulatedPointsContainer, 0.75, { y:_cumulatedScoreContainerTargetY });
			
			if( MemberManager.getInstance().isTournamentAnimPending )
			{
				// the tournament have been unloacked
				_homeButton.removeEventListener(starling.events.Event.TRIGGERED, onGoHome);
				const savedScaleX:Number = _glow.scaleX;
				const savedScaleY:Number = _glow.scaleY;
				_glow.scaleX = _glow.scaleY = 0;
				TweenMax.to(_glow, 0.5, { delay:0.75, autoAlpha:1, scaleX:savedScaleX, scaleY:savedScaleY, ease:Linear.easeNone });
				TweenMax.to(_glow, 8, { rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 });
				TweenMax.delayedCall(2, Shaker.startShaking, [_lockImage, 12]);
				Shaker.dispatcher.addEventListener(starling.events.Event.COMPLETE, onLockAnimComplete);
			}
			else
			{
				// the tournament have already been unlocked, so here we just need to fade in the containers
				if( MemberManager.getInstance().isLoggedIn() )
					TweenMax.allTo([_convertShop, _convertTournament], 0.5, { delay:0.5, autoAlpha:1 });
			}
			
			// if not logged in or if the tournament have been unlocked, we show the convert container
			if(!MemberManager.getInstance().isLoggedIn() || MemberManager.getInstance().isTournamentAnimPending)
				TweenMax.to(_convertContainer, 0.5, { delay:0.5, autoAlpha:1 });
			
			// disable and hide the continue button
			_continueButton.isEnabled = false;
			TweenMax.to(_continueButton, 0.5, { width:0, autoAlpha:0 });
		}
		
		/**
		 * When the unlock animation is complete, we shake the home button and activate it once the shaking
		 * is finished (to avoid a potential bug : shake on a null element).
		 */
		private function onLockAnimComplete(event:starling.events.Event):void
		{
			Shaker.dispatcher.removeEventListener(starling.events.Event.COMPLETE, onLockAnimComplete);
			_lockImage.texture = AbstractEntryPoint.assets.getTexture("unlock-big");
			TweenMax.allTo([_lockImage, _glow], 0.75, { delay:1, autoAlpha:0, onComplete:function():void
			{
				// shake the home button
				TweenMax.killTweensOf(_glow);
				Shaker.startShaking(_homeButton, 5);
				Shaker.dispatcher.addEventListener(starling.events.Event.COMPLETE, activateHome);
			} });
			_particles.start(0.25);
		}
		
		/**
		 * Once the shaking on the home button has finished, we enable it.
		 */
		private function activateHome(event:starling.events.Event):void
		{
			Shaker.dispatcher.removeEventListener(starling.events.Event.COMPLETE, activateHome);
			_homeButton.addEventListener(starling.events.Event.TRIGGERED, onGoHome);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Navigation handlers
		
		/**
		 * Go to home screen.
		 */		
		private function onGoHome(event:starling.events.Event):void
		{
			Flox.logEvent("Choix en fin de jeu solo", { Choix:"Accueil"} );
			
			advancedOwner.screenData.gameData = new GameData();
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_homeButton.isEnabled = false;
				_playAgainButton.isEnabled = false;
				advancedOwner.showScreen( ScreenIds.HOME_SCREEN );
			}
			else
			{
				if(MemberManager.getInstance().tokens == 0)
				{
					NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(ScreenIds.HOME_SCREEN) );
				}
				else
				{
					_homeButton.isEnabled = false;
					_playAgainButton.isEnabled = false;
					advancedOwner.showScreen( ScreenIds.HOME_SCREEN );
				}
			}
		}
		
		/**
		 * Play again.
		 */		
		private function onPlayAgain(event:starling.events.Event):void
		{
			Flox.logEvent("Choix en fin de jeu solo", { Choix:"Rejouer"} );
			
			advancedOwner.screenData.gameData = new GameData();
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackEvent("Fin mode solo", "Rejouer", null, NaN, MemberManager.getInstance().id);
				
				_homeButton.isEnabled = false;
				_playAgainButton.isEnabled = false;
				advancedOwner.showScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN  );
			}
			else
			{
				if(MemberManager.getInstance().tokens == 0)
				{
					NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(MemberManager.getInstance().tokens >= Storage.getInstance().getProperty(StorageConfig.NUM_TOKENS_IN_SOLO_MODE) ? ScreenIds.GAME_TYPE_SELECTION_SCREEN : ScreenIds.HOME_SCREEN) );
				}
				else
				{
					_homeButton.isEnabled = false;
					_playAgainButton.isEnabled = false;
					advancedOwner.showScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN  );
				}
			}
		}
		
		/**
		 * Go to the shop screen.
		 */
		private function onGoShop(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_convertShop);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackEvent("Fin mode solo", "Redirection boutique", null, NaN, MemberManager.getInstance().id);
				advancedOwner.showScreen( ScreenIds.BOUTIQUE_HOME );
			}
			touch = null;
		}
		
		/**
		 * Go to the tournament ranking screen.
		 */
		private function onGoTournament(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_convertTournament);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackEvent("Fin mode solo", "Redirection tournoi", null, NaN, MemberManager.getInstance().id);
				advancedOwner.showScreen( ScreenIds.TOURNAMENT_RANKING_SCREEN );
			}
			touch = null;
		}
		
		/**
		 * Go to the shop screen (when not logged in)
		 */
		private function onConvertInShop(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_convertContainer);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackEvent("Fin mode solo", "Redirection boutique (non connecté)", null, NaN, MemberManager.getInstance().id);
				advancedOwner.showScreen( ScreenIds.REGISTER_SCREEN );
			}
			touch = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_scoreValue.removeFromParent(true);
			_scoreValue = null;
			
			_scoreTitle.removeFromParent(true);
			_scoreTitle = null;
			
			_scoreContainer.removeFromParent(true);
			_scoreContainer = null;
			
			_pointsValue.removeFromParent(true);
			_pointsValue = null;
			
			_pointsTitle.removeFromParent(true);
			_pointsTitle = null;
			
			_pointsContainer.removeFromParent(true);
			_pointsContainer = null;
			
			_miniCoinImage.removeFromParent(true);
			_miniCoinImage = null;
			
			TweenMax.killTweensOf(_miniLueurImage);
			_miniLueurImage.removeFromParent(true);
			_miniLueurImage = null;
			
			_miniScoreImage.removeFromParent(true);
			_miniScoreImage = null;
			
			_pointsIcon.removeFromParent(true);
			_pointsIcon = null;
			
			_cumulatedPointsTitle.removeFromParent(true);
			_cumulatedPointsTitle = null;
			
			_cumulatedPointsValue.removeFromParent(true);
			_cumulatedPointsValue = null;
			
			_cumulatedPointsContainer.removeFromParent(true);
			_cumulatedPointsContainer = null;
			
			if( _lockImage )
			{
				_lockImage.removeFromParent(true);
				_lockImage = null;
			}
			
			if( _convertIcon )
			{
				_convertIcon.removeFromParent(true);
				_convertIcon = null;
			}
			
			if( _convertLabel )
			{
				_convertLabel.removeFromParent(true);
				_convertLabel = null;
			}
			
			if( _glow )
			{
				_glow.removeFromParent(true);
				_glow = null;
			}
			
			if( _particles )
			{
				Starling.juggler.remove( _particles );
				_particles.stop(true);
				_particles.removeFromParent(true);
				_particles = null;
			}
			
			if( _convertContainer )
			{
				_convertContainer.removeEventListener(TouchEvent.TOUCH, onConvertInShop);
				_convertContainer.removeFromParent(true);
				_convertContainer = null;
			}
			
			if( _convertShop )
			{
				_convertShop.removeEventListener(starling.events.Event.TRIGGERED, onGoShop);
				_convertShop.removeFromParent(true);
				_convertShop = null;
			}
			
			if( _convertTournament )
			{
				_convertTournament.removeEventListener(starling.events.Event.TRIGGERED, onGoTournament);
				_convertTournament.removeFromParent(true);
				_convertTournament = null;
			}
			
			_pointsToAddLabel.removeFromParent(true);
			_pointsToAddLabel = null;
			
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
			
			super.dispose();
		}
	}
}