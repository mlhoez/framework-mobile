/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 11 Avril 2013
*/
package com.ludofactory.mobile.core.test.home
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.achievements.GameCenterManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	
	import starling.events.Event;
	
	/**
	 * The application's home screen.
	 */	
	public class HomeScreen extends AdvancedScreen
	{
		/**
		 * Game logo */		
		private var _logo:ImageLoader;
		
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
			
			_logo = new ImageLoader();
			_logo.source = Theme.gameLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			addChild(_logo);
			
			_playButton = new Button();
			_playButton.nameList.add( (GlobalConfig.ios && GameCenterManager.available) ? Theme.BUTTON_SPECIAL_SQUARED_RIGHT_BIGGER : Theme.BUTTON_SPECIAL_BIGGER );
			_playButton.label = Localizer.getInstance().translate("HOME.PLAY_BUTTON_LABEL");
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
				_gameCenterButton.nameList.add( Theme.BUTTON_SPECIAL_SQUARED_LEFT );
				_gameCenterButton.addEventListener(Event.TRIGGERED, onShowGameCenterAchievements);
				addChild(_gameCenterButton);
			}
			
			_giftsButton = new Button();
			_giftsButton.nameList.add( Theme.BUTTON_TRANSPARENT_WHITE );
			_giftsButton.label = Localizer.getInstance().translate("HOME.WIN_GIFTS_BUTTON_LABEL");
			_giftsButton.addEventListener(Event.TRIGGERED, onShowRules);
			_giftsButton.visible = Storage.getInstance().getProperty(StorageConfig.PROPERTY_DISPLAY_HOW_TO_WIN_GIFTS_SCREEN);
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
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
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
				
				if( GlobalConfig.DEBUG )
				{
					_debugButton.validate();
					_debugButton.x = (actualWidth - _debugButton.width) * 0.5;
					_debugButton.y = actualHeight - _debugButton.height - scaleAndRoundToDpi(10);
				}
			}
		}
		
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
			this.advancedOwner.showScreen( Storage.getInstance().getProperty(StorageConfig.PROPERTY_DISPLAY_HOW_TO_WIN_GIFTS_SCREEN) ? ScreenIds.HOW_TO_WIN_GIFTS_SCREEN : ScreenIds.MY_GIFTS_SCREEN );
		}
		
		/**
		 * When the storage has finished initializing, this function is called in
		 * order to update the screen (if we need to add / remove the button "Win
		 * gifts" for example).
		 */		
		public function updateInterface():void
		{
			_giftsButton.visible = Storage.getInstance().getProperty(StorageConfig.PROPERTY_DISPLAY_HOW_TO_WIN_GIFTS_SCREEN);
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