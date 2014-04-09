/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 7 mars 2014
*/
package com.ludofactory.mobile.core
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.freshplanet.nativeExtensions.PushNotification;
	import com.freshplanet.nativeExtensions.PushNotificationEvent;
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.hasoffers.nativeExtensions.MobileAppTracker;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.authentication.AuthenticationManager;
	import com.ludofactory.mobile.core.authentication.AuthenticationScreen;
	import com.ludofactory.mobile.core.authentication.ForgotPasswordScreen;
	import com.ludofactory.mobile.core.authentication.LoginScreen;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.authentication.PseudoChoiceScreen;
	import com.ludofactory.mobile.core.authentication.RegisterCompleteScreen;
	import com.ludofactory.mobile.core.authentication.RegisterScreen;
	import com.ludofactory.mobile.core.authentication.SponsorScreen;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.AdvancedScreenNavigator;
	import com.ludofactory.mobile.core.controls.Footer;
	import com.ludofactory.mobile.core.controls.Header;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.display.TiledBackground;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.shop.BoutiqueHomeScreen;
	import com.ludofactory.mobile.core.shop.bid.BidHomeScreen;
	import com.ludofactory.mobile.core.shop.vip.BoutiqueCategoryScreen;
	import com.ludofactory.mobile.core.shop.vip.BoutiqueSubCategoryScreen;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.HowToWinGiftsScreen;
	import com.ludofactory.mobile.core.test.UpdateScreen;
	import com.ludofactory.mobile.core.test.account.MyAccountScreen;
	import com.ludofactory.mobile.core.test.account.history.gifts.MyGiftsScreen;
	import com.ludofactory.mobile.core.test.achievements.GameCenterManager;
	import com.ludofactory.mobile.core.test.achievements.TrophyScreen;
	import com.ludofactory.mobile.core.test.ads.AdManager;
	import com.ludofactory.mobile.core.test.alert.AlertContainer;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.cs.HelpScreen;
	import com.ludofactory.mobile.core.test.cs.thread.CSThreadScreen;
	import com.ludofactory.mobile.core.test.engine.FacebookEndScreen;
	import com.ludofactory.mobile.core.test.engine.FreeGameEndScreen;
	import com.ludofactory.mobile.core.test.engine.HighScoreScreen;
	import com.ludofactory.mobile.core.test.engine.PodiumScreen;
	import com.ludofactory.mobile.core.test.engine.SmallRulesScreen;
	import com.ludofactory.mobile.core.test.engine.TournamentEndScreen;
	import com.ludofactory.mobile.core.test.event.EventManager;
	import com.ludofactory.mobile.core.test.faq.FaqScreen;
	import com.ludofactory.mobile.core.test.game.GamePriceSelectionScreen;
	import com.ludofactory.mobile.core.test.game.GameTypeSelectionManager;
	import com.ludofactory.mobile.core.test.highscore.HighScoreHomeScreen;
	import com.ludofactory.mobile.core.test.highscore.HighScoreListScreen;
	import com.ludofactory.mobile.core.test.home.AlertData;
	import com.ludofactory.mobile.core.test.home.HomeScreen;
	import com.ludofactory.mobile.core.test.home.RulesAndScoresScreen;
	import com.ludofactory.mobile.core.test.news.CGUScreen;
	import com.ludofactory.mobile.core.test.news.NewsScreen;
	import com.ludofactory.mobile.core.test.push.PushManager;
	import com.ludofactory.mobile.core.test.settings.SettingsScreen;
	import com.ludofactory.mobile.core.test.sponsor.SponsorHomeScreen;
	import com.ludofactory.mobile.core.test.sponsor.filleuls.FilleulsScreen;
	import com.ludofactory.mobile.core.test.sponsor.invite.SponsorInviteScreen;
	import com.ludofactory.mobile.core.test.store.StoreScreen;
	import com.ludofactory.mobile.core.test.tournament.PreviousTournamentsScreen;
	import com.ludofactory.mobile.core.test.tournament.PreviousTournementDetailScreen;
	import com.ludofactory.mobile.core.test.tournament.TournamentRankingScreen;
	import com.ludofactory.mobile.core.test.vip.VipScreen;
	import com.ludofactory.mobile.core.test.vip.VipUpScreen;
	import com.ludofactory.mobile.debug.DebugScreen;
	import com.ludofactory.mobile.navigation.menu.Menu;
	import com.milkmangames.nativeextensions.GoViral;
	import com.nl.funkymonkey.android.deviceinfo.NativeDeviceInfo;
	import com.nl.funkymonkey.android.deviceinfo.NativeDeviceProperties;
	import com.nl.funkymonkey.android.deviceinfo.NativeDevicePropertiesData;
	
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import eu.alebianco.air.extensions.analytics.Analytics;
	import eu.alebianco.air.extensions.analytics.api.ITracker;
	
	import feathers.controls.Drawers;
	import feathers.controls.ImageLoader;
	import feathers.controls.ProgressBar;
	import feathers.display.Scale9Image;
	import feathers.events.FeathersEventType;
	import feathers.motion.transitions.ScreenFadeTransitionManager;
	import feathers.system.DeviceCapabilities;
	import feathers.textures.Scale9Textures;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
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
//------------------------------------------------------------------------------------------------------------
//	Loading elements
		
		/**
		 * Loading background. */		
		private var _loadingBackground:Image;
		/**
		 * Loading logo (Ludokado) */		
		private var _loadingLogo:ImageLoader;
		/**
		 * Progress bar. */		
		private var _progressBar:ProgressBar;
		/**
		 * Orange background. */		
		private var _orangeBackground:Image;
		
//------------------------------------------------------------------------------------------------------------
//	Google Analytics tracker
		
		/**
		 * Google Analytics Tracker */		
		private static var _tracker:ITracker;
		
//------------------------------------------------------------------------------------------------------------
//	Backgrounds
		
		/**
		 * Application clear background */		
		private var _appClearBackground:Image;
		/**
		 * Application dark background */		
		private var _appDarkBackground:Image;
		/**
		 * Tiled background */		
		private var _whiteBackground:TiledBackground;
		/**
		 * Tiled background */		
		private var _blueBackground:TiledBackground;
		/**
		 * Tiled background */		
		private var _howToWinGiftsBackground:Image;
		
//------------------------------------------------------------------------------------------------------------
//	
		
		// TODO Checker RegisterScreen
		/**
		 * The common screens used to navigate within the app. */		
		protected static var SCREENS:Array = [  { id:ScreenIds.HOME_SCREEN, clazz:HomeScreen },
												{ id:ScreenIds.LOGIN_SCREEN, clazz:LoginScreen },
												{ id:ScreenIds.REGISTER_SCREEN, clazz:RegisterScreen },
												{ id:ScreenIds.REGISTER_COMPLETE_SCREEN, clazz:RegisterCompleteScreen },
												{ id:ScreenIds.PSEUDO_CHOICE_SCREEN, clazz:PseudoChoiceScreen },
												{ id:ScreenIds.FORGOT_PASSWORD_SCREEN, clazz:ForgotPasswordScreen },
												{ id:ScreenIds.SMALL_RULES_SCREEN, clazz:SmallRulesScreen },
												{ id:ScreenIds.NEW_HIGH_SCORE_SCREEN, clazz:HighScoreScreen },
												{ id:ScreenIds.FREE_GAME_END_SCREEN, clazz:FreeGameEndScreen },
												{ id:ScreenIds.GAME_TYPE_SELECTION_SCREEN, clazz:GamePriceSelectionScreen },
												{ id:ScreenIds.TOURNAMENT_RANKING_SCREEN, clazz:TournamentRankingScreen },
												{ id:ScreenIds.SPONSOR_REGISTER_SCREEN, clazz:SponsorScreen },
												{ id:ScreenIds.RULES_AND_SCORES_SCREEN, clazz:RulesAndScoresScreen },
												{ id:ScreenIds.PODIUM_SCREEN, clazz:PodiumScreen },
												{ id:ScreenIds.TOURNAMENT_GAME_END_SCREEN, clazz:TournamentEndScreen },
												{ id:ScreenIds.BOUTIQUE_HOME, clazz:BoutiqueHomeScreen },
												{ id:ScreenIds.BOUTIQUE_CATEGORY_LISTING, clazz:BoutiqueCategoryScreen },
												{ id:ScreenIds.BOUTIQUE_SUB_CATEGORY_LISTING, clazz:BoutiqueSubCategoryScreen },
												{ id:ScreenIds.HELP_HOME_SCREEN, clazz:HelpScreen },
												{ id:ScreenIds.CUSTOMER_SERVICE_THREAD_SCREEN, clazz:CSThreadScreen },
												{ id:ScreenIds.BIDS_HOME_SCREEN, clazz:BidHomeScreen },
												{ id:ScreenIds.TROPHY_SCREEN, clazz:TrophyScreen },
												{ id:ScreenIds.MY_ACCOUNT_SCREEN, clazz:MyAccountScreen },
												{ id:ScreenIds.FAQ_SCREEN, clazz:FaqScreen },
												{ id:ScreenIds.VIP_SCREEN, clazz:VipScreen },
												{ id:ScreenIds.SPONSOR_HOME_SCREEN, clazz:SponsorHomeScreen },
												{ id:ScreenIds.SPONSOR_INVITE_SCREEN, clazz:SponsorInviteScreen },
												{ id:ScreenIds.PREVIOUS_TOURNAMENTS_SCREEN, clazz:PreviousTournamentsScreen },
												{ id:ScreenIds.PREVIOUS_TOURNAMENTS_DETAIL_SCREEN, clazz:PreviousTournementDetailScreen },
												{ id:ScreenIds.MY_GIFTS_SCREEN, clazz:MyGiftsScreen },
												{ id:ScreenIds.HIGH_SCORE_LIST_SCREEN, clazz:HighScoreListScreen },
												{ id:ScreenIds.NEWS_SCREEN, clazz:NewsScreen },
												{ id:ScreenIds.STORE_SCREEN, clazz:StoreScreen },
												{ id:ScreenIds.HOW_TO_WIN_GIFTS_SCREEN, clazz:HowToWinGiftsScreen },
												{ id:ScreenIds.SETTINGS_SCREEN, clazz:SettingsScreen },
												{ id:ScreenIds.SPONSOR_FRIENDS_SCREEN, clazz:FilleulsScreen },
												{ id:ScreenIds.HIGH_SCORE_HOME_SCREEN, clazz:HighScoreHomeScreen },
												{ id:ScreenIds.AUTHENTICATION_SCREEN, clazz:AuthenticationScreen },
												{ id:ScreenIds.FACEBOOK_END_SCREEN, clazz:FacebookEndScreen },
												{ id:ScreenIds.UPDATE_SCREEN, clazz:UpdateScreen },
												{ id:ScreenIds.VIP_UP_SCREEN, clazz:VipUpScreen },
												{ id:ScreenIds.CGU_SCREEN, clazz:CGUScreen } ];
		
		/**
		 * The debug screens concatened to SCREEN when the app is in debug mode. */		
		private static const DEBUG_SCREENS:Array = [  { id:ScreenIds.DEBUG_SCREEN, clazz:DebugScreen } ];
		
		/**
		 * The main container used by the Drawer. */		
		private static var _container:Sprite;
		/**
		 * The drawer for the alert container. */		
		private var _drawer:Drawers;
		/**
		 * The header. */		
		private static var _header:Header;
		/**
		 * Screen navigator. */		
		protected static var _screenNavigator:AdvancedScreenNavigator;
		/**
		 * Screen transition. */		
		private var _transitionManager:ScreenFadeTransitionManager;
		/**
		 * The footer */		
		private static var _footer:Footer;
		/**
		 * The shadow displayed beside the AlertContainer */		
		private var _shadow:Quad;
		
		/**
		 * The assets to load after the loading of the splash
		 * elements is complete. Push element into this array
		 * in the subclass if needed. */		
		protected var _assetsToLoad:Array;
		
		
		/**
		 * The static asset manager */		
		private static var _assets:AssetManager;
		
		/**
		 *  */		
		private static var _isSelectingPseudo:Boolean = false;
		
		/**
		 *  */		
		private static var _gameTypeSelectionManager:GameTypeSelectionManager;
		
//------------------------------------------------------------------------------------------------------------
//	Managers
		
		/**
		 * The push manager */		
		private static var _pushManager:PushManager;
		
		/**
		 * The alert data. */		
		private static var _alertData:AlertData;
		/**
		 * The alert container. */		
		private var _alertContainer:AlertContainer;
		
		/**
		 * Used to retrieve and display events. */		
		private var _eventManager:EventManager;
		
		
		public function AbstractEntryPoint()
		{
			super();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Loading progress
		
		/**
		 * Starts the application. This function is called by the Main.as class once
		 * the root (this class) is created by Starling.
		 */		
		public function loadTheme(launchImageTexture:Texture):void
		{
			// FIXME Essayer de le laisser à 1 sur les vieux appareils : http://forum.starling-framework.org/topic/setting-the-root-alpha-to-0999
			this.alpha = 0.999; // http://wiki.starling-framework.org/manual/performance_optimization
			
			GlobalConfig.stageWidth = Starling.current.viewPort.width;
			GlobalConfig.stageHeight = Starling.current.viewPort.height;
			
			if( launchImageTexture )
			{
				// there is a launchImageTexture when we test on a device
				// (it is the reference to the splash screen)
				_loadingBackground = new Image( launchImageTexture );
				_loadingBackground.width = GlobalConfig.stageWidth;
				_loadingBackground.height = GlobalConfig.stageHeight;
				addChild( _loadingBackground );
			}
			
			_assets = new AssetManager();
			_assets.verbose = GlobalConfig.DEBUG;
			_assets.enqueue( File.applicationDirectory.resolvePath("assets/splash/") );
			_assets.loadQueue(onLoadingSplash);
		}
		
		/**
		 * Loading progress of the splash screen elements (background, progress bar
		 * and logo). When the loading is finished, we create the progress bar and
		 * start loading the ui elements.
		 */		
		private function onLoadingSplash(ratio:Number):void
		{
			if( ratio == 1 )
			{
				_progressBar = new ProgressBar();
				_progressBar.backgroundSkin = new Scale9Image( new Scale9Textures(_assets.getTexture("progress-bar-background"), new Rectangle(9, 8, 12, 1)) );
				_progressBar.fillSkin = new Scale9Image( new Scale9Textures(_assets.getTexture("progress-bar-fill"), new Rectangle(9, 8, 12, 1)) );
				_progressBar.width = GlobalConfig.stageWidth * 0.7;
				_progressBar.x = GlobalConfig.stageWidth * 0.15;
				_progressBar.y = GlobalConfig.stageHeight * 0.9;
				addChild(_progressBar);
				
				_assetsToLoad = [ File.applicationDirectory.resolvePath("assets/ui/") ];
				
				loadAssets();
			}
		}
		
		protected function loadAssets():void
		{
			_assets.enqueue( _assetsToLoad  );
			_assets.loadQueue(onLoadingUiProgress);
		}
		
		/**
		 * Loading progress of the user interface elements.
		 */		
		private function onLoadingUiProgress(ratio:Number):void
		{
			_progressBar.value = ratio;
			if(ratio == 1)
				onAssetsLoaded();
		}
		
		/**
		 * All assets are loaded, here we can initialize the theme
		 * and create all the stuff.
		 * 
		 * <p>Note that the theme must be created in the subclass.
		 * If there is a specific theme for the game, use 
		 * CustomThemeName(), but if there is not, use Theme().</p>
		 */		
		protected function onAssetsLoaded():void
		{
			Storage.getInstance().initialize();
			// initialize Game Center
			GameCenterManager.initialize();
			// initialize Ads
			AdManager.initialize();
			
			try
			{
				MobileAppTracker.instance.init(AbstractGameInfo.HAS_OFFERS_ADVERTISER_ID, AbstractGameInfo.HAS_OFFERS_CONVERSION_KEY);
				
				if( GlobalConfig.DEBUG )
				{
					MobileAppTracker.instance.setDebugMode(true);
					MobileAppTracker.instance.setAllowDuplicates(true);
				}
				
				//MobileAppTracker.instance.setUserId(GlobalConfig.deviceId);
				MobileAppTracker.instance.trackInstall(); // track install (or update)
				MobileAppTracker.instance.trackAction("open"); // track daily open
			} 
			catch(error:Error) 
			{
				
			}
			
			if( Analytics.isSupported() )
			{
				_tracker = Analytics.getInstance().getTracker(AbstractGameInfo.GOOGLE_ANALYTICS_TRACKER);
				_tracker.appID = AbstractGameInfo.GAME_BUNDLE_ID;
				_tracker.appName = AbstractGameInfo.GAME_NAME;
				_tracker.appVersion = AbstractGameInfo.GAME_VERSION;
			}
			
			GlobalConfig.isPhone = DeviceCapabilities.isPhone( Starling.current.nativeStage );
			if( GlobalConfig.android )
			{
				// only for android
				try
				{
					// just in case
					NativeDeviceInfo.parse();
					
					log("<strong>Device informations :</strong><tr style='font-weight:bold;'>" +
							"<td style='width: 148px; color: black; text-align: right;'><strong>Device details :</strong></td>" +
							"<td style='word-break: break-all;'>" + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BRAND).value +  " " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MODEL).value + " (" + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_NAME).value + ")</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
							"<td />" + 
							"<td style='word-break: break-all;'>Manufactured by " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MANUFACTURER).value + "</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
							"<td style='width: 148px; color: black; text-align: right;'><strong>OS details :</strong></td>" +
							"<td style='word-break: break-all;'>" + NativeDevicePropertiesData(NativeDeviceProperties.OS_NAME).value + ((GlobalConfig.android || GlobalConfig.ios) ? "" : "(Simulateur)") + " sur " + (GlobalConfig.isPhone ? "Smartphone" : "Tablette") + "</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
							"<td />" + 
							"<td style='word-break: break-all;'>OS version " + NativeDevicePropertiesData(NativeDeviceProperties.OS_VERSION).value + " (Build : " + NativeDevicePropertiesData(NativeDeviceProperties.OS_BUILD).value + ")</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
							"<td />" + 
							"<td style='word-break: break-all;'>SDK version " + NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_VERSION).value + " (" + NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_DESCRIPTION).value + ")</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
							"<td style='width: 148px; color: black; text-align: right;'><strong>Screen details :</strong></td>" +
							"<td style='word-break: break-all;'>Density " + NativeDevicePropertiesData(NativeDeviceProperties.LCD_DENSITY).value + " dpi - résolution " + Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY + "</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
							"<td style='width: 148px; color: black; text-align: right;'><strong>Other details :</strong></td>" +
							"<td style='word-break: break-all;'>Board : " +  NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BOARD).value + "</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
							"<td />" + 
							"<td style='word-break: break-all;'>CPU : " +  NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_CPU).value + "</td>" +
						"<tr style='font-weight:bold;'>" +
							"<td />" + 
							"<td style='word-break: break-all;'>OpenGL ES version " +  NativeDevicePropertiesData(NativeDeviceProperties.OPENGLES_VERSION).value + "</td>" +
						"<tr style='font-weight:bold;'>" +
							"<td />" + 
							"<td style='word-break: break-all;'>Heap size : " +  NativeDevicePropertiesData(NativeDeviceProperties.DALVIK_HEAPSIZE).value + "</td>" +
						"</tr>"
					);
				} 
				catch(error:Error) 
				{
					Flox.logWarning("Impossible de parser le fichier build.prop du téléphone.");
					Flox.logInfo("Type d'appareil : <strong>{0} sur {1}</strong>", (GlobalConfig.isPhone ? "Smartphone" : "Tablette"), (GlobalConfig.ios ? "iOS" : (GlobalConfig.android ? "Android" : "Simulateur")));
				}
			}
			else
			{
				// for ios
				Flox.logInfo("Type d'appareil : <strong>{0} sur {1}</strong>", (GlobalConfig.isPhone ? "Smartphone" : "Tablette"), (GlobalConfig.ios ? "iOS" : (GlobalConfig.android ? "Android" : "Simulateur")));
			}
			
			_alertData = new AlertData();
			_alertData.addEventListener(LudoEventType.ALERT_COUNT_UPDATED, onPushUpdate);
			
			_container = new Sprite();
			
			initializeBackgrounds();
			
			_alertContainer = new AlertContainer();
			_alertContainer.addEventListener(LudoEventType.OPEN_ALERTS, onAlertButtonTouched);
			addChild(_alertContainer);
			
			// controllrs
			_pushManager = new PushManager();
			_pushManager.addEventListener(LudoEventType.UPDATE_HEADER, onPushUpdate);
			_pushManager.addEventListener(LudoEventType.UPDATE_ALERT_CONTAINER_LIST, _alertContainer.updateList);
			
			
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
			
			_drawer = new Drawers( _container );
			_drawer.rightDrawer = _alertContainer;
			_drawer.autoSizeMode = Drawers.AUTO_SIZE_MODE_CONTENT;
			_drawer.openOrCloseDuration = 0.5;
			_drawer.rightDrawerToggleEventType = LudoEventType.OPEN_ALERTS;
			_drawer.addEventListener(FeathersEventType.BEGIN_INTERACTION, onStartInteractWithDrawer);
			_drawer.openGesture = Drawers.OPEN_GESTURE_NONE;
			addChild(_drawer);
			
			_transitionManager = new ScreenFadeTransitionManager( _screenNavigator );
			_transitionManager.duration = .5;
			
			// Header
			_header = new Header();
			_header.addEventListener(LudoEventType.OPEN_ALERTS, onAlertButtonTouched);
			_container.addChild(_header);
			
			_footer = new Footer();
			_footer.addEventListener(LudoEventType.MAIN_MENU_TOUCHED, onMenuButtonTouched);
			_footer.addEventListener(LudoEventType.BACK_BUTTON_TOUCHED, onBackButtonTouched);
			_footer.addEventListener(LudoEventType.NEWS_BUTTON_TOUCHED, onNewsButtonTouched);
			_container.addChild(_footer);
			
			_shadow = new Quad(scaleAndRoundToDpi(10), 5, 0x000000);
			_shadow.touchable = false;
			_shadow.visible = false;
			_shadow.setVertexAlpha(0, 0.4);
			_shadow.setVertexAlpha(2, 0.4);
			_shadow.setVertexAlpha(1, 0.1);
			_shadow.setVertexColor(1, 0xffffff);
			_shadow.setVertexAlpha(3, 0.1);
			_shadow.setVertexColor(3, 0xffffff);
			_container.addChild(_shadow);
			
			MemberManager.getInstance().addEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateSummary);
			Remote.getInstance().addEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateSummary);
			
			if( PushNotification.getInstance().isPushNotificationSupported && (Boolean(Storage.getInstance().getProperty( StorageConfig.PROPERTY_PUSH_INITIALIZED )) || GlobalConfig.android) )
			{
				// IMPORTANT ! : ajouter dans la condition (?) : ou si le membre est co et qu'il a activé les pushs sur un autre appareil
				// car si on reset le Storage, ça se mettra jamais à jour...
				// FIXME Gérer android
				PushNotification.getInstance().addEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
				PushNotification.getInstance().registerForPushNotification(AbstractGameInfo.GCM_SENDER_ID);
			}
			
			_eventManager = new EventManager();
			_gameTypeSelectionManager = new GameTypeSelectionManager(this);
			
			// check if the user has completed all the steps
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE)) == true )
			{
				// we requested the user to update the application, here we check if he did it
				if( Number(AbstractGameInfo.GAME_VERSION) > Number(Storage.getInstance().getProperty(StorageConfig.PROPERTY_GAME_VERSION)) )
				{
					// the actual game version is higher than the old one stored when the update was requested
					// them we can disable the force update because it means that the user updated the game
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE, false);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_GAME_VERSION, AbstractGameInfo.GAME_VERSION);
					_screenNavigator.showScreen(ScreenIds.HOME_SCREEN);
				}
				else
				{
					_screenNavigator.showScreen(ScreenIds.UPDATE_SCREEN);
				}
			}
			else
			{
				if( MemberManager.getInstance().isLoggedIn() )
				{
					AuthenticationManager.startAuthenticationProcess(_screenNavigator, ScreenIds.HOME_SCREEN);
				}
				else
				{
					_screenNavigator.showScreen(ScreenIds.HOME_SCREEN);
				}
			}
			
			layout();
		}
		
		/**
		 * Initializes all the backgrounds.
		 */		
		protected function initializeBackgrounds():void
		{
			_whiteBackground = new TiledBackground( TiledBackground.WHITE_BACKGROUND );
			_whiteBackground.touchable = _whiteBackground.visible = false;
			_container.addChild( _whiteBackground );
			
			_blueBackground = new TiledBackground( TiledBackground.BLUE_BACKGROUND );
			_blueBackground.touchable = _blueBackground.visible = false;
			_container.addChild( _blueBackground );
			
			_appDarkBackground = new Image( _assets.getTexture("dark-background") );
			_appDarkBackground.touchable = _appDarkBackground.visible = false;
			_container.addChild(_appDarkBackground);
			
			_howToWinGiftsBackground = new Image( _assets.getTexture("how-to-win-gifts-background") );
			_howToWinGiftsBackground.touchable = _howToWinGiftsBackground.visible = false;
			_container.addChild(_howToWinGiftsBackground);
			
			_appClearBackground = new Image( _assets.getTexture("clear-background") );
			_appClearBackground.touchable = _appClearBackground.visible = false;
			_container.addChild(_appClearBackground);
		}
		
		/**
		 * Initializes the screen navigator.
		 * 
		 * <p>Override this method to add the GameScreen of the
		 * current project and any additional screens.</p>
		 */		
		protected function initializeScreenNavigator():void
		{
			_screenNavigator = new AdvancedScreenNavigator();
			if( GlobalConfig.DEBUG ) SCREENS = SCREENS.concat(DEBUG_SCREENS);
			_screenNavigator.addScreensFromArray(SCREENS);
			_screenNavigator.addEventListener(FeathersEventType.TRANSITION_START, onScreenTransitionStarted);
			//_screenNavigator.addEventListener(FeathersEventType.TRANSITION_COMPLETE, onScreenTransitionComplete);
			_screenNavigator.addEventListener(LudoEventType.UPDATE_HEADER_TITLE, onUpdateHeaderTitle);
			_screenNavigator.addEventListener(LudoEventType.SHOW_MAIN_MENU, onMenuButtonTouched);
			_screenNavigator.addEventListener(LudoEventType.HIDE_MAIN_MENU, hideMenu);
			_screenNavigator.addEventListener(LudoEventType.ANIMATE_SUMMARY, onAnimateSummary);
			_screenNavigator.addEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateSummary);
			//_screenNavigator.clipContent = true;
			_container.addChild(_screenNavigator);
		}
		
		/**
		 * Layout
		 */		
		private function layout():void
		{
			_drawer.width = _appClearBackground.width = _appDarkBackground.width = _howToWinGiftsBackground.width = _whiteBackground.width = _blueBackground.width = GlobalConfig.stageWidth;
			_drawer.height = _appClearBackground..height = _appDarkBackground.height = _howToWinGiftsBackground.height = _whiteBackground.height = _blueBackground.height = GlobalConfig.stageHeight;
			
			_alertContainer.width = GlobalConfig.stageWidth * 0.8;
			_alertContainer.height = GlobalConfig.stageHeight;
			_alertContainer.x = GlobalConfig.stageWidth - _alertContainer.width;
			
			_shadow.x = GlobalConfig.stageWidth;
			_shadow.height = GlobalConfig.stageHeight;
			
			_footer.width = GlobalConfig.stageWidth;
			_footer.y = GlobalConfig.stageHeight - _footer.height;
			
			_header.width = GlobalConfig.stageWidth;
			
			_screenNavigator.y =  _header.height;
			_screenNavigator.height = GlobalConfig.stageHeight - _header.height - _footer.height;
			
			_pushManager.initialize();
			
			if( _loadingBackground )
				setChildIndex(_loadingBackground, numChildren);
			
			if( _progressBar )
				setChildIndex(_progressBar, numChildren);
			
			_progressBar.visible = false;
			
			if( GlobalConfig.ios || GlobalConfig.android )
				Starling.juggler.delayCall(animateIn, 2);
			else
				removeSplashElements();
		}
		
		
		/**
		 * Once everything have been created and positioned, we play
		 * the animation of the splash elements which is a simple
		 * fade in and out of the elements.
		 */		
		private function animateIn():void
		{
			_orangeBackground = new Image(_assets.getTexture("orange-background"));
			_orangeBackground.width = GlobalConfig.stageWidth;
			_orangeBackground.height = GlobalConfig.stageHeight;
			_orangeBackground.alpha = 0;
			addChild( _orangeBackground );
			
			_loadingLogo = new ImageLoader();
			_loadingLogo.source = _assets.getTexture("splash-logo");
			_loadingLogo.textureScale = GlobalConfig.dpiScale;
			_loadingLogo.snapToPixels = true;
			_loadingLogo.alpha = 0;
			addChild( _loadingLogo );
			_loadingLogo.width = GlobalConfig.stageWidth * (GlobalConfig.isPhone ? 0.85 : 0.75);
			_loadingLogo.validate();
			_loadingLogo.x = ((GlobalConfig.stageWidth - _loadingLogo.width) * 0.5) << 0;
			_loadingLogo.y = ((GlobalConfig.stageHeight - _loadingLogo.height) * 0.5) << 0;
			
			// TODO Tester :
			
			/*
			
				_loadingLogo.alignPivot();
				_loadingLogo.width = GlobalConfig.stageWidth * (GlobalConfig.isPhone ? 0.85 : 0.75);
				_loadingLogo.x = (GlobalConfig.stageWidth * 0.5) << 0;
				_loadingLogo.y = (GlobalConfig.stageHeight * 0.5) << 0;
			
			*/
			
			Starling.juggler.tween(_loadingLogo, 1, { alpha:1 });
			Starling.juggler.tween(_orangeBackground, 1, { alpha:1, onComplete:animateOut });
		}
		
		/**
		 * Animates the splash elements, a simple fade out.
		 */		
		private function animateOut():void
		{
			// removing the splash image and the progress bar
			if( _loadingBackground )
			{
				_loadingBackground.removeFromParent(true);
				_loadingBackground = null;
			}
			
			if( _progressBar )
			{
				_progressBar.removeFromParent(true);
				_progressBar = null;
			}
			
			Starling.juggler.tween(_loadingLogo, 1, { delay:1, alpha:0 });
			Starling.juggler.tween(_orangeBackground, 1, { delay:1, alpha:0, onComplete:removeSplashElements });
		}
		
		/**
		 * Removes all the splash elements (orange background and
		 * logo), unload the texture atlas, then show an interstital
		 * ad if needed, renew Facebook session and start the Game
		 * Center if on iOS.
		 */		
		private function removeSplashElements():void
		{
			if( _orangeBackground )
			{
				_orangeBackground.removeFromParent(true);
				_orangeBackground = null;
			}
			
			if( _loadingLogo )
			{
				_loadingLogo.removeFromParent(true);
				_loadingLogo = null;
			}
			
			_assets.removeTextureAtlas("splash");
			
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_DISPLAY_ADS) == true )
				AdManager.showInterstitial();
			
			if( GoViral.isSupported() && GoViral.goViral.isFacebookSupported() && MemberManager.getInstance().getFacebookId() != 0 && !GoViral.goViral.isFacebookAuthenticated() )
				GoViral.goViral.authenticateWithFacebook( AbstractGameInfo.FACEBOOK_PERMISSIONS );
			
			GameCenterManager.authenticateUser();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Screen Management
		
		/**
		 * When the transition is complete, we need to set the blendMode of each
		 * background to NONE to improve performances.
		 */		
		private function onScreenTransitionComplete(event:starling.events.Event):void
		{
			//_appClearBackground.blendMode = _appDarkBackground.blendMode = _whiteBackground.blendMode =
			//	_howToWinGiftsBackground.blendMode = _blueBackground.blendMode = BlendMode.NONE;
		}
		
		/**
		 * When the screen transition starts.
		 */		
		private function onScreenTransitionStarted(event:starling.events.Event):void
		{
			hideMenu();
			onResize();
			
			if( _drawer.isRightDrawerOpen )
				_drawer.toggleRightDrawer();
			
			// update the badges
			if( AirNetworkInfo.networkInfo.isConnected() && MemberManager.getInstance().isLoggedIn() && _screenNavigator.activeScreenID == ScreenIds.HOME_SCREEN )
				Remote.getInstance().getAlerts(onGetAlertsSuccess, null, null, 1);
			
			if( _screenNavigator.activeScreenID == ScreenIds.HOME_SCREEN )
				_eventManager.getEvent();
			
			_header.setTitle( AdvancedScreen(_screenNavigator.activeScreen).headerTitle );
			_footer.displayNewsIcon( _screenNavigator.activeScreenID == ScreenIds.HOME_SCREEN );
			
			_shadow.visible = _drawer.openGesture == Drawers.OPEN_GESTURE_NONE ? false : true;
			
			if( _screenNavigator.activeScreenID == ScreenIds.GAME_SCREEN)
			{
				_appClearBackground.visible = _appDarkBackground.visible = _whiteBackground.visible =
					_howToWinGiftsBackground.visible = _blueBackground.visible = false;
				_appClearBackground.alpha = _appDarkBackground.alpha = _whiteBackground.alpha = 
					_blueBackground.alpha = _howToWinGiftsBackground.alpha = 0;
			}
			else
			{
				//_appClearBackground.blendMode = _appDarkBackground.blendMode = _whiteBackground.blendMode =
				//	_howToWinGiftsBackground.blendMode = _blueBackground.blendMode = BlendMode.NORMAL;
				
				TweenMax.to(_appClearBackground,   0.25, { autoAlpha: (_screenNavigator.activeScreen as AdvancedScreen).appClearBackground ? 1:0 });
				TweenMax.to(_appDarkBackground,   0.25, { autoAlpha: (_screenNavigator.activeScreen as AdvancedScreen).appDarkBackground ? 1:0 });
				TweenMax.to(_whiteBackground, 0.25, { autoAlpha: (_screenNavigator.activeScreen as AdvancedScreen).whiteBackground ? 1:0 });
				TweenMax.to(_blueBackground, 0.25, { autoAlpha: (_screenNavigator.activeScreen as AdvancedScreen).blueBackground ? 1:0 });
				TweenMax.to(_howToWinGiftsBackground, 0.25, { autoAlpha: (_screenNavigator.activeScreen as AdvancedScreen).howToWinGiftsBackground ? 1:0 });
			}
		}
		
		/**
		 * When the user starts the interact with the drawer (by touching the
		 * alert button or by draggind the right side of the screen), we update
		 * the content of the AlertContainer.
		 */		
		private function onStartInteractWithDrawer(event:starling.events.Event):void
		{
			if( !_drawer.isRightDrawerOpen )
			{
				_shadow.visible = true;
				//_screenNavigator.clipContent = true;
				_alertContainer.updateContent();
				_alertContainer.updateList();
			}
			//log("Shadow visible = " + _shadow.visible);
		}
		
		/**
		 * We need to resize the screen navigator here because if we do it at the
		 * beginning of the transition of the screen navigator, the values are not
		 * correct, specially on android (because of the bottom menu bar).
		 */		
		public function onResize():void
		{
			//TweenMax.killTweensOf(_screenNavigator);
			
			if( AdvancedScreen(_screenNavigator.activeScreen).fullScreen )
			{
				_drawer.openGesture = Drawers.OPEN_GESTURE_NONE;
				
				_screenNavigator.y = 0;
				_screenNavigator.height = GlobalConfig.stageHeight;
				_screenNavigator.width = GlobalConfig.stageWidth;
				
				TweenMax.to(_header, 0.25, { y:-_header.height, autoAlpha:0 });
				TweenMax.to(_footer, 0.25, { y:(GlobalConfig.stageHeight + _footer.height), autoAlpha:0 });
			}
			else
			{
				if( _pushManager && _pushManager.isInitialized && _pushManager.numElementsToPush > 0 || _alertData.numAlerts > 0 )
					_drawer.openGesture = Drawers.OPEN_GESTURE_DRAG_CONTENT_EDGE;
				else
					_drawer.openGesture = Drawers.OPEN_GESTURE_NONE;
				
				_screenNavigator.y = _header.height;
				_screenNavigator.height = GlobalConfig.stageHeight - _footer.height - _header.height;
				_screenNavigator.width = GlobalConfig.stageWidth;
				
				//TweenMax.to(_screenNavigator, 0.25, { y:_header.height, height:Math.max(GlobalConfig.stageHeight, GlobalConfig.stageWidth) - _header.height - _footer.height, width:Math.min(GlobalConfig.stageHeight, GlobalConfig.stageWidth) });
				TweenMax.to(_header, 0.25, { y:0, autoAlpha:1 });
				TweenMax.to(_footer, 0.25, { y:(GlobalConfig.stageHeight - _footer.height), autoAlpha:1 });
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Menu Management
		
		/**
		 * The main menu. */		
		private static var _mainMenu:Menu;
		/**
		 * Whether the main menu is displaying. */		
		private static var _isMainMenuDisplaying:Boolean = false;
		/**
		 *  */		
		private var _showHomeOnMenuClose:Boolean;
		/**
		 *  */		
		private static var _showHomeScreenPending:Boolean = false;
		
		/**
		 * Displays the main menu.
		 */		
		private static function showMainMenu( showHomeOnClose:Boolean = false ):void
		{
			// FIXME A vérifier
			if( !AdvancedScreen(_screenNavigator.activeScreen).canBack )
			{
				hideMenu(); // just in case
				return;
			}
			
			if( !_isMainMenuDisplaying )
			{
				if( !_mainMenu )
				{
					_mainMenu = new Menu(_screenNavigator, showHomeOnClose);
					_mainMenu.addEventListener(LudoEventType.HIDE_MAIN_MENU, hideMenu);
					_mainMenu.alpha = 0;
					_mainMenu.visible = false;
					_mainMenu.width = _screenNavigator.width;
					_mainMenu.height = _screenNavigator.height + _header.height;
					_mainMenu.alignPivot();
					_mainMenu.x = _mainMenu.width * 0.5;
					_mainMenu.y = /*_screenNavigator.y +*/ (_mainMenu.height * 0.5);
					// we need to add this now because the width and height equals to
					// 0 if we do it before, and the list item renderers width and height
					// will also be to 0
					_container.addChildAt(_mainMenu, _container.getChildIndex(_header) + 1);
					_mainMenu.scaleX = _mainMenu.scaleY = 1.3;
					
					// FIXME A vérifier
					//_mainMenu.flatten();
				}
				else
				{
					_mainMenu.updateContent();
				}
				
				Flox.logInfo("<strong>&rarr; Menu</strong>");
				
				_footer.displayNewsIcon(false, true);
				
				_mainMenu.visible = true;
				_isMainMenuDisplaying = true;
				Starling.juggler.tween(_mainMenu, 0.25, { alpha:1, scaleX:1, scaleY:1 });
				
				if( _screenNavigator.activeScreenID == ScreenIds.CGU_SCREEN )
					CGUScreen(_screenNavigator.activeScreen).updateView(true);
			}
		}
		
		/**
		 * Hides the main menu.
		 */		
		private static function hideMenu():void
		{
			// if the main menu is displaying and if ...
			if( _isMainMenuDisplaying && !_showHomeScreenPending )
			{
				if( _mainMenu.showHomeOnClose )
				{
					_showHomeScreenPending = true;
					AdvancedScreen(_screenNavigator.activeScreen).onBack();
				}
				Starling.juggler.tween(_mainMenu, 0.25, { alpha:0, scaleX:1.3, scaleY:1.3, onComplete:onMenuHidden });
			}
		}
		
		/**
		 * Once the main menu is hidden, we need to set its visibility
		 * to false to improve performance, and if we are currently on
		 * the "Termes of Service" screen, we need to hide the scrollText
		 * so that it doesn't appear below the menu.
		 */		
		private static function onMenuHidden(event:starling.events.Event = null):void
		{
			_mainMenu.visible = false;
			_showHomeScreenPending = _isMainMenuDisplaying = false;
			
			if( _screenNavigator.activeScreenID == ScreenIds.HOME_SCREEN )
				_footer.displayNewsIcon(true);
			
			if( _screenNavigator.activeScreenID == ScreenIds.CGU_SCREEN )
				(_screenNavigator.activeScreen as CGUScreen).updateView(false);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Header / Footer functions
		
		/**
		 * When the back button is touched, we check if a callback function have been
		 * defined and if so, we execute it.
		 */		
		private function onBackButtonTouched(event:starling.events.Event):void
		{
			// FIXME mettre ça directement dans le listener ?
			AdvancedScreen(_screenNavigator.activeScreen).onBack();
		}
		
		/**
		 * The news button was touched.
		 */		
		private function onNewsButtonTouched(event:starling.events.Event):void
		{
			_screenNavigator.showScreen( ScreenIds.NEWS_SCREEN );
		}
		
		/**
		 * The alert button was touched.
		 * 
		 * <p>At this time if the AlertContainer is not currently opened,
		 * we will update its content</p>
		 */		
		private function onAlertButtonTouched(event:starling.events.Event = null):void
		{
			onStartInteractWithDrawer(event);
			_container.dispatchEventWith( LudoEventType.OPEN_ALERTS );
			hideMenu();
		}
		
		/**
		 * The menu button was touched in the header.
		 * 
		 * <p>If the header is not displaying, we create it and then display
		 * it with a fade tween. Otherwise, the menu fades out and then is
		 * destroyed to save memory space.</p>
		 */		
		private function onMenuButtonTouched(event:starling.events.Event):void
		{
			if( _isSelectingPseudo )
			{
				displayPseudoSelectionError();
			}
			else
			{
				_isMainMenuDisplaying ? hideMenu():showMainMenu( Boolean(event.data) );
			}
		}
		
		/**
		 * received from Remote when an object obj_membre_mobile
		 * is received.
		 */		
		private function onUpdateSummary(event:starling.events.Event):void
		{
			_footer.updateSummary();
			
			if( !MemberManager.getInstance().isLoggedIn() )
			{
				// if not logged in, we need to display an alert with the number
				// or stars earned with anonymous game sessions
				onPushUpdate();
				_alertContainer.updateContent();
			}
		}
		
		private function onAnimateSummary(event:starling.events.Event):void
		{
			_footer.animateSummary( event.data );
		}
		
		private function onUpdateHeaderTitle( event:starling.events.Event ):void
		{
			_header.setTitle( String(event.data) );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Push Manager
		
		/**
		 * The push manager have been updated (whether it has just finished
		 * initializing, an element have been added or removed).
		 * 
		 * <p>In this case we need to check whether we need to display the
		 * alert button in the header or not.</p>
		 * 
		 * <p>The content of the AlertContainer is not updated here so that
		 * it will be done only when the user wants to open the Drawer.<p>
		 */		
		private function onPushUpdate(event:starling.events.Event = null):void
		{
			if( _pushManager.numElementsToPush > 0 || _alertData.numAlerts > 0 || MemberManager.getInstance().getNumStarsEarnedInAnonymousGameSessions() > 0 || MemberManager.getInstance().getNumTrophiesEarnedInAnonymousGameSessions() > 0)
			{
				_header.showAlertButton( _pushManager.numElementsToPush + _alertData.numAlerts + (MemberManager.getInstance().getNumStarsEarnedInAnonymousGameSessions() > 0 ? 1 : 0) + (MemberManager.getInstance().getNumTrophiesEarnedInAnonymousGameSessions() > 0 ? 1 : 0));
				_drawer.openGesture = Drawers.OPEN_GESTURE_DRAG_CONTENT_EDGE;
				
				//TweenMax.to(_screenNavigator, 0.5, { y:_header.height, height:(GlobalConfig.stageHeight - _header.height - _footer.height) });
			}
			else
			{
				_header.hideAlertButton();
				_drawer.openGesture = Drawers.OPEN_GESTURE_NONE;
				
				//TweenMax.to(_screenNavigator, 0.5, { y:0, height:(GlobalConfig.stageHeight - _footer.height) });
			}
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
				Remote.getInstance().updatePushToken(event.token, null, null, null, 1);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Divers
		
		/**
		 * The alerts have been retreived from the server. In this case
		 * we store them (update) so that we can display badges in the
		 * main menu list.
		 */		
		private function onGetAlertsSuccess(result:Object):void
		{
			_alertData.parse( result.alertes );
			
			// update header
			onPushUpdate();
			
			if( _drawer.isRightDrawerOpen )
			{
				_alertContainer.updateContent();
				_alertContainer.updateList();
			}
		}
		
		/**
		 * When the user have not finished the account creation process (mainly
		 * because he didn't choose a pseudo), we will lock the navigation to
		 * force the user to finish the process. 
		 */		
		private static function displayPseudoSelectionError():void
		{
			// pseudo choice screen error or for the sponsor for now
			InfoManager.showTimed(Localizer.getInstance().translate( (_screenNavigator.activeScreenID == ScreenIds.PSEUDO_CHOICE_SCREEN ? "PSEUDO_CHOICE.YOU_NEED_TO_CHOOSE_PSEUDO" : "SPONSOR.NAVIGATION_ERROR") ), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		public static function get alertData():AlertData { return _alertData; }
		public static function get numAlerts():int { return (_pushManager.numElementsToPush + _alertData.numAlerts); }
		public static function get assets():AssetManager { return _assets; }
		public static function get pushManager():PushManager { return _pushManager; }
		public static function get screenNavigator():AdvancedScreenNavigator { return _screenNavigator; }
		public static function get gameTypeSelectionManager():GameTypeSelectionManager { return _gameTypeSelectionManager; }
		public static function get tracker():ITracker { return _tracker; }
		
		public static function get isSelectingPseudo():Boolean { return _isSelectingPseudo; }
		public static function set isSelectingPseudo(val:Boolean):void { _isSelectingPseudo = val; }
		
	}
}