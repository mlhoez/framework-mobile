/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.core
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.pause.PauseManager;
	import com.ludofactory.mobile.core.push.GameSession;
	import com.ludofactory.mobile.core.push.PushType;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.navigation.achievements.GameCenterManager;
	import com.ludofactory.mobile.navigation.achievements.TrophyManager;
	import com.ludofactory.mobile.navigation.ads.AdManager;
	import com.milkmangames.nativeextensions.ios.IAdBannerAlignment;
	
	import flash.filesystem.File;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	
	/**
	 * AbstractGame
	 */	
	public class AbstractGame extends AdvancedScreen implements IGame
	{
		/**
		 * The game session. */		
		private var _gameSession:GameSession;
		
		/**
		 * The transparent black overlay. */
		protected var _playOverlay:Image;
		/**
		 * Loader */		
		private var _loader:MovieClip;
		
		/**
		 * The play button displayed at the begining of a game session. */		
		protected var _playButton:MobileButton;
		
		/**
		 * Whether the player gave up this game session. */		
		private var _gaveUp:Boolean;
		/**
		 * Whether the screen is validating. This is added for security reason in order to avoid multiple validations. */		
		private var _isValidatingGame:Boolean = false;
		
		private var _nextScreenId:String;
		
		public function AbstractGame()
		{
			super();
			
			_canBack = false;
			_gaveUp = false;
		}
		
		/**
		 * Initializes the core data of a game session.
		 */
		override protected function initialize():void
		{
			super.initialize();
			
			// create banners in order to display them faster when the game is paused
			AdManager.createiAdBanner(IAdBannerAlignment.BOTTOM);
			AdManager.crateAdMobBanner();
			
			// disable the push manager while playing
			AbstractEntryPoint.pushManager.isEnabled = false;
			
			// create the game session data, link it to the TrophyManager and add it to the PushManager in case
			// the user quits the game while playing
			_gameSession = new GameSession(PushType.GAME_SESSION, advancedOwner.screenData.gameType);
			TrophyManager.getInstance().currentGameSession = _gameSession;
			AbstractEntryPoint.pushManager.addElementToPush(_gameSession);
			
			// ----- finally initialze the game by loading all the assets
			
			_loader = new MovieClip(AbstractEntryPoint.assets.getTextures("Loader")); // TODO a stocker en constante dans le theme car sera récupéré souvent
			_loader.scale = GlobalConfig.dpiScale;
			_loader.x = (GlobalConfig.stageWidth - _loader.width) * 0.5;
			_loader.y = (GlobalConfig.stageHeight - _loader.height) * 0.5;
			Starling.juggler.add(_loader);
			addChild(_loader);
			
			// load the main atlas
			var path:File = File.applicationDirectory.resolvePath( GlobalConfig.isPhone ? "assets/game/sd/" : "assets/game/hd/");
			AbstractEntryPoint.assets.enqueue( path.url + "/game.png" );
			AbstractEntryPoint.assets.enqueue( path.url + "/game.xml" );
			
			// load common assets if found
			path = File.applicationDirectory.resolvePath("assets/game/common/");
			if(path.exists)
				AbstractEntryPoint.assets.enqueue(path);
			
			// load tutorial elements if necessary
			if(MemberManager.getInstance().getDisplayTutorial())
			{
				path = File.applicationDirectory.resolvePath("assets/game/tutorial/");
				if(path.exists)
					AbstractEntryPoint.assets.enqueue(path);
			}
			path = null;
			
			// load !
			AbstractEntryPoint.assets.loadQueue( function onLoading(ratio:Number):void{ if(ratio == 1) initializeContent(); });
		}
		
		/**
		 * @inheritDoc
		 */		
		public function initializeContent():void
		{
			// initialize sounds
			initializeSounds();
			
			Starling.juggler.remove(_loader);
			_loader.removeFromParent(true);
			_loader = null;
			
			// create the overlay and play button
			_playOverlay = new Image(AbstractEntryPoint.assets.getTexture("overlay-skin"));
			_playOverlay.width = GlobalConfig.stageWidth;
			_playOverlay.height = GlobalConfig.stageHeight;
			addChild(_playOverlay);
			
			_playButton = ButtonFactory.getButton(_("Commencer"), ButtonFactory.SPECIAL);
			_playButton.x = (GlobalConfig.stageWidth - _playButton.width) * 0.5;
			_playButton.y = (GlobalConfig.stageHeight - _playButton.height) * 0.5;
			_playButton.addEventListener(Event.TRIGGERED, onPlay);
			addChild(_playButton);
			
			// enable the pause view and listeners
			PauseManager.dispatcher.addEventListener(MobileEventTypes.EXIT, giveUp);
			PauseManager.dispatcher.addEventListener(MobileEventTypes.RESUME, resume);
		}
		
		/**
		 * @inheritDoc
		 */
		public function initializeSounds():void
		{
			// to override in GameScreen
		}
		
		
		/**
		 * The user touched the play button.
		 * 
		 * <p>Here we remove the overlay and the play button, then we call the startLevel function
		 * which is overridden in the subclass.</p>
		 */		
		protected function onPlay(event:Event):void
		{
			// truly playing when the play button have been touched, not before !
			PauseManager.isPlaying = true;
			
			_playOverlay.removeFromParent(true);
			_playOverlay = null;
			
			_playButton.removeEventListener(Event.TRIGGERED, onPlay);
			_playButton.removeFromParent(true);
			_playButton = null;
			
			startLevel();
		}
		
		/**
		 * @inheritDoc
		 */		
		public function startLevel():void
		{
			// to override in GameScreen
		}
		
		/**
		 * @inheritDoc
		 */		
		public function giveUp(event:Event):void
		{
			if(!_gaveUp) // avoid multiple calls by securité
			{
				_gaveUp = true;
				PauseManager.isPlaying = false;
				onGaveUp();
			}
		}
		
		public function onGaveUp():void
		{
			throw new Error("onGaveUp is meant to be overridden in each game.")
		}
		
		/**
		 * @inheritDoc
		 */		
		public function resume(event:Event):void
		{
			// to override in GameScreen
		}
		
		/**
		 * @inheritDoc
		 */		
		public function gameOver():void
		{
			// to override in GameScreen
			
			InfoManager.show(_("Validation de votre partie en cours.\nMerci de patienter quelques secondes..."));
			//Flox.logEvent("Parties", { "4. Etat de la partie":(_gaveUp ? "Abandonnee" : "Terminee"), "5. Connectivité en fin de partie":( AirNetworkInfo.networkInfo.isConnected() ? "Connecte" : "Deconnecte") });
			
			// update tutorial state
			if( MemberManager.getInstance().getDisplayTutorial() == true )
				MemberManager.getInstance().setDisplayTutorial(false);
			
			PauseManager.isPlaying = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Game validation
		
		/**
		 * Validates the game session.
		 * 
		 * <p>In solo mode, there are no rewards so we don't really care about if we can send it right now or later.</p>
		 * 
		 * <p>On the other hand, in duel mode, the reward is calculated at the beginning of the game session (because we
		 * match the user to an opponent and the reward is pre-determined), so that no matter if the user is connected
		 * to the netward or not at the end of the game, we can push the game session later but still show the rewards.<p/>
		 */		
		protected function validateGame(finalScore:int, totalElapsedTime:int):void
		{
			if(!_isValidatingGame) // avoid multiple validations
			{
				log("Score" + finalScore + " made in " + (totalElapsedTime / 1000) + " seconds.");
				
				_isValidatingGame = true;
				
				// dissociate the game session from the trophy manager
				TrophyManager.getInstance().currentGameSession = null;
				// dispose banners
				AdManager.disposeBanners();
				
				// update the score and the gain
				_gameSession.score = finalScore;
				_gameSession.elapsedTime = totalElapsedTime;
				advancedOwner.screenData.gameData.score = _gameSession.score;
				advancedOwner.screenData.gameData.numStarsOrPointsEarned = _gameSession.numStarsOrPointsEarned = 999; // FIXME A modifier
				
				// report iOS Leaderboard
				GameCenterManager.reportLeaderboardScore(AbstractGameInfo.LEADERBOARD_HIGHSCORE, _gameSession.score);
				
				// if connected to internet, we validate the game session directly
				if(AirNetworkInfo.networkInfo.isConnected())
				{
					_gameSession.connected = true;
					Remote.getInstance().pushGame(_gameSession, onGamePushSuccess, onGamePushFailure, onGamePushFailure, 1);
				}
				else
				{
					// otherwise we save it for later
					onGamePushFailure();
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Game validation callbacks
		
		/**
		 * The game session was pushed, we can remove it from the push manager and go to the next screen.
		 */		
		private function onGamePushSuccess(result:Object):void
		{
			log("[AbstractGame] GameSession validated : " + result.code + " => " + result.txt);
			
			AbstractEntryPoint.pushManager.removeLastGameSession(_gameSession);
			
			switch(result.code)
			{
				case 0:  // invalid data
				case 10: // given date is higher than the one of the server // ?
				case 12: // classic game too old to be taken in account // ?
				case 13: // game session already pushed
				{
					onGamePushFailure();
					break;
				}
				case 1: // ok
				{
					// Facebook data - only returned when the user is connected with Facebook and have a valid token
					if("fb_hs_friends" in result && result.fb_hs_friends)
					{
						if("classement" in result.fb_hs_friends && (result.fb_hs_friends.classement as Array).length > 0)
						{
							advancedOwner.screenData.gameData.facebookFriends = (result.fb_hs_friends.classement as Array).concat();
							advancedOwner.screenData.gameData.facebookMoving = int(result.fb_hs_friends.deplacement);
							advancedOwner.screenData.gameData.facebookPosition = int(result.fb_hs_friends.key_position);
						}
					}
					/*else // Temporary for debugging
					{
						advancedOwner.screenData.gameData.facebookFriends = [ { classement:1, id:7526441, id_facebook:1087069645, last_classement:1, last_score:350, nom:"Maxime Lhoez", score:350 },
																			  { classement:2, id:7525967, id_facebook:100001491084445, last_classement:3, last_score:220, nom:"Nicolas Alexandre", score:220 },
																			  { classement:2, id:7525969, id_facebook:100003577159732, last_classement:4, last_score:100, nom:"Maxime Lhz", score:250 } ];
						advancedOwner.screenData.gameData.facebookMoving = 1;
						advancedOwner.screenData.gameData.facebookPosition = 2;
					}*/
					
					// show the trophies that can be earned after a server side validation // TODO maybe get this whe nthe game is initialzed ?
					if("tab_php_trophy_win" in result && result.tab_php_trophy_win && (result.tab_php_trophy_win as Array).length > 0)
					{
						for each(var idTrophy:int in result.tab_php_trophy_win)
						{
							// Display trophy only once
							if( TrophyManager.getInstance().canWinTrophy(idTrophy) )
								TrophyManager.getInstance().onWinTrophy( idTrophy );
						}
					}
					
					if(_gameSession.gameMode == GameMode.SOLO) // solo
					{
						this.advancedOwner.screenData.gameData.numStarsOrPointsEarned = int(result.gains);
						_nextScreenId = int(result.isHighscore) == 1 ? ScreenIds.NEW_HIGH_SCORE_SCREEN : ScreenIds.SOLO_END_SCREEN;
						if(TrophyManager.getInstance().isTrophyMessageDisplaying )
						{
							TrophyManager.getInstance().addEventListener(Event.COMPLETE, onTrophiesDisplayed);
						}
						else
						{
							InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
							advancedOwner.replaceScreen(_nextScreenId);
						}
					}
					else // duel
					{
						advancedOwner.screenData.gameData.numStarsOrPointsEarned = int(result.items);
						advancedOwner.screenData.gameData.position = int(result.classement);
						advancedOwner.screenData.gameData.top = int(result.top);
						advancedOwner.screenData.gameData.hasReachNewTop = int(result.podium) == 1;
						advancedOwner.screenData.gameData.displayPushAlert = int(result.afficher_alerte_push) == 1;
						
						if(result.isHighscore == 1)
						{
							if( TrophyManager.getInstance().isTrophyMessageDisplaying )
							{
								_nextScreenId = ScreenIds.NEW_HIGH_SCORE_SCREEN;
								TrophyManager.getInstance().addEventListener(Event.COMPLETE, onTrophiesDisplayed);
							}
							else
							{
								InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
								advancedOwner.replaceScreen( ScreenIds.NEW_HIGH_SCORE_SCREEN );
							}
						}
						else
						{
							// no highscore but maybe a new level
							if( TrophyManager.getInstance().isTrophyMessageDisplaying )
							{
								_nextScreenId = int(advancedOwner.screenData.gameData.hasReachNewTop) == 1 ? ScreenIds.PODIUM_SCREEN : ScreenIds.TOURNAMENT_END_SCREEN;
								TrophyManager.getInstance().addEventListener(Event.COMPLETE, onTrophiesDisplayed);
							}
							else
							{
								InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
								advancedOwner.replaceScreen( int(advancedOwner.screenData.gameData.hasReachNewTop) == 1 ? ScreenIds.PODIUM_SCREEN : ScreenIds.TOURNAMENT_END_SCREEN );
							}
						}
					}
					break;
				}
					
				default:
				{
					onGamePushFailure();
					break;
				}
			}
			
			// re-enable the PushManager
			AbstractEntryPoint.pushManager.isEnabled = true;
		}
		
		/**
		 * The game session could not be validated or there was no connection when we
		 * tried to push it to our server.
		 * 
		 * <p>In this case wee need to save this game session so that it can be pushed
		 * later.</p>
		 * 
		 * <p>The points (in classic mode) or the cumulated stars (in tournament mode)
		 * will be updated here so that it matches what the user just earned. Those values
		 * might be replaced at any time when a <code>obj_membre_mobile</code> is returned
		 * by a query in <code>Remote</code>.</p>
		 */		
		private function onGamePushFailure():void
		{
			/*this.advancedOwner.screenData.gameData.top = 15;
			this.advancedOwner.screenData.gameData.hasReachNewTop = true;
			advancedOwner.showScreen( ScreenIds.PODIUM_SCREEN );
			
			return;*/
			
			// update earned values in any cases
			if( _gameSession.gameMode == GameMode.SOLO )
			{
				
			}
			else
			{
				MemberManager.getInstance().cumulatedRubies = ( MemberManager.getInstance().cumulatedRubies + advancedOwner.screenData.gameData.numStarsOrPointsEarned );
			}
			
			_nextScreenId = _gameSession.gameMode == GameMode.SOLO ? ScreenIds.SOLO_END_SCREEN : ScreenIds.TOURNAMENT_END_SCREEN;
			if( MemberManager.getInstance().highscore != 0 && _gameSession.score > MemberManager.getInstance().highscore )
			{
				// the user got a new high score
				MemberManager.getInstance().highscore = _gameSession.score;
				_nextScreenId = ScreenIds.NEW_HIGH_SCORE_SCREEN;
				if( TrophyManager.getInstance().isTrophyMessageDisplaying )
				{
					TrophyManager.getInstance().addEventListener(Event.COMPLETE, onTrophiesDisplayed);
				}
				else
				{
					InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
					advancedOwner.replaceScreen( _nextScreenId );
				}
			}
			else
			{
				// set up the new high score, because this is the first one
				if( MemberManager.getInstance().highscore == 0 )
					MemberManager.getInstance().highscore = _gameSession.score;
				
				if( TrophyManager.getInstance().isTrophyMessageDisplaying )
				{
					TrophyManager.getInstance().addEventListener(Event.COMPLETE, onTrophiesDisplayed);
				}
				else
				{
					InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
					advancedOwner.replaceScreen( _nextScreenId );
				}
			}
			
			if( !MemberManager.getInstance().isLoggedIn() )
			{
				// if the user is not logged in, we need to store the game sessions
				MemberManager.getInstance().anonymousGameSessions[ (MemberManager.getInstance().anonymousGameSessions.length - 1) ] = _gameSession;
				MemberManager.getInstance().anonymousGameSessions = ( MemberManager.getInstance().anonymousGameSessions );
			}
			
			// re-enable the PushManager
			AbstractEntryPoint.pushManager.isEnabled = true;
		}
		
		/**
		 * All the trophies have been displayed, in this case we can show the next screen.
		 */		
		private function onTrophiesDisplayed(event:Event):void
		{
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			TrophyManager.getInstance().removeEventListener(Event.COMPLETE, onTrophiesDisplayed);
			AbstractEntryPoint.screenNavigator.replaceScreen(_nextScreenId);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			// free memory
			AbstractEntryPoint.assets.removeTextureAtlas("game", true);
			AbstractEntryPoint.assets.removeTextureAtlas("common", true);
			AbstractEntryPoint.assets.removeTextureAtlas("tutorial", true);
			
			PauseManager.isPlaying = false;
			PauseManager.dispatcher.removeEventListener(MobileEventTypes.EXIT, giveUp);
			PauseManager.dispatcher.removeEventListener(MobileEventTypes.RESUME, resume);
			
			if( _loader )
			{
				Starling.juggler.remove(_loader);
				_loader.removeFromParent(true);
				_loader = null;
			}
			
			if( _playOverlay )
			{
				_playOverlay.removeFromParent(true);
				_playOverlay = null;
			}
			
			if( _playButton )
			{
				_playButton.removeEventListener(Event.TRIGGERED, onPlay);
				_playButton.removeFromParent(true);
				_playButton = null;
			}
			
			super.dispose();
		}
		
	}
}