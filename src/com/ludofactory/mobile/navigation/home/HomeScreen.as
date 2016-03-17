/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
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
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManager;
	import com.ludofactory.mobile.navigation.FacebookManagerEventType;

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
		private var _playButton:MobileButton;
		/**
		 * Facebookconnect button. */
		private var _facebookButton:FacebookButton;
		
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
			
			_playButton = ButtonFactory.getButton(_("JOUER"), ButtonFactory.SPECIAL);
			_playButton.addEventListener(Event.TRIGGERED, onPlay);
			addChild(_playButton);
			
			if(FacebookManager.getInstance().canDisplayFacebookConnectButton())
			{
				_facebookButton = ButtonFactory.getFacebookButton(_("Facebook"), ButtonFactory.FACEBOOK_TYPE_CONNECT);
				_facebookButton.addEventListener(FacebookManagerEventType.AUTHENTICATED, onAuthenticatedWithFacebook);
				addChild(_facebookButton);
			}
			
			if( advancedOwner.screenData.displayPopupOnHome || (MemberManager.getInstance().isTournamentUnlocked && MemberManager.getInstance().isTournamentAnimPending) )
			{
				if( AbstractEntryPoint.gameTypeSelectionManager )
				{
					Flox.logInfo("<strong>&rarr; Affichage du choix du mode de jeu (auto)</strong>");
					advancedOwner.screenData.displayPopupOnHome = false;
					if( (MemberManager.getInstance().isTournamentUnlocked && MemberManager.getInstance().isTournamentAnimPending) )
						AbstractEntryPoint.gameTypeSelectionManager.show( false );
					else
						AbstractEntryPoint.gameTypeSelectionManager.show( true );
				}
			}
			
			if( MemberManager.getInstance().isAdmin() )
			{
				_debugButton = new ArrowGroup("Debug");
				_debugButton.addEventListener(Event.TRIGGERED, onShowDebugScreen);
				addChild(_debugButton);
			}
		}
		
		override protected function draw():void
		{
			if (isInvalid(INVALIDATION_FLAG_SIZE))
			{
				var padding:int;
				var buttonHeight:int = scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 118 : 138) : 128);
				var gap:int = scaleAndRoundToDpi(GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 10 : 50) : (AbstractGameInfo.LANDSCAPE ? 30 : 80));
				
				// 1) scale the logo
				if(AbstractGameInfo.LANDSCAPE)
				{
					padding = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 40);
					var maxLogoHeight:int = actualHeight - (padding * 2) - buttonHeight - (gap * 2);
					var maxLogoScale:Number = (GlobalConfig.isPhone ? 0.6 : 0.45);
					_logo.scaleX = _logo.scaleY = 1;
					_logo.scaleX = _logo.scaleY = Utilities.getScaleToFillHeight(_logo.height, maxLogoHeight);
					if (_logo.height > (actualHeight * maxLogoScale))
					{
						_logo.scaleX = _logo.scaleY = 1;
						_logo.scaleX = _logo.scaleY = Utilities.getScaleToFillHeight(_logo.height, (actualHeight * maxLogoScale));
					}
				}
				else
				{
					padding = scaleAndRoundToDpi(GlobalConfig.isPhone ? 60 : 100);
					var maxLogoWidth:int = actualWidth - (padding * 2);
					var maxLogoScaleW:Number = (GlobalConfig.isPhone ? 0.6 : 0.45); 
					// scale the logo to fit in maxLogoWidth
					_logo.scaleX = _logo.scaleY = 1;
					_logo.scaleX = _logo.scaleY = Utilities.getScaleToFillWidth(_logo.width, maxLogoWidth);
					// if the scaled logo becomes to big (in height), we need to scale it down to the maximum height
					if (_logo.height > (actualHeight * maxLogoScaleW))
					{
						_logo.scaleX = _logo.scaleY = 1;
						_logo.scaleX = _logo.scaleY = Utilities.getScaleToFillHeight(_logo.height, (actualHeight * maxLogoScaleW));
					}
				}
				
				// 2) place the elements
				_logo.x = roundUp((actualWidth - _logo.width) * 0.5);
				_logo.y = padding + (actualHeight - (padding * 2) - buttonHeight - _logo.height - (gap * 2)) * 0.5;
				
				var buttonWidth:int = 0;
				var minWidth:int = scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 375 : 800) : (GlobalConfig.isPhone ? 375 : 800));
				if(minWidth > _logo.width * (GlobalConfig.isPhone ? 0.9:0.8))
					buttonWidth = (_logo.width * (GlobalConfig.isPhone ? 0.9:0.8));
				else
					buttonWidth = scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 375 : 800) : (GlobalConfig.isPhone ? 375 : 800));

				if(_facebookButton)
				{
					_facebookButton.height = buttonHeight;
					_facebookButton.width = buttonWidth;
				}
				
				_playButton.width = buttonWidth;
				_playButton.x = roundUp((actualWidth - _playButton.width - (_facebookButton ? _facebookButton.width : 0)) * 0.5);
				_playButton.y = _logo.y + _logo.height + gap;
				_playButton.height = buttonHeight;
				
				if(_facebookButton)
				{
					_facebookButton.x = _playButton.x + _playButton.width + scaleAndRoundToDpi(20);
					_facebookButton.y = _logo.y + _logo.height + gap;
				}
				
				if (_debugButton)
				{
					_debugButton.x = actualWidth - _debugButton.width - scaleAndRoundToDpi(5);
					_debugButton.y = actualHeight - _debugButton.height;
				}
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Play. Displays the game mode selection popup.
		 */		
		private function onPlay(event:Event):void
		{
			Flox.logInfo("<strong>&rarr; Affichage du choix du mode de jeu</strong>");
			//AbstractEntryPoint.gameTypeSelectionManager.show();
			advancedOwner.showScreen(ScreenIds.AVATAR_HOME_SCREEN);
		}
		
		private function onShowDebugScreen(event:Event):void
		{
			advancedOwner.showScreen(ScreenIds.DEBUG_SCREEN);
		}
		
		/**
		 * Facebook authentication.
		 */
		private function onAuthenticatedWithFacebook(event:Event):void
		{
			if(_facebookButton)
			{
				_facebookButton.removeEventListener(FacebookManagerEventType.AUTHENTICATED, onAuthenticatedWithFacebook);
				_facebookButton.removeFromParent(true);
				_facebookButton = null;
			}
			
			// layout again
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		public function onUserDisconnected():void
		{
			if(!_facebookButton)
			{
				_facebookButton = ButtonFactory.getFacebookButton(_("Facebook"), ButtonFactory.FACEBOOK_TYPE_CONNECT);
				_facebookButton.addEventListener(FacebookManagerEventType.AUTHENTICATED, onAuthenticatedWithFacebook);
				addChild(_facebookButton);
			}

			// layout again
			invalidate(INVALIDATION_FLAG_SIZE);
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
			
			if(_facebookButton)
			{
				_facebookButton.removeEventListener(FacebookManagerEventType.AUTHENTICATED, onAuthenticatedWithFacebook);
				_facebookButton.removeFromParent(true);
				_facebookButton = null;
			}
			
			if( _debugButton )
			{
				_debugButton.removeEventListener(Event.TRIGGERED, onShowDebugScreen);
				_debugButton.removeFromParent(true);
				_debugButton = null;
			}
			
			super.dispose();
		}
	}
}