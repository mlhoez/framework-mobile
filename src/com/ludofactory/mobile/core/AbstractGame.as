/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.core
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.Utility;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.scoring.ScoreConverter;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.achievements.GameCenterManager;
	import com.ludofactory.mobile.core.test.achievements.TrophyManager;
	import com.ludofactory.mobile.core.test.ads.AdManager;
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.ludofactory.mobile.core.test.push.PushType;
	import com.milkmangames.nativeextensions.ios.IAdBannerAlignment;
	
	import flash.display.StageAspectRatio;
	import flash.events.Event;
	
	import starling.core.Starling;
	import starling.events.Event;
	
	/**
	 * AbstractGame
	 */	
	public class AbstractGame extends AdvancedScreen
	{
		/**
		 * The game session. */		
		private var _gameSession:GameSession;
		
		/**
		 * @param isLandscape
		 */		
		public function AbstractGame(isLandscape:Boolean)
		{
			super();
			
			_fullScreen = true;
			_isLandscape = isLandscape;
			_canBack = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			Flox.logEvent("Parties jouees vs. parties abandonnees", {Total:"Total"});
			
			AdManager.createiAdBanner(IAdBannerAlignment.BOTTOM);
			AdManager.crateAdMobBanner();
			
			// We need to check here if the user can really play, this case can can happen if
			// the user played while logged out, and at the end of the game, he chooses to play
			// again and then logged in but the account didn't have enought free game sessions /
			// points or credits.
			switch( this.advancedOwner.screenData.gamePrice )
			{
				case GameSession.PRICE_FREE:
				{
					if( MemberManager.getInstance().getNumFreeGameSessions() < Storage.getInstance().getProperty( this.advancedOwner.screenData.gameType == GameSession.TYPE_FREE ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ) )
					{
						this.advancedOwner.screenData.purgeData();
						this.advancedOwner.showScreen( ScreenIds.HOME_SCREEN );
						return;
					}
					break;
				}
				case GameSession.PRICE_CREDIT:
				{
					if( MemberManager.getInstance().getCredits() < Storage.getInstance().getProperty( this.advancedOwner.screenData.gameType == GameSession.TYPE_FREE ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) )
					{
						this.advancedOwner.screenData.purgeData();
						this.advancedOwner.showScreen( ScreenIds.HOME_SCREEN );
						return;
					}
					break;
				}
				case GameSession.PRICE_POINT:
				{
					if( MemberManager.getInstance().getPoints() < Storage.getInstance().getProperty( StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE ) )
					{
						this.advancedOwner.screenData.purgeData();
						this.advancedOwner.showScreen( ScreenIds.HOME_SCREEN );
						return;
					}
					break;
				}
			}
			
			advancedOwner.screenData.displayPopupOnHome = false;
			
			// if the user can really play, we know initialize a game session which will
			// be saved until the end of the game and we decrement the associated values
			// (chather free game sessions, points or credits).
			log("Démarrage d'une partie en mode <strong>[" + this.advancedOwner.screenData.gameType + ", mise : " + advancedOwner.screenData.gamePrice + "</strong>");
			Flox.logEvent("Parties classiques vs. parties en tournoi", {Etat:(this.advancedOwner.screenData.gameType == GameSession.TYPE_FREE ? "Classique":"Tournoi")});
			Flox.logEvent("Parties gratuites vs. a credit vs. a points", {Etat:this.advancedOwner.screenData.gamePrice});
			
			if( advancedOwner.screenData.gameType == GameSession.TYPE_FREE )
			{
				Flox.logEvent("Nombre de parties en mode classique", {Type:"Classique", Mise:advancedOwner.screenData.gamePrice});
			}
			else
			{
				Flox.logEvent("Nombre de parties en mode tournoi", {Type:"Tournoi", Mise:advancedOwner.screenData.gamePrice});
			}
			
			AbstractEntryPoint.pushManager.isEnabled = false;
			_gameSession = new GameSession(PushType.GAME_SESSION, this.advancedOwner.screenData.gameType, this.advancedOwner.screenData.gamePrice );
			
			TrophyManager.getInstance().currentGameSession = _gameSession;
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				AbstractEntryPoint.pushManager.addElementToPush( _gameSession );
			}
			else
			{
				MemberManager.getInstance().getAnonymousGameSessions().push( _gameSession );
				MemberManager.getInstance().setAnonymousGameSessions( MemberManager.getInstance().getAnonymousGameSessions() );
			}
			
			switch(this.advancedOwner.screenData.gamePrice)
			{
				case GameSession.PRICE_FREE:
				{
					MemberManager.getInstance().setNumFreeGameSessions( MemberManager.getInstance().getNumFreeGameSessions() - Storage.getInstance().getProperty( this.advancedOwner.screenData.gameType == GameSession.TYPE_FREE ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ) );
					break;
				}
				case GameSession.PRICE_CREDIT:
				{
					MemberManager.getInstance().setCredits( MemberManager.getInstance().getCredits() - Storage.getInstance().getProperty( this.advancedOwner.screenData.gameType == GameSession.TYPE_FREE ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) );
					break;
				}
				case GameSession.PRICE_POINT:
				{
					MemberManager.getInstance().setPoints( MemberManager.getInstance().getPoints() - Storage.getInstance().getProperty( StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE ) );
					break;
				}
			}
			
			if( _isLandscape )
			{
				Starling.current.nativeStage.addEventListener(flash.events.Event.RESIZE, onOrientationChanged, false, int.MAX_VALUE, true);
				Starling.current.nativeStage.setAspectRatio(StageAspectRatio.LANDSCAPE);
			}
			else
			{
				initializeGame();
			}
		}
		
		private function onOrientationChanged(event:flash.events.Event):void
		{
			Starling.current.nativeStage.removeEventListener(flash.events.Event.RESIZE, onOrientationChanged, false);
			initializeGame();
		}
		
		/**
		 * The application has finished resizing, we can start loading all the assets for
		 * the game. Depending on which type of device we are we will load a specific
		 * size of the game assets so that it fits any device.
		 * 
		 * <p>Whe we initialize the game, we need to store the current GameSession
		 * so that we can push it at the end of the game if possible and if not, later
		 * in the PushManager. Thus, while the user plays, we disable the PushManager
		 * so that no information is pushed while he is playing.</p>
		 * 
		 * <p>We need to do this in the resize function because otherwise, we will get a
		 * contect error (context = dispose while resizing).</p>
		 * 
		 * @see com.ludofactory.mobile.push.PushManager
		 * @see com.ludofactory.mobile.push.GameSession
		 */		
		protected function initializeGame():void
		{
			// to override
		}
		
//------------------------------------------------------------------------------------------------------------
//	
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * <p>This function will calculate the final score (base score + bonuses) and then
		 * convert it to the appropriate gain : whether stars or points depending on which
		 * type of game have been choose (tournament or free game).</p>
		 * 
		 * <p>The score is updated in the GameSession object (which have been initialized
		 * at the beginning of the game) so that we can push it right after (if we can).</p>
		 * 
		 * <p>Those informations (socre and gain) are also sotred in the <code>_data</code>
		 * object in order to be passed to the next screen.</p>
		 * 
		 * Some fake data to use
		 * 
		 * var result:Object = {};
		 * result.code = 1;
		 * result.isHighscore = 1;
		 * result.highscore = 159;
		 * result.etoiles = 100;
		 * result.classement = 95;
		 * result.top = 999;
		 * result.lot_actuel = "Une Xbox 360";
		 * result.lot_suivant = {};
		 * result.lot_suivant.lot = "1000€";
		 * result.lot_suivant.nb_etoiles = 2000;
		 * result.podium = 1;
		 * result.gains = 5;
		 * 
		 * onGameSessionValidated(result);
		 * 
		 */		
		protected function validateGame(finalScore:int, totalElapsedTime:int):void
		{
			TrophyManager.getInstance().currentGameSession = null;
			AdManager.disposeBanners();
			
			// update the score and the gain (Note taht this last value
			// will be overridden if the push is a success)
			var scoreConverter:ScoreConverter = new ScoreConverter();
			_gameSession.score = finalScore;
			_gameSession.elapsedTime = totalElapsedTime;
			this.advancedOwner.screenData.gameData.score = _gameSession.score;
			GameCenterManager.reportLeaderboardScore(AbstractGameInfo.LEADERBOARD_HIGHSCORE, _gameSession.score);
			
			// those values be overridden if the push is a success
			advancedOwner.screenData.gameData.numStarsOrPointsEarned = _gameSession.numStarsOrPointsEarned = scoreConverter.convertScore(_gameSession.score, _gameSession.gamePrice, _gameSession.gameType);
			
			// Try to directly push this game session
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					Flox.logEvent("Ratio de parties jouees connecte / déconnecte", {Etat:"Connecte"});
					_gameSession.connected = true;
					Remote.getInstance().pushGame(_gameSession, onGamePushSuccess, onGamePushFailure, onGamePushFailure, 1);
				}
				else
				{
					Flox.logEvent("Ratio de parties jouees connecte / déconnecte", {Etat:"Déconnecte"});
					onGamePushFailure();
				}
			}
			else
			{
				onGamePushFailure();
			}
		}
		
		/**
		 * The game session was pushed, we can remove it from the push manager
		 * and go to the next screen.
		 */		
		private function onGamePushSuccess(result:Object):void
		{
			log("[GameScreen] GameSession validated : " + result.code + " => " + result.txt);
			
			AbstractEntryPoint.pushManager.removeLastGameSession(_gameSession);
			
			switch(result.code)
			{
				case 0: // invalid data
				case 3: // cannot retreive the score to points array in php
				case 5: // id jeux arcade not defined in config
				case 9: // cannot retreive the score to stars array in php
				case 2: // game with credits but not enough in database ( ask to buy credits ? )
				case 4: // not enough free game sessions
				case 6: // not tournament actually for this game
				case 7: // not enough points for this tournament
				case 8: // not enough credits for this tournament
				{
					// false = no update because even if there is an error, an object membre_mobile
					// will be returned
					onGamePushFailure(false);
					break;
				}
				case 1: // ok
				{
					advancedOwner.screenData.gameData.gameSessionPushed = true;
					
					// Facebook data (returned only when the user is connected to Facebook)
					if( result.hasOwnProperty("fb_hs_friends") && result.fb_hs_friends )
					{
						if( result.fb_hs_friends.hasOwnProperty("classement") && (result.fb_hs_friends.classement as Array).length > 0 )
						{
							advancedOwner.screenData.gameData.facebookFriends = (result.fb_hs_friends.classement as Array).concat();
							advancedOwner.screenData.gameData.facebookMoving = int(result.fb_hs_friends.deplacement);
							advancedOwner.screenData.gameData.facebookPosition = int(result.fb_hs_friends.key_position);
						}
					}
					/*else
					{
						// FIXME Temporaire !!!
						advancedOwner.screenData.gameData.facebookFriends = [ { classement:1, id:7525971, id_facebook:1087069645, last_classement:1, last_score:350, nom:"Maxime Lhoez", score:350 },
																			  { classement:2, id:7525967, id_facebook:100001491084445, last_classement:3, last_score:220, nom:"Nicolas Alexandre", score:220 },
																			  { classement:2, id:7525969, id_facebook:100003577159732, last_classement:4, last_score:100, nom:"Maxime Lhz", score:250 } ];
						advancedOwner.screenData.gameData.facebookMoving = 1;
						advancedOwner.screenData.gameData.facebookPosition = 2;
					}*/
					
					if( result.hasOwnProperty("tab_php_trophy_win") && result.tab_php_trophy_win && result.tab_php_trophy_win.length > 0 )
					{
						for each( var idTrophy:int in result.tab_php_trophy_win )
						{
							// Display trophy only once
							if( TrophyManager.getInstance().canWinTrophy(idTrophy) )
								TrophyManager.getInstance().onWinTrophy( idTrophy );
						}
					}
					
					
					if( _gameSession.gameType == GameSession.TYPE_FREE )
					{
						// free game
						// add points only in free mode
						this.advancedOwner.screenData.gameData.numStarsOrPointsEarned = int(result.gains);
						if( TrophyManager.getInstance().isTrophyMessageDisplaying )
						{
							_nextScreenId = int(result.isHighscore) == 1 ? ScreenIds.NEW_HIGH_SCORE_SCREEN : ScreenIds.FREE_GAME_END_SCREEN;
							TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
						}
						else
						{
							InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
							advancedOwner.showScreen( int(result.isHighscore) == 1 ? ScreenIds.NEW_HIGH_SCORE_SCREEN : ScreenIds.FREE_GAME_END_SCREEN );
						}
					}
					else
					{
						// tournament
						this.advancedOwner.screenData.gameData.numStarsOrPointsEarned = int(result.etoiles);
						this.advancedOwner.screenData.gameData.position = int(result.classement);
						this.advancedOwner.screenData.gameData.top = int(result.top);
						this.advancedOwner.screenData.gameData.actualGiftImageUrl = result.lot_actuel.image;
						this.advancedOwner.screenData.gameData.actualGiftName = Utility.replaceCurrency(result.lot_actuel.nom);
						this.advancedOwner.screenData.gameData.nextGiftImageUrl = result.lot_suivant.image;
						this.advancedOwner.screenData.gameData.nextGiftName = Utility.replaceCurrency(result.lot_suivant.nom);
						this.advancedOwner.screenData.gameData.numStarsForNextGift = int(result.lot_suivant.nb_etoiles);
						this.advancedOwner.screenData.gameData.hasReachNewTop = int(result.podium) == 1 ? true:false;
						this.advancedOwner.screenData.gameData.timeUntilTournamentEnd = int(result.temps_fin_tournoi);
						this.advancedOwner.screenData.gameData.displayPushAlert = int(result.afficher_alerte_push) == 1 ? true : false;
						this.advancedOwner.screenData.gameData.topDotationName = result.top_dotation;
						
						if( result.isHighscore == 1 )
						{
							if( TrophyManager.getInstance().isTrophyMessageDisplaying )
							{
								_nextScreenId = ScreenIds.NEW_HIGH_SCORE_SCREEN;
								TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
							}
							else
							{
								InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
								advancedOwner.showScreen( ScreenIds.NEW_HIGH_SCORE_SCREEN );
							}
						}
						else
						{
							// no highscore but maybe a new level
							if( TrophyManager.getInstance().isTrophyMessageDisplaying )
							{
								_nextScreenId = int(result.podium) == 1 ? ScreenIds.PODIUM_SCREEN : ScreenIds.TOURNAMENT_GAME_END_SCREEN;
								TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
							}
							else
							{
								InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
								advancedOwner.showScreen( int(result.podium) == 1 ? ScreenIds.PODIUM_SCREEN : ScreenIds.TOURNAMENT_GAME_END_SCREEN );
							}
						}
					}
					break;
				}
					
				default:
				{
					onGamePushFailure(false);
					break;
				}
			}
			
			// re-enable the PushManager
			AbstractEntryPoint.pushManager.isEnabled = true;
		}
		
		/**
		 * The game session could not be validated or there is no connection.
		 * 
		 * <p>In this case wee need to save this game session so that it can
		 * be pushed later.</p>
		 * 
		 * <p>The points 'in free mode) or the ncumulated stars number (in
		 * tournament mode) will be updated here so that it matches we the
		 * user just earned. Those values might be overridden at any time
		 * when a <code>obj_membre_mobile</code> is returned by a query.</p>
		 */		
		private function onGamePushFailure(error:Object = null):void
		{
			//AlertManager.hide("", ProgressPopup.SUCCESS_ICON_NOTHING, 0);
			advancedOwner.screenData.gameData.gameSessionPushed = false;
			
			// update earned values in any cases
			if( _gameSession.gameType == GameSession.TYPE_FREE )
				MemberManager.getInstance().setPoints( MemberManager.getInstance().getPoints() + advancedOwner.screenData.gameData.numStarsOrPointsEarned );
			else
				MemberManager.getInstance().setCumulatedStars( MemberManager.getInstance().getCumulatedStars() + advancedOwner.screenData.gameData.numStarsOrPointsEarned );
			
			_nextScreenId = _gameSession.gameType == GameSession.TYPE_FREE ? ScreenIds.FREE_GAME_END_SCREEN:ScreenIds.TOURNAMENT_GAME_END_SCREEN;
			if( MemberManager.getInstance().getHighscore() != 0 && _gameSession.score > MemberManager.getInstance().getHighscore() )
			{
				// the user did a new high score
				MemberManager.getInstance().setHighscore( _gameSession.score );
				if( TrophyManager.getInstance().isTrophyMessageDisplaying )
				{
					_nextScreenId = ScreenIds.NEW_HIGH_SCORE_SCREEN;
					TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
				}
				else
				{
					InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
					advancedOwner.showScreen( ScreenIds.NEW_HIGH_SCORE_SCREEN );
				}
			}
			else
			{
				if( MemberManager.getInstance().getHighscore() == 0 )
				{
					// set up the new high score (this is the first one
					MemberManager.getInstance().setHighscore(_gameSession.score);
				}
				// else no new high score
				
				if( TrophyManager.getInstance().isTrophyMessageDisplaying )
				{
					TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
				}
				else
				{
					InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
					advancedOwner.showScreen( _nextScreenId );
				}
			}
			
			if( !MemberManager.getInstance().isLoggedIn() )
			{
				// if the user is not logged in, we need to store the game sessions
				MemberManager.getInstance().getAnonymousGameSessions()[ (MemberManager.getInstance().getAnonymousGameSessions().length - 1) ] = _gameSession;
				MemberManager.getInstance().setAnonymousGameSessions( MemberManager.getInstance().getAnonymousGameSessions() );
			}
			
			// re-enable the PushManager
			AbstractEntryPoint.pushManager.isEnabled = true;
		}
		
		private var _nextScreenId:String;
		
		private function onTrophiesDisplayed(event:starling.events.Event):void
		{
			TrophyManager.getInstance().removeEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			AbstractEntryPoint.screenNavigator.showScreen( _nextScreenId ); // bug des fois si AdvancedOwner utilisé à la place
		}
		
	}
}