/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.newClasses
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.model.ScreenData;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.neww.SettingsPopupContent;
	import com.ludofactory.mobile.core.notification.content.neww.TrophiesPopupContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import starling.display.Image;
	import starling.events.Event;
	
	/**
	 * Home screen.
	 */
	public class HomeScreen extends AdvancedScreen
	{
		/**
		 * Background. */
		private var _background:Image;
		
		/**
		 * Header container, will hold the high score and number of trophies in duel mode. */
		private var _headerContainer:HeaderContainer;
		
		/**
		 * Settings button. */
		private var _settingsButton:IconButton;
		/**
		 * High scores ranking button. */
		private var _highscoresRankingButton:IconButton;
		/**
		 * Trophies ranking button. */
		private var _trophiesRankingButton:IconButton;
		/**
		 * Trophies button. */
		private var _trophiesButton:IconButton;
		
		/**
		 * Solo button. */
		private var _soloButton:MobileButton;
		/**
		 * Duel button. */
		private var _duelButton:MobileButton;
		
		public function HomeScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("dark-background"));
			addChild(_background);
			
			_headerContainer = new HeaderContainer();
			addChild(_headerContainer);
			
			_settingsButton = new IconButton(AbstractEntryPoint.assets.getTexture("settings-button"));
			_settingsButton.addEventListener(Event.TRIGGERED, onShowSettings);
			addChild(_settingsButton);
			
			_highscoresRankingButton = new IconButton(AbstractEntryPoint.assets.getTexture("highscores-ranking-button"));
			_highscoresRankingButton.addEventListener(Event.TRIGGERED, onShowHighscoresRanking);
			addChild(_highscoresRankingButton);
			
			_trophiesRankingButton = new IconButton(AbstractEntryPoint.assets.getTexture("trophies-ranking-button"));
			_trophiesRankingButton.addEventListener(Event.TRIGGERED, onShowTrophiesRanking);
			addChild(_trophiesRankingButton);
			
			_trophiesButton = new IconButton(AbstractEntryPoint.assets.getTexture("trophies-button"));
			_trophiesButton.addEventListener(Event.TRIGGERED, onShowTrophies);
			addChild(_trophiesButton);
			
			_soloButton = ButtonFactory.getButton(_("Solo"),ButtonFactory.SPECIAL);
			_soloButton.addEventListener(Event.TRIGGERED, onPlaySolo);
			addChild(_soloButton);
			
			_duelButton = ButtonFactory.getButton(_("Duel"),ButtonFactory.SPECIAL);
			_duelButton.addEventListener(Event.TRIGGERED, onPlayDuel);
			addChild(_duelButton);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_background.width = actualWidth;
				_background.height = actualHeight;
				
				_headerContainer.x = _headerContainer.y = scaleAndRoundToDpi(5);
				//_headerContainer.width = scaleAndRoundToDpi(400);
				
				_settingsButton.y = _highscoresRankingButton.y = _trophiesRankingButton.y = _trophiesButton.y = scaleAndRoundToDpi(5);
				_settingsButton.x = actualWidth - _settingsButton.width - scaleAndRoundToDpi(5);
				_highscoresRankingButton.x = _settingsButton.x - _highscoresRankingButton.width - scaleAndRoundToDpi(10);
				_trophiesRankingButton.x = _highscoresRankingButton.x - _trophiesRankingButton.width - scaleAndRoundToDpi(10);
				_trophiesButton.x = _trophiesRankingButton.x - _trophiesButton.width - scaleAndRoundToDpi(10);
				
				_soloButton.y = _duelButton.y = actualHeight - _soloButton.height - scaleAndRoundToDpi(5);
				_soloButton.x = roundUp((actualWidth - _soloButton.width - _duelButton.width - scaleAndRoundToDpi(5)) * 0.5);
				_duelButton.x = _soloButton.x + _soloButton.width + scaleAndRoundToDpi(5);
			}
			
			super.draw()
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function onShowSettings(event:Event):void
		{
			CustomPopupManager.addPopup(new SettingsPopupContent());
		}
		
		private function onShowHighscoresRanking(event:Event):void
		{
			CustomPopupManager.addPopup(new TrophiesPopupContent());
		}
		
		private function onShowTrophiesRanking(event:Event):void
		{
			CustomPopupManager.addPopup(new TrophiesPopupContent());
		}
		private function onShowTrophies(event:Event):void
		{
			CustomPopupManager.addPopup(new TrophiesPopupContent());
		}
		
		/**
		 * Starts a solo game.
		 * 
		 * 
		 */
		private function onPlaySolo(event:Event):void
		{
			ScreenData.getInstance().gameMode = GameMode.SOLO;
			advancedOwner.replaceScreen(ScreenIds.GAME_SCREEN);
		}
		
		/**
		 * Starts a duel game
		 * 
		 * Before the game can be launched, we need to make a request to our server in order to
		 * gather some informations about the game that will be played :
		 * 
		 *     - The opponenent : if we could find one, otherwise the player initializes a new duel.
		 *     This value will contain the nickname and current trophies count of the opponenent.
		 *     
		 *     - The value of the reward : just like Clash Royale, this value is pre-determined if
		 *     we found an opponent. In case of a victory, this value is added to the trophies count,
		 *     otherwise it will be decremented. If there was no opponent, we will indicate to the user
		 *     that the result will be displayed later in the home screen.
		 */
		private function onPlayDuel(event:Event):void
		{
			if(AirNetworkInfo.networkInfo.isConnected())
			{
				InfoManager.show("Recherche d'un duel en cours...");
				ScreenData.getInstance().gameMode = GameMode.DUEL;
				onDuelLaunchSuccess({});
				//Remote.getInstance().launchDuel(onDuelLaunchSuccess, onDuelLaunchFail, onDuelLaunchFail, 1, _screenID);
			}
			else
			{
				InfoManager.showTimed(_("Vous devez être connecté à Internet pour lancer un duel."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Duel launch callbacks
		
		/**
		 * We could find a duel on the server side.
		 */
		private function onDuelLaunchSuccess(result:Object):void
		{
			// FIXME DEBUG PURPOSE ONLY !
			
			result = {};
			result.id = 12345;
			result.reward = 40;
			result.challenger = {};
			result.challenger.nickname = "Challenger 1";
			result.challenger.facebookId = 123456789;
			result.challenger.trophiesCount = 150;
			
			// FIXME END OF DEBUG CODE
			
			InfoManager.forceClose();
			ScreenData.getInstance().gameData.parse(result);
			advancedOwner.replaceScreen(ScreenIds.GAME_SCREEN);
		}
		
		/**
		 * The duel could not be initialized
		 * @param error
		 */
		private function onDuelLaunchFail(error:Object):void
		{
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_headerContainer.removeFromParent(true);
			_headerContainer = null;
			
			_settingsButton.removeEventListener(Event.TRIGGERED, onShowSettings);
			_settingsButton.removeFromParent(true);
			_settingsButton = null;
			
			_highscoresRankingButton.removeEventListener(Event.TRIGGERED, onShowHighscoresRanking);
			_highscoresRankingButton.removeFromParent(true);
			_highscoresRankingButton = null;
			
			_trophiesRankingButton.removeEventListener(Event.TRIGGERED, onShowTrophiesRanking);
			_trophiesRankingButton.removeFromParent(true);
			_trophiesRankingButton = null;
			
			_trophiesButton.removeEventListener(Event.TRIGGERED, onShowTrophies);
			_trophiesButton.removeFromParent(true);
			_trophiesButton = null;
			
			_soloButton.removeEventListener(Event.TRIGGERED, onPlaySolo);
			_soloButton.removeFromParent(true);
			_soloButton = null;
			
			_duelButton.removeEventListener(Event.TRIGGERED, onPlayDuel);
			_duelButton.removeFromParent(true);
			_duelButton = null;
			
			super.dispose();
		}
	}
}