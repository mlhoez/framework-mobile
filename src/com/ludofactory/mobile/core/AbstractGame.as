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
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.model.ScreenData;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.pause.PauseManager;
	import com.ludofactory.mobile.core.push.GameSession;
	import com.ludofactory.mobile.core.push.PushType;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobileNew.core.achievements.GameCenterManager;
	import com.ludofactory.mobileNew.core.achievements.TrophyManager;
	import com.ludofactory.mobileNew.core.ads.AdManager;
	import com.ludofactory.mobileNew.GameActionsRecorder;
	import com.ludofactory.mobileNew.core.jauge.GameJauge;
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
		 * The game session that will hold important informations. */		
		private var _gameSession:GameSession;
		
		/**
		 * Records all the score variations during the game. */
		protected var _actionsRecorder:GameActionsRecorder;
		/**
		 * The user jauge. */
		protected var _userJauge:GameJauge;
		/**
		 * The opponent jauge in duel mode or the self-highscore jauge in solo mode. */
		protected var _opponentJauge:GameJauge;
		
		/**
		 * The transparent black overlay. */
		protected var _blackOverlay:Image;
		/**
		 * Loader */		
		private var _loader:MovieClip;
		/**
		 * The play button displayed at the begining of a game session. */		
		protected var _playButton:MobileButton;
		
		/**
		 * Whether the player gave up this game session. */		
		private var _gaveUp:Boolean = false;
		
		/**
		 * Whether the screen is validating. This is added for security reason in order to avoid multiple validations. */		
		private var _isValidatingGame:Boolean = false;
		/**
		 * Stores the calculated next screen id. */
		private var _nextScreenId:String;
		
		/**
		 * Whether we need to display the tutorial. */
		protected var _displayTutorial:Boolean = false;
		
		public function AbstractGame()
		{
			super();
			
			_canBack = false;
		}
		
		/**
		 * Initializes the core data of a game session.
		 */
		override protected function initialize():void
		{
			super.initialize();
			
			// create banners in order to display them faster when the game is paused
			AdManager.getInstance().createiAdBanner(IAdBannerAlignment.BOTTOM);
			AdManager.getInstance().crateAdMobBanner();
			
			// disable the push manager while playing
			AbstractEntryPoint.pushManager.isEnabled = false;
			
			// create the game session data, link it to the TrophyManager and add it to the PushManager in case
			// the user quits the game while playing
			_gameSession = new GameSession(PushType.GAME_SESSION, ScreenData.getInstance().gameMode);
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
			AbstractEntryPoint.assets.enqueue(path.url + "/game.png");
			AbstractEntryPoint.assets.enqueue(path.url + "/game.xml");
			
			// load common assets if found
			path = File.applicationDirectory.resolvePath("assets/game/common/");
			if(path.exists)
				AbstractEntryPoint.assets.enqueue(path);
			
			// load tutorial elements if necessary
			_displayTutorial = MemberManager.getInstance().needsTutorial;
			if(_displayTutorial)
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
			_blackOverlay = new Image(AbstractEntryPoint.assets.getTexture("overlay-skin"));
			_blackOverlay.width = GlobalConfig.stageWidth;
			_blackOverlay.height = GlobalConfig.stageHeight;
			addChild(_blackOverlay);
			
			_playButton = ButtonFactory.getButton(_("Commencer"), ButtonFactory.SPECIAL);
			_playButton.x = (GlobalConfig.stageWidth - _playButton.width) * 0.5;
			_playButton.y = (GlobalConfig.stageHeight - _playButton.height) * 0.5;
			_playButton.addEventListener(Event.TRIGGERED, onPlay);
			addChild(_playButton);
			
			// enable the pause view and listeners
			PauseManager.dispatcher.addEventListener(MobileEventTypes.EXIT, giveUp);
			PauseManager.dispatcher.addEventListener(MobileEventTypes.RESUME, resume);
			
			// the actions recorder
			_actionsRecorder = new GameActionsRecorder();
			
			_userJauge = new GameJauge(AbstractEntryPoint.assets.getTexture("default-photo"));
			_userJauge.alpha = 0;
			addChild(_userJauge);
			
			MemberManager.getInstance().highscore = 100; // FIXME A retirer
			if((ScreenData.getInstance().gameMode == GameMode.SOLO && MemberManager.getInstance().highscore != 0 )|| ScreenData.getInstance().gameMode == GameMode.DUEL)
			{
				// display the jauge only in duel mode or when in solo mode but with a highscore reference
				_opponentJauge = new GameJauge(ScreenData.getInstance().gameMode == GameMode.SOLO ? AbstractEntryPoint.assets.getTexture("high-score-default-jauge") : (ScreenData.getInstance().gameData.challengerFacebookId != 0 ? ("https://graph.facebook.com/" + ScreenData.getInstance().gameData.challengerFacebookId + "/picture?type=large&width=" + scaleAndRoundToDpi(58) + "&height=" + scaleAndRoundToDpi(58)) : AbstractEntryPoint.assets.getTexture("unknown-default-jauge")) ); // TODO mettre l'url de l'image de l'adversaire
				_opponentJauge.addReader(JSON.parse('[{"s":100,"t":4},{"s":150,"t":5},{"s":200,"t":6},{"s":250,"t":10},{"s":100,"t":15},{"s":150,"t":16},{"s":200,"t":17},{"s":250,"t":18},{"s":300,"t":19},{"s":100,"t":25},{"s":150,"t":26},{"s":200,"t":31},{"s":250,"t":32},{"s":300,"t":33},{"s":250,"t":40},{"s":1100,"t":43},{"s":200,"t":44},{"s":550,"t":45},{"s":100,"t":52},{"s":150,"t":55},{"s":1500,"t":58},{"s":100,"t":60},{"s":100,"t":66},{"s":3000,"t":71},{"s":100,"t":75},{"s":100,"t":82},{"s":350,"t":86},{"s":250,"t":88},{"s":100,"t":94},{"s":250,"t":98},{"s":450,"t":101},{"s":100,"t":104},{"s":150,"t":105},{"s":200,"t":106},{"s":250,"t":110},{"s":200,"t":111},{"s":250,"t":112},{"s":650,"t":113},{"s":400,"t":114},{"s":100,"t":123},{"s":1100,"t":126},{"s":100,"t":129},{"s":100,"t":139},{"s":1500,"t":144},{"s":9900,"t":148},{"s":0,"t":155}]') as Array);
				_opponentJauge.alpha = 0;
				addChild(_opponentJauge);
			}
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
			
			_blackOverlay.removeFromParent(true);
			_blackOverlay = null;
			
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
			if(MemberManager.getInstance().needsTutorial)
				MemberManager.getInstance().needsTutorial = false;
			
			PauseManager.isPlaying = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function onTutorialOver():void
		{
			MemberManager.getInstance().needsTutorial = false;
			_displayTutorial = false;
			
			_actionsRecorder.reset();
			
			PauseManager.isPlaying = true;
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
				log("Score" + finalScore + " made in " + totalElapsedTime + " seconds.");
				
				_isValidatingGame = true;
				
				// dissociate the game session from the trophy manager
				TrophyManager.getInstance().currentGameSession = null;
				// dispose banners
				AdManager.getInstance().disposeBanners();
				
				// update the score and the gain
				ScreenData.getInstance().gameData.finalScore = _gameSession.score = finalScore;
				_gameSession.elapsedTime = totalElapsedTime;
				if(_gameSession.gameMode == GameMode.SOLO)
					_gameSession.actions = _actionsRecorder.getFinal();
				
				log(_actionsRecorder.getFinal())
				
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
					// parse the data
					ScreenData.getInstance().gameData.parse(result);
					
					// show the trophies that can be earned after a server side validation
					if("tab_php_trophy_win" in result && result.tab_php_trophy_win && (result.tab_php_trophy_win as Array).length > 0)
					{
						for each(var idTrophy:int in result.tab_php_trophy_win)
						{
							// Display trophy only once
							if(TrophyManager.getInstance().canWinTrophy(idTrophy))
								TrophyManager.getInstance().onWinTrophy(idTrophy);
						}
					}
					
					_nextScreenId = ScreenData.getInstance().gameData.isNewHighscore ? ScreenIds.NEW_HIGH_SCORE_SCREEN : // can only be true in solo mode so no need to check the mode here
							(_gameSession.gameMode == GameMode.SOLO ? ScreenIds.SOLO_END_SCREEN : (ScreenData.getInstance().gameData.hasReachNewTop ? ScreenIds.PODIUM_SCREEN : ScreenIds.DUEL_END_SCREEN));
					
					if(TrophyManager.getInstance().isTrophyMessageDisplaying )
					{
						TrophyManager.getInstance().addEventListener(Event.COMPLETE, onTrophiesDisplayed);
					}
					else
					{
						InfoManager.forceClose();
						advancedOwner.replaceScreen(_nextScreenId);
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
		private function onGamePushFailure(error:Object = null):void
		{
			if( _gameSession.gameMode == GameMode.SOLO )
			{
				ScreenData.getInstance().gameData.isNewHighscore = MemberManager.getInstance().highscore == 0 || (MemberManager.getInstance().highscore != 0 && _gameSession.score > MemberManager.getInstance().highscore); 
				if(ScreenData.getInstance().gameData.isNewHighscore)
				{
					MemberManager.getInstance().highscore = _gameSession.score;
					MemberManager.getInstance().highscoreActions = _gameSession.actions;
				}
			}
			else
			{
				MemberManager.getInstance().cumulatedTrophies += ScreenData.getInstance().gameData.duelReward;
			}
			
			_nextScreenId = ScreenData.getInstance().gameData.isNewHighscore ? ScreenIds.NEW_HIGH_SCORE_SCREEN : // can only be true in solo mode so no need to check the mode here
					(_gameSession.gameMode == GameMode.SOLO ? ScreenIds.SOLO_END_SCREEN : ScreenIds.DUEL_END_SCREEN);
			
			if( TrophyManager.getInstance().isTrophyMessageDisplaying )
			{
				TrophyManager.getInstance().addEventListener(Event.COMPLETE, onTrophiesDisplayed);
			}
			else
			{
				InfoManager.forceClose();
				advancedOwner.replaceScreen(_nextScreenId);
			}
			
			// re-enable the PushManager
			AbstractEntryPoint.pushManager.isEnabled = true;
		}
		
		/**
		 * All the trophies have been displayed, in this case we can show the next screen.
		 */		
		private function onTrophiesDisplayed(event:Event):void
		{
			InfoManager.forceClose();
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
			
			if( _blackOverlay )
			{
				_blackOverlay.removeFromParent(true);
				_blackOverlay = null;
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