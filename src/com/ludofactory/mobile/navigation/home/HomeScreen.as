/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 11 Avril 2013
*/
package com.ludofactory.mobile.navigation.home
{
	
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.achievements.GameCenterManager;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	
	import starling.display.Image;
	import starling.events.Event;
	
	/**
	 * The application's home screen.
	 */	
	public class HomeScreen extends AdvancedScreen
	{
		/**
		 * Game logo */		
		private var _logo:Image;
		
		/**
		 * Play button */		
		private var _playButton:Button;
		
		/**
		 * Game Center icon. */		
		private var _gameCenterIcon:ImageLoader;
		
		/**
		 * Game Center */		
		private var _gameCenterButton:Button;
		
		/**
		 * Gift button */		
		private var _giftsButton:Button;
		
		/**
		 * Temporary debug button. */		
		private var _debugButton:ArrowGroup;
		
		public function HomeScreen()
		{
			super();
			
			_appClearBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			advancedOwner.screenData.purgeData();
			
			_logo = new Image(Theme.gameLogoTexture);
			_logo.scaleX = _logo.scaleY = GlobalConfig.dpiScale;
			addChild(_logo);
			
			_playButton = new Button();
			_playButton.styleName = (GlobalConfig.ios && GameCenterManager.available) ? Theme.BUTTON_SPECIAL_SQUARED_RIGHT_BIGGER : Theme.BUTTON_SPECIAL_BIGGER;
			_playButton.label = _("JOUER");
			_playButton.addEventListener(Event.TRIGGERED, onPlay);
			addChild(_playButton);
			
			if( GlobalConfig.ios && GameCenterManager.available )
			{
				_gameCenterIcon = new ImageLoader();
				_gameCenterIcon.source = Theme.gameCenterTexture;
				_gameCenterIcon.snapToPixels = true;
				_gameCenterIcon.textureScale = GlobalConfig.dpiScale;
				
				_gameCenterButton = new Button();
				_gameCenterButton.defaultIcon = _gameCenterIcon;
				_gameCenterButton.styleName = Theme.BUTTON_SPECIAL_SQUARED_LEFT;
				_gameCenterButton.addEventListener(Event.TRIGGERED, onShowGameCenterAchievements);
				addChild(_gameCenterButton);
			}
			
			_giftsButton = new Button();
			_giftsButton.styleName = Theme.BUTTON_TRANSPARENT_WHITE;
			_giftsButton.label = MemberManager.getInstance().getGiftsEnabled() ? _("Gagner des cadeaux") : _("Gagner des crédits");
			_giftsButton.addEventListener(Event.TRIGGERED, onShowRules);
			addChild(_giftsButton);
			
			if( advancedOwner.screenData.displayPopupOnHome || (MemberManager.getInstance().getTournamentUnlocked() && MemberManager.getInstance().getTournamentAnimPending()) )
			{
				if( AbstractEntryPoint.gameTypeSelectionManager )
				{
					Flox.logInfo("<strong>&rarr; Affichage du choix du mode de jeu (auto)</strong>");
					advancedOwner.screenData.displayPopupOnHome = false;
					if( (MemberManager.getInstance().getTournamentUnlocked() && MemberManager.getInstance().getTournamentAnimPending()) )
						AbstractEntryPoint.gameTypeSelectionManager.show( false );
					else
						AbstractEntryPoint.gameTypeSelectionManager.show( true );
				}
			}
			
			if( GlobalConfig.DEBUG )
			{
				_debugButton = new ArrowGroup("Debug");
				_debugButton.addEventListener(Event.TRIGGERED, onShowDebugScreen);
				addChild(_debugButton);
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) && !_logoPlaced )
			{
				// EN PAYSAGE
				// 1 actualHeight - taille cumulée des boutons + gap + padding top et bottom
				// 2 getScaleToFillHeight pour adapter le logo
				// sur tablette on limite la taille (au début en faisant actualHeight * X)
				
				// EN PORTRAIT
				// 1 actualHeight * un scale à définir - taille cumulée des boutons + gap + padding top et bottom
				// 2 getScaleToFillHeight pour adapter le logo
				// sur tablette on limite la taille (au début en faisant actualHeight * X)
				
				/*if( AbstractGameInfo.LANDSCAPE )
				{*/
				
				var hheight:int = GlobalConfig.stageHeight - scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 88 : 118);
						
				var maxScaleWidth:Number = AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 0.6 : 0.6) : (GlobalConfig.isPhone ? 0.8 : 0.6);
				
					var gap:int = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 30);
					var padding:int = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 30);
				
				var buttonHeight:int = scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 118 : 148) : 128);
					
					_giftsButton.validate();
					var logoMaxHeight:int = hheight - (buttonHeight + _giftsButton.height + (padding * 2) + (gap * 2));
				
					
					_logo.scaleX = _logo.scaleY = Utilities.getScaleToFillHeight(_logo.height, logoMaxHeight);
					if( _logo.width > (actualWidth * maxScaleWidth) )
					{
						_logo.scaleX = _logo.scaleY = 1;
						_logo.scaleX = _logo.scaleY = Utilities.getScaleToFillWidth(_logo.width, (actualWidth * maxScaleWidth));
					}
					
					_logo.x = roundUp((actualWidth - _logo.width) * 0.5);
					_logo.y = roundUp(padding + (hheight - (_logo.height + scaleAndRoundToDpi(118) + _giftsButton.height + (padding * 2) +(gap * 2))) * 0.5);
					
				if( _gameCenterButton )
					_gameCenterButton.validate();
				
					_playButton.width = _logo.width * (GlobalConfig.isPhone ? 0.9 : 0.8) - ((GlobalConfig.ios && GameCenterManager.available) ? _gameCenterButton.width : 0 );
					_playButton.x = roundUp((actualWidth - _playButton.width - ((GlobalConfig.ios && GameCenterManager.available) ? _gameCenterButton.width : 0 )) * 0.5);
					_playButton.y = _logo.y + _logo.height + gap;
					_playButton.height = buttonHeight;
					//_playButton.validate();
				
				if( GlobalConfig.ios && GameCenterManager.available )
				{
					//_playButton.x -= _gameCenterButton.width;
					_gameCenterButton.height = buttonHeight;
					_gameCenterButton.x = _playButton.x + _playButton.width;
					_gameCenterButton.y = _playButton.y;
				}
				
					_giftsButton.width = _logo.width * (GlobalConfig.isPhone ? 0.8 : 0.7);
					_giftsButton.x = roundUp((actualWidth - _giftsButton.width) * 0.5);
					_giftsButton.y = _playButton.y + _playButton.height + gap;
				
				_logoPlaced = true;
				
				/*}
				else
				{
					
				}*/
				
				/*if( AbstractGameInfo.LANDSCAPE )
				{
					_logo.height = actualHeight * 0.5;
					_logo.validate();
					
					if( GlobalConfig.ios && GameCenterManager.available )
					{
						_gameCenterButton.height = _playButton.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 108 : 118);
						_gameCenterButton.validate();
						_gameCenterButton.y = _playButton.y = actualHeight * 0.45 + scaleAndRoundToDpi(30);
						
						_playButton.width = _logo.width * (GlobalConfig.isPhone ? 0.8 : 0.7) - _gameCenterButton.width;
						_playButton.x = (actualWidth - (_playButton.width + _gameCenterButton.width)) * 0.5;
						_gameCenterButton.x = _playButton.x + _playButton.width;
					}
					else
					{
						_playButton.width = _logo.width * (GlobalConfig.isPhone ? 0.8 : 0.7);
						_playButton.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 108 : 118);
						_playButton.x = (actualWidth - _playButton.width) * 0.5;
						_playButton.y = actualHeight * 0.45 + scaleAndRoundToDpi(30);
					}
					
					_giftsButton.width = _logo.width * (GlobalConfig.isPhone ? 0.7 : 0.6);
					_giftsButton.x = (actualWidth - _giftsButton.width) * 0.5;
					
					//_logo.height = actualHeight - _playButton.height - _giftsButton.height - scaleAndRoundToDpi(60);
					_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
					_logo.y = (_playButton.y - _logo.height) * 0.5;
					
					_giftsButton.y = _playButton.y + _playButton.height + scaleAndRoundToDpi(20);
				}
				else
				{
					_logo.width = actualWidth * (GlobalConfig.isPhone ? GlobalConfig.homeScreenLogoScaleWidthPhone : GlobalConfig.homeScreenLogoScaleWidthTablet);
					_logo.validate();
					// header height + padding, then centered
					_logo.y = scaleAndRoundToDpi(60) + (((actualHeight * 0.5) - scaleAndRoundToDpi(60)) - _logo.height) << 0;
					_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
					
					if( GlobalConfig.ios && GameCenterManager.available )
					{
						_gameCenterButton.height = _playButton.height = scaleAndRoundToDpi(118);
						_gameCenterButton.validate();
						_gameCenterButton.y = _playButton.y = actualHeight * 0.5 + scaleAndRoundToDpi(40);
						
						_playButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6) - _gameCenterButton.width;
						_playButton.x = (actualWidth - (_playButton.width + _gameCenterButton.width)) * 0.5;
						_gameCenterButton.x = _playButton.x + _playButton.width;
					}
					else
					{
						_playButton.width = actualWidth * (GlobalConfig.isPhone ? 0.7 : 0.6);
						_playButton.height = scaleAndRoundToDpi(118);
						_playButton.x = (actualWidth - _playButton.width) * 0.5;
						_playButton.y = actualHeight * 0.5 + scaleAndRoundToDpi(40);
					}
					
					_giftsButton.y = _playButton.y + _playButton.height + scaleAndRoundToDpi(40);
					_giftsButton.width = actualWidth * (GlobalConfig.isPhone ? ( GameCenterManager.available ? 0.7 : 0.6) : 0.5);
					_giftsButton.x = (actualWidth - _giftsButton.width) * 0.5;
				}*/

				if( GlobalConfig.DEBUG )
				{
					_debugButton.validate();
					_debugButton.x = actualWidth - _debugButton.width - scaleAndRoundToDpi(5);
					_debugButton.y = hheight - _debugButton.height;
				}
			}
		}
		
		private var _logoPlaced:Boolean = false;
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Play. Displays the game mode selection popup.
		 */		
		private function onPlay(event:Event):void
		{
			Flox.logInfo("<strong>&rarr; Affichage du choix du mode de jeu</strong>");
			AbstractEntryPoint.gameTypeSelectionManager.show();
		}
		
		/**
		 * Show rules.
		 */		
		private function onShowRules(event:Event):void
		{
			this.advancedOwner.showScreen( MemberManager.getInstance().getGiftsEnabled() ? ScreenIds.HOW_TO_WIN_GIFTS_SCREEN : ScreenIds.BOUTIQUE_HOME );
		}
		
		private function onShowDebugScreen(event:Event):void
		{
			advancedOwner.showScreen(ScreenIds.DEBUG_SCREEN);
		}
		
		/**
		 * Shows the Game Center achievements.
		 */		
		private function onShowGameCenterAchievements(event:Event):void
		{
			if( GameCenterManager.available )
			{
				GameCenterManager.dispatcher.addEventListener(LudoEventType.GAME_CENTER_AUTHENTICATION_SUCCESS, onGameCenterAuthenticationFinished);
				GameCenterManager.authenticateUser();
			}
		}
		
		/**
		 * Authentication ok, we can show the achievements.
		 */		
		private function onGameCenterAuthenticationFinished(event:Event):void
		{
			GameCenterManager.dispatcher.removeEventListener(LudoEventType.GAME_CENTER_AUTHENTICATION_SUCCESS, onGameCenterAuthenticationFinished);
			GameCenterManager.showAchievements();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_playButton.removeEventListener(Event.TRIGGERED, onPlay);
			_playButton.removeFromParent(true);
			_playButton = null;
			
			_giftsButton.removeEventListener(Event.TRIGGERED, onShowRules);
			_giftsButton.removeFromParent(true);
			_giftsButton = null;
			
			if( GlobalConfig.ios && GameCenterManager.available )
			{
				_gameCenterIcon.removeFromParent(true);
				_gameCenterIcon = null;
				
				_gameCenterButton.removeEventListener(Event.TRIGGERED, onShowGameCenterAchievements);
				_gameCenterButton.removeFromParent(true);
				_gameCenterButton = null;
			}
			
			if( GlobalConfig.DEBUG )
			{
				_debugButton.removeEventListener(Event.TRIGGERED, onShowDebugScreen);
				_debugButton.removeFromParent(true);
				_debugButton = null;
			}
			
			super.dispose();
		}
	}
}