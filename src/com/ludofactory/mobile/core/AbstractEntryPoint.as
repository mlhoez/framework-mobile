/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 7 mars 2014
*/
package com.ludofactory.mobile.core
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.freshplanet.nativeExtensions.PushNotification;
	import com.freshplanet.nativeExtensions.PushNotificationEvent;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.logs.LogDisplayer;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.AdvancedScreenNavigator;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.push.PushManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.newClasses.GameChoiceScreen;
	import com.ludofactory.mobile.navigation.UpdateScreen;
	import com.ludofactory.mobile.navigation.account.MyAccountScreen;
	import com.ludofactory.mobile.navigation.achievements.GameCenterManager;
	import com.ludofactory.mobile.navigation.achievements.TrophyScreen;
	import com.ludofactory.mobile.navigation.ads.AdManager;
	import com.ludofactory.mobile.navigation.authentication.LoginScreen;
	import com.ludofactory.mobile.navigation.authentication.RegisterScreen;
	import com.ludofactory.mobile.navigation.authentication.SponsorScreen;
	import com.ludofactory.mobile.navigation.engine.FacebookEndScreen;
	import com.ludofactory.mobile.navigation.engine.HighScoreScreen;
	import com.ludofactory.mobile.navigation.engine.PodiumScreen;
	import com.ludofactory.mobile.navigation.engine.SoloEndScreen;
	import com.ludofactory.mobile.navigation.faq.FaqScreen;
	import com.ludofactory.mobile.navigation.highscore.HighScoreHomeScreen;
	import com.ludofactory.mobile.navigation.highscore.HighScoreListScreen;
	import com.ludofactory.mobile.navigation.home.OldHomeScreen;
	import com.ludofactory.mobile.navigation.news.CGUScreen;
	import com.ludofactory.mobile.navigation.sponsor.SponsorHomeScreen;
	import com.ludofactory.mobile.navigation.tournament.TournamentRankingScreen;
	import com.ludofactory.newClasses.HomeScreen;
	import com.ludofactory.newClasses.SplashScreen;
	import com.milkmangames.nativeextensions.CoreMobile;
	import com.milkmangames.nativeextensions.GoViral;
	import com.nl.funkymonkey.android.deviceinfo.NativeDeviceInfo;
	
	import feathers.system.DeviceCapabilities;
	
	import flash.filesystem.File;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	/**
	 * The Root class is the topmost display object in the game. It loads all the assets.
	 * Keep this class rather lightweight : it controls the high level behaviour of the game.
	 */	
	public class AbstractEntryPoint extends Sprite
	{
		
	//------ CONFIG
		
		/**
		 * The common screens used to navigate within the app. */
		protected static var SCREENS:Array = [  { id:ScreenIds.HOME_SCREEN, clazz:HomeScreen },
												{ id:ScreenIds.LOGIN_SCREEN, clazz:LoginScreen },
												{ id:ScreenIds.REGISTER_SCREEN, clazz:RegisterScreen },
												{ id:ScreenIds.NEW_HIGH_SCORE_SCREEN, clazz:HighScoreScreen },
												{ id:ScreenIds.SOLO_END_SCREEN, clazz:SoloEndScreen },
												{ id:ScreenIds.TOURNAMENT_RANKING_SCREEN, clazz:TournamentRankingScreen },
												{ id:ScreenIds.SPONSOR_REGISTER_SCREEN, clazz:SponsorScreen },
												{ id:ScreenIds.PODIUM_SCREEN, clazz:PodiumScreen },
												{ id:ScreenIds.TROPHY_SCREEN, clazz:TrophyScreen },
												{ id:ScreenIds.MY_ACCOUNT_SCREEN, clazz:MyAccountScreen },
												{ id:ScreenIds.FAQ_SCREEN, clazz:FaqScreen },
												{ id:ScreenIds.SPONSOR_HOME_SCREEN, clazz:SponsorHomeScreen },
												{ id:ScreenIds.HIGH_SCORE_LIST_SCREEN, clazz:HighScoreListScreen },
												{ id:ScreenIds.HIGH_SCORE_HOME_SCREEN, clazz:HighScoreHomeScreen },
												{ id:ScreenIds.FACEBOOK_END_SCREEN, clazz:FacebookEndScreen },
												{ id:ScreenIds.UPDATE_SCREEN, clazz:UpdateScreen },
												{ id:ScreenIds.GAME_CHOICE_SCREEN, clazz:GameChoiceScreen },
												{ id:ScreenIds.CGU_SCREEN, clazz:CGUScreen } ];
		
		/**
		 * The debug screens concatened to the SCREENS property when the app is in debug mode. */
		private static const DEBUG_SCREENS:Array = [  /*{ id:ScreenIds.DEBUG_SCREEN, clazz:DebugScreen }*/ ];
		
	//------ Assets
		
		/**
		 * The required assets to load for the app to work. Push more elements into this array
		 * in the subclass if needed by overridding the "loadAssets" function. */
		protected var _assetsToLoad:Array = [];
		/**
		 * The static asset manager */
		private static var _assets:AssetManager;
		
	//------ Others
		
		/**
		 * Splash screen animation used at the beginning of the app. */
		private var _splashScreenAnimation:SplashScreen;
		/**
		 * Screen navigator. */		
		protected static var _screenNavigator:AdvancedScreenNavigator;
		/**
		 * The push manager */		
		private static var _pushManager:PushManager;
		
		public function AbstractEntryPoint()
		{
			super();
		}
		
		/**
		 * Starts the application. This function is called by the Main.as class once Starling is
		 * ready and the root (this class) is created by Starling.
		 */		
		public function loadTheme(launchImageTexture:Texture):void
		{
			// FIXME Essayer de le laisser à 1 sur les vieux appareils : http://forum.starling-framework.org/topic/setting-the-root-alpha-to-0999
			this.alpha = 0.999; // http://wiki.starling-framework.org/manual/performance_optimization
			
			GlobalConfig.isPhone = DeviceCapabilities.isPhone( Starling.current.nativeStage );
			GlobalConfig.stageWidth = Starling.current.viewPort.width;
			GlobalConfig.stageHeight = Starling.current.viewPort.height;
			
			// splash screen is ready right away as the assets are embedded for a faster process
			_splashScreenAnimation = new SplashScreen(launchImageTexture);
			addChild(_splashScreenAnimation);
			
			loadAssets();
		}
		
		/**
		 * This function can be overridden in the subclass "AppEntryPoint" in order to add more app-specific
		 * assets to load.
		 */
		protected function loadAssets():void
		{
			// prepare assets to load
			_assetsToLoad.push(File.applicationDirectory.resolvePath("assets/ui/"));
			
			Starling.current.nativeStage.autoOrients = true; // why ?
			
			_assets = new AssetManager();
			_assets.verbose = CONFIG::DEBUG;
			_assets.enqueue( _assetsToLoad  );
			_assets.loadQueue(onLoadingUiProgress);
		}
		
		/**
		 * Loading progress of the user interface elements.
		 */		
		private function onLoadingUiProgress(ratio:Number):void
		{
			_splashScreenAnimation.setProgressBarValue(ratio);
			if(ratio == 1)
				onAssetsLoaded();
		}
		
		/**
		 * All assets are loaded, here we can initialize the theme and create all the stuff.
		 * 
		 * <p>Note that the theme must be created in the subclass. If there is a specific theme for the game,
		 * use CustomThemeName(), but if there is not, use Theme().</p>
		 */		
		protected function onAssetsLoaded():void
		{
			// initialize the application local storage
			Storage.getInstance().initialize();
			// initialize Game Center
			GameCenterManager.initialize();
			// initialize Ads
			AdManager.initialize();
			// initialize Popups
			CustomPopupManager.initializeBasePopup();
			
			// load common sounds
			var musicPath:String = File.applicationDirectory.resolvePath("assets/sounds/music/").url;
			var sfxPath:String = File.applicationDirectory.resolvePath("assets/sounds/sfx/").url;
			
			// default in framework
			SoundManager.getInstance().addSound("new-highscore", sfxPath + "/new-highscore.mp3", "sfx");
			SoundManager.getInstance().addSound("trophy-won", sfxPath + "/trophy-won.mp3", "sfx");
			
			// parse device info
			
			NativeDeviceInfo.parse();
			
			// controllers
			_pushManager = new PushManager();
			_pushManager.initialize();
			// TODO handle this properly for the new app
			//_pushManager.addEventListener(MobileEventTypes.UPDATE_HEADER, onPushUpdate);
			//_pushManager.addEventListener(MobileEventTypes.UPDATE_ALERT_CONTAINER_LIST, _alertContainer.updateList);
			
			// only supported on Android and iOS but we can create it here without having to check isSupported
			CoreMobile.create();
			
			if( GoViral.isSupported() )
			{
				GoViral.create();
				if( GoViral.goViral.isFacebookSupported() )
					GoViral.goViral.initFacebook(AbstractGameInfo.FACEBOOK_APP_ID);
			}
			
			if( !Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED)) )
				SoundManager.getInstance().mutePlaylist("sfx", 0);
			if( !Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED)) )
				SoundManager.getInstance().mutePlaylist("music", 0);
			
			initializeScreenNavigator();
			
			LanguageManager.getInstance().checkForUpdate(false);
			
			if( PushNotification.getInstance().isPushNotificationSupported && (Boolean(Storage.getInstance().getProperty( StorageConfig.PROPERTY_PUSH_INITIALIZED )) || GlobalConfig.android) )
			{
				// IMPORTANT ! : ajouter dans la condition (?) : ou si le membre est co et qu'il a activé les pushs sur un autre appareil
				// car si on reset le Storage, ça se mettra jamais à jour...
				// FIXME Gérer android
				PushNotification.getInstance().addEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
				PushNotification.getInstance().registerForPushNotification(AbstractGameInfo.GCM_SENDER_ID);
			}
			
			// check if the user has completed all the steps
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE)) == true )
			{
				// we requested the user to update the application, here we check if he did it
				if( Number(AbstractGameInfo.GAME_VERSION) > Number(Storage.getInstance().getProperty(StorageConfig.PROPERTY_GAME_VERSION)) )
				{
					// FIXME Si on downgrade le numéro de version en base, gérer le cas pour réactiver l'appli peut être
					
					// the actual game version is higher than the old one stored when the update was requested
					// them we can disable the force update because it means that the user updated the game
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE, false);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK, ""); // reset it
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_TEXT, ""); // reset it
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_BUTTON_NAME, ""); // reset it
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_GAME_VERSION, AbstractGameInfo.GAME_VERSION);
					_screenNavigator.replaceScreen(ScreenIds.HOME_SCREEN);
				}
				else
				{
					_screenNavigator.replaceScreen(ScreenIds.UPDATE_SCREEN);
				}
			}
			else
			{
				_screenNavigator.replaceScreen(ScreenIds.HOME_SCREEN);
			}
			
			// everything is ready, we can remove the splash elements and loading bar
			removeSplashElements();
		}
		
		/**
		 * Initializes the screen navigator.
		 * 
		 * <p>Override this method to add the GameScreen of the
		 * current project and any additional screens.</p>
		 */		
		protected function initializeScreenNavigator():void
		{
			// concat debug screens
			SCREENS = SCREENS.concat(DEBUG_SCREENS);
			
			_screenNavigator = new AdvancedScreenNavigator();
			_screenNavigator.addScreensFromArray(SCREENS);
			//_screenNavigator.clipContent = true;
			_screenNavigator.rootScreenID = ScreenIds.HOME_SCREEN;
			_screenNavigator.width = GlobalConfig.stageWidth;
			_screenNavigator.height = GlobalConfig.stageHeight;
			addChildAt(_screenNavigator, 0);
		}
		
		/**
		 * Removes all the splash elements.
		 */		
		private function removeSplashElements():void
		{
			Starling.juggler.tween(_splashScreenAnimation, 0.75, { alpha:0, onComplete:function():void{
				_splashScreenAnimation.removeFromParent(true);
			} });
			
			GameCenterManager.authenticateUser();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Header / Footer functions
		
		/**
		 * When the back button is touched, we check if a callback function have been
		 * defined and if so, we execute it.
		 */		
		private function onBackButtonTouched(event:Event):void
		{
			// FIXME mettre ça directement dans le listener ?
			AdvancedScreen(_screenNavigator.activeScreen).onBack();
		}
		
		/**
		 * The news button was touched.
		 */		
		private function onNewsButtonTouched(event:Event):void
		{
			_screenNavigator.replaceScreen( ScreenIds.NEWS_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Push Notifications
		
		/**
		 * The permission have been given, let's send the token to
		 * our server if connected to Internet.
		 */		
		private function onPermissionGiven(event:PushNotificationEvent):void
		{
			PushNotification.getInstance().removeEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
			if( AirNetworkInfo.networkInfo.isConnected() )
				Remote.getInstance().updatePushToken(event.token, null, null, null, 2);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Logs
		
		private var _areLogsShowing:Boolean = false;
		
		public function showOrHideLogs():void
		{
			_areLogsShowing ? hideLogs() : showLogs();
		}
		
		/**
		 * 
		 */
		public function showLogs():void
		{
			if( !_areLogsShowing )
			{
				addChild(LogDisplayer.getInstance());
				LogDisplayer.getInstance().enable();
				_areLogsShowing = true;
			}
		}
		
		/**
		 * 
		 */
		public function hideLogs():void
		{
			if( _areLogsShowing )
			{
				removeChild(LogDisplayer.getInstance());
				LogDisplayer.getInstance().disable();
				_areLogsShowing = false;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		public static function get assets():AssetManager { return _assets; }
		public static function get pushManager():PushManager { return _pushManager; }
		public static function get screenNavigator():AdvancedScreenNavigator { return _screenNavigator; }
		
	}
}