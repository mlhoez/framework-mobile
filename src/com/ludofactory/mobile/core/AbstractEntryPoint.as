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
	import com.gamua.flox.Flox;
	import com.hasoffers.nativeExtensions.MobileAppTracker;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.LogDisplayer;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.AdvancedScreenNavigator;
	import com.ludofactory.mobile.core.controls.display.TiledBackground;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.push.PushManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.debug.DebugScreen;
	import com.ludofactory.mobile.navigation.Footer;
	import com.ludofactory.mobile.navigation.Header;
	import com.ludofactory.mobile.navigation.HowToWinGiftsScreen;
	import com.ludofactory.mobile.navigation.UpdateScreen;
	import com.ludofactory.mobile.navigation.account.MyAccountScreen;
	import com.ludofactory.mobile.navigation.account.history.gifts.MyGiftsScreen;
	import com.ludofactory.mobile.navigation.achievements.GameCenterManager;
	import com.ludofactory.mobile.navigation.achievements.TrophyScreen;
	import com.ludofactory.mobile.navigation.ads.AdManager;
	import com.ludofactory.mobile.navigation.alert.AlertManager;
	import com.ludofactory.mobile.navigation.authentication.AuthenticationScreen;
	import com.ludofactory.mobile.navigation.authentication.ForgotPasswordScreen;
	import com.ludofactory.mobile.navigation.authentication.LoginScreen;
	import com.ludofactory.mobile.navigation.authentication.PseudoChoiceScreen;
	import com.ludofactory.mobile.navigation.authentication.RegisterCompleteScreen;
	import com.ludofactory.mobile.navigation.authentication.RegisterScreen;
	import com.ludofactory.mobile.navigation.authentication.SponsorScreen;
	import com.ludofactory.mobile.navigation.cs.HelpScreen;
	import com.ludofactory.mobile.navigation.cs.thread.CSThreadScreen;
	import com.ludofactory.mobile.navigation.engine.FacebookEndScreen;
	import com.ludofactory.mobile.navigation.engine.SoloEndScreen;
	import com.ludofactory.mobile.navigation.engine.HighScoreScreen;
	import com.ludofactory.mobile.navigation.engine.PodiumScreen;
	import com.ludofactory.mobile.navigation.engine.TournamentEndScreen;
	import com.ludofactory.mobile.navigation.event.EventManager;
	import com.ludofactory.mobile.navigation.faq.FaqScreen;
	import com.ludofactory.mobile.navigation.game.GameModeSelectionManager;
	import com.ludofactory.mobile.navigation.game.StakeSelectionScreen;
	import com.ludofactory.mobile.navigation.highscore.HighScoreHomeScreen;
	import com.ludofactory.mobile.navigation.highscore.HighScoreListScreen;
	import com.ludofactory.mobile.navigation.home.AlertData;
	import com.ludofactory.mobile.navigation.home.HomeScreen;
	import com.ludofactory.mobile.navigation.home.RulesAndScoresScreen;
	import com.ludofactory.mobile.navigation.menu.Menu;
	import com.ludofactory.mobile.navigation.news.CGUScreen;
	import com.ludofactory.mobile.navigation.news.NewsScreen;
	import com.ludofactory.mobile.navigation.settings.SettingsScreen;
	import com.ludofactory.mobile.navigation.shop.BoutiqueHomeScreen;
	import com.ludofactory.mobile.navigation.shop.bid.BidHomeScreen;
	import com.ludofactory.mobile.navigation.shop.vip.BoutiqueCategoryScreen;
	import com.ludofactory.mobile.navigation.shop.vip.BoutiqueSubCategoryScreen;
	import com.ludofactory.mobile.navigation.sponsor.SponsorHomeScreen;
	import com.ludofactory.mobile.navigation.sponsor.filleuls.FilleulsScreen;
	import com.ludofactory.mobile.navigation.sponsor.invite.SponsorInviteScreen;
	import com.ludofactory.mobile.navigation.store.StoreScreen;
	import com.ludofactory.mobile.navigation.tournament.PreviousTournamentsScreen;
	import com.ludofactory.mobile.navigation.tournament.PreviousTournementDetailScreen;
	import com.ludofactory.mobile.navigation.tournament.TournamentRankingScreen;
	import com.ludofactory.mobile.navigation.vip.VipScreen;
	import com.ludofactory.mobile.navigation.vip.VipUpScreen;
	import com.milkmangames.nativeextensions.CoreMobile;
	import com.milkmangames.nativeextensions.GAnalytics;
	import com.milkmangames.nativeextensions.GoViral;
	import com.nl.funkymonkey.android.deviceinfo.NativeDeviceInfo;
	import com.vidcoin.extension.ane.VidCoinController;
	
	import feathers.controls.Drawers;
	import feathers.controls.ImageLoader;
	import feathers.controls.ProgressBar;
	import feathers.display.Scale9Image;
	import feathers.events.FeathersEventType;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	import feathers.system.DeviceCapabilities;
	import feathers.textures.Scale9Textures;
	
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import starling.utils.deg2rad;
	
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
		 * VidCoin. */
		public static var vidCoin:VidCoinController;
		
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
												{ id:ScreenIds.NEW_HIGH_SCORE_SCREEN, clazz:HighScoreScreen },
												{ id:ScreenIds.SOLO_END_SCREEN, clazz:SoloEndScreen },
												{ id:ScreenIds.GAME_TYPE_SELECTION_SCREEN, clazz:StakeSelectionScreen },
												{ id:ScreenIds.TOURNAMENT_RANKING_SCREEN, clazz:TournamentRankingScreen },
												{ id:ScreenIds.SPONSOR_REGISTER_SCREEN, clazz:SponsorScreen },
												{ id:ScreenIds.RULES_AND_SCORES_SCREEN, clazz:RulesAndScoresScreen },
												{ id:ScreenIds.PODIUM_SCREEN, clazz:PodiumScreen },
												{ id:ScreenIds.TOURNAMENT_END_SCREEN, clazz:TournamentEndScreen },
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
		private var _header:Header;
		/**
		 * Screen navigator. */		
		protected static var _screenNavigator:AdvancedScreenNavigator;
		/**
		 * Screen transition. */		
		private var _transitionManager:ScreenSlidingStackTransitionManager;
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
		private static var _gameTypeSelectionManager:GameModeSelectionManager;
		
//------------------------------------------------------------------------------------------------------------
//	Managers
		
		/**
		 * The push manager */		
		private static var _pushManager:PushManager;
		
		
		/**
		 * The alert container. */		
		private static var _alertContainer:AlertManager;
		
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
			
			GlobalConfig.isPhone = DeviceCapabilities.isPhone( Starling.current.nativeStage );
			GlobalConfig.stageWidth = Starling.current.viewPort.width;
			GlobalConfig.stageHeight = Starling.current.viewPort.height;
			
			if( launchImageTexture )
			{
				// there is a launchImageTexture when we test on a device
				// (it is the reference to the splash screen)
				
				// OLD
				//_loadingBackground = new Image( launchImageTexture );
				//_loadingBackground.width = GlobalConfig.stageWidth;
				//_loadingBackground.height = GlobalConfig.stageHeight;
				//addChild( _loadingBackground );
				
				_loadingBackground = new Image( launchImageTexture );
				
				if(AbstractGameInfo.LANDSCAPE)
				{
					if(_loadingBackground.height > _loadingBackground.width)
					{
						// landscape but the image is portrait
						_loadingBackground.width = GlobalConfig.stageHeight;
						_loadingBackground.height = GlobalConfig.stageWidth;
						_loadingBackground.rotation = deg2rad(-90);
						_loadingBackground.x = 0;
						_loadingBackground.y = GlobalConfig.stageHeight;
					}
				}
				else
				{
					// portrait but the image is landscape
					if(_loadingBackground.width > _loadingBackground.height)
					{
						_loadingBackground.width = GlobalConfig.stageHeight;
						_loadingBackground.height = GlobalConfig.stageWidth;
						_loadingBackground.rotation = deg2rad(90);
						_loadingBackground.x = 0;
						_loadingBackground.y = 0;
					}
				}
				
				if( GlobalConfig.android )
				{
					//_loadingBackground.width = stage.stageWidth;
					//_loadingBackground.height = stage.stageHeight;
					_loadingBackground.scaleX = _loadingBackground.scaleY = 1;
					_loadingBackground.scaleX = _loadingBackground.scaleY = Utilities.getScaleToFill(_loadingBackground.width, _loadingBackground.height, GlobalConfig.stageWidth, GlobalConfig.stageHeight, true);
					_loadingBackground.x = (GlobalConfig.stageWidth - _loadingBackground.width) * 0.5;
					_loadingBackground.y = (GlobalConfig.stageHeight - _loadingBackground.height) * 0.5;
				}
				
				/*if( (AbstractGameInfo.LANDSCAPE && GlobalConfig.android) || (GlobalConfig.ios && AbstractGameInfo.LANDSCAPE && GlobalConfig.isPhone) )
				{
					_loadingBackground.width = GlobalConfig.stageHeight;
					_loadingBackground.height = GlobalConfig.stageWidth;
					_loadingBackground.rotation = deg2rad(-90);
					_loadingBackground.x = 0;
					_loadingBackground.y = GlobalConfig.stageHeight;
				}*/
				
				addChild( _loadingBackground );
			}
			
			_assets = new AssetManager();
			_assets.verbose = CONFIG::DEBUG;
			_assets.enqueue( File.applicationDirectory.resolvePath("./assets/splash/") );
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
				_progressBar.width = GlobalConfig.stageWidth * (GlobalConfig.isPhone ? 0.3 : 0.3);
				addChild(_progressBar);
				_progressBar.validate();
				_progressBar.x = (GlobalConfig.stageWidth - _progressBar.width) * 0.5;
				_progressBar.y = GlobalConfig.stageHeight * 0.9;
				
				_assetsToLoad = [ File.applicationDirectory.resolvePath("assets/ui/") ];
				
				Starling.current.nativeStage.autoOrients = true;
				
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
			// initialize Popups
			NotificationPopupManager.initializeNotification();
			// initialize VidCoin
			try
			{
				vidCoin = new VidCoinController();
				vidCoin.startWithGameId(AbstractGameInfo.VID_COIN_GAME_ID);
				vidCoin.setLoggingEnabled(CONFIG::DEBUG);
				if( MemberManager.getInstance().isLoggedIn() )
				{
					var dict:Dictionary = new Dictionary();
					dict[VidCoinController.kVCUserGameID] = MemberManager.getInstance().id;
					dict[VidCoinController.kVCUserBirthYear] = MemberManager.getInstance().birthDate.split("-")[0];
					dict[VidCoinController.kVCUserGenderKey]= MemberManager.getInstance().title == "Mr." ? VidCoinController.kVCUserGenderMale : VidCoinController.kVCUserGenderFemale;
					vidCoin.updateUserDictionary(dict);
				}
			}
			catch(error:Error) { Flox.logError("Erreur lors de l'intialisation de VidCoin.") }
			
			// load common sounds
			var musicPath:String = File.applicationDirectory.resolvePath("assets/sounds/music/").url;
			var sfxPath:String = File.applicationDirectory.resolvePath("assets/sounds/sfx/").url;
			
			// default in framework
			SoundManager.getInstance().addSound("new-highscore", sfxPath + "/new-highscore.mp3", "sfx");
			SoundManager.getInstance().addSound("trophy-won", sfxPath + "/trophy-won.mp3", "sfx");
			
			try
			{
				MobileAppTracker.instance.init(AbstractGameInfo.HAS_OFFERS_ADVERTISER_ID, AbstractGameInfo.HAS_OFFERS_CONVERSION_KEY);
				
				if( CONFIG::DEBUG )
				{
					MobileAppTracker.instance.setDebugMode(true);
					MobileAppTracker.instance.setAllowDuplicates(true);
				}
				
				//MobileAppTracker.instance.setUserId(GlobalConfig.deviceId);
				//MobileAppTracker.instance.trackInstall(); // track install (or update)
				//MobileAppTracker.instance.trackAction("open"); // track daily open
			} 
			catch(error:Error) { }
			
			if( GAnalytics.isSupported() )
			{
				GAnalytics.create(AbstractGameInfo.GOOGLE_ANALYTICS_TRACKER);
			}
			
			// parse device info
			
			NativeDeviceInfo.parse();
			
			
			
			_container = new Sprite();
			
			initializeBackgrounds();
			
			_alertContainer = new AlertManager();
			dispatcher.addEventListener(MobileEventTypes.OPEN_ALERTS_FROM_HEADER, onAlertButtonTouched);
			addChild(_alertContainer);
			
			// controllrs
			_pushManager = new PushManager();
			_pushManager.addEventListener(MobileEventTypes.UPDATE_HEADER, onPushUpdate);
			_pushManager.addEventListener(MobileEventTypes.UPDATE_ALERT_CONTAINER_LIST, _alertContainer.updateList);
			
			if( CoreMobile.isSupported() )
			{
				CoreMobile.create(); // only supported on Android and iOS
			}
			
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
			
			// Drawers : child = 0 => derrière le ScreenNavigator
			
			_drawer = new Drawers( _container );
			_drawer.rightDrawer = _alertContainer;
			_drawer.autoSizeMode = Drawers.AUTO_SIZE_MODE_CONTENT;
			_drawer.openOrCloseDuration = 0.5;
			_drawer.rightDrawerToggleEventType = MobileEventTypes.OPEN_ALERTS_FROM_HEADER;
			_drawer.addEventListener(FeathersEventType.BEGIN_INTERACTION, onStartInteractWithDrawer);
			_drawer.openGesture = Drawers.OPEN_GESTURE_NONE;
			addChild(_drawer);
			
			//_transitionManager = new ScreenSlidingStackTransitionManager( _screenNavigator );
			//_transitionManager.duration = .5;
			
			// Header
			_header = new Header();
			_header.addEventListener(MobileEventTypes.OPEN_ALERTS_FROM_HEADER, onAlertButtonTouched);
			_header.addEventListener(MobileEventTypes.HEADER_VISIBILITY_CHANGED, onHeaderVisibilityChanged);
			_container.addChild(_header);
			
			_footer = new Footer();
			_footer.addEventListener(MobileEventTypes.MAIN_MENU_TOUCHED, onMenuButtonTouched);
			_footer.addEventListener(MobileEventTypes.BACK_BUTTON_TOUCHED, onBackButtonTouched);
			_footer.addEventListener(MobileEventTypes.NEWS_BUTTON_TOUCHED, onNewsButtonTouched);
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
			
			MemberManager.getInstance().addEventListener(MobileEventTypes.UPDATE_SUMMARY, onUpdateSummary);
			Remote.getInstance().addEventListener(MobileEventTypes.UPDATE_SUMMARY, onUpdateSummary);
			
			dispatcher.addEventListener(MobileEventTypes.ALERT_COUNT_UPDATED, onPushUpdate);
			LanguageManager.getInstance().checkForUpdate(false);
			
			if( PushNotification.getInstance().isPushNotificationSupported && (Boolean(Storage.getInstance().getProperty( StorageConfig.PROPERTY_PUSH_INITIALIZED )) || GlobalConfig.android) )
			{
				// IMPORTANT ! : ajouter dans la condition (?) : ou si le membre est co et qu'il a activé les pushs sur un autre appareil
				// car si on reset le Storage, ça se mettra jamais à jour...
				// FIXME Gérer android
				PushNotification.getInstance().addEventListener(PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT, onPermissionGiven);
				PushNotification.getInstance().registerForPushNotification(AbstractGameInfo.GCM_SENDER_ID);
			}
			
			_eventManager = new EventManager();
			_gameTypeSelectionManager = new GameModeSelectionManager(this);
			
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
			
			//addChild(LogDisplayer.getInstance());
			//LogDisplayer.getInstance().touchable = true;
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
			
			// TODO A checker
			//_appClearBackground.blendMode = _appDarkBackground.blendMode = _whiteBackground.blendMode =
			//	_howToWinGiftsBackground.blendMode = _blueBackground.blendMode = BlendMode.NONE;
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
			SCREENS = SCREENS.concat(DEBUG_SCREENS);
			_screenNavigator.addScreensFromArray(SCREENS);
			_screenNavigator.addEventListener(FeathersEventType.TRANSITION_START, onScreenTransitionStarted);
			_screenNavigator.addEventListener(MobileEventTypes.UPDATE_HEADER_TITLE, onUpdateHeaderTitle);
			_screenNavigator.addEventListener(MobileEventTypes.SHOW_MAIN_MENU, onMenuButtonTouched);
			_screenNavigator.addEventListener(MobileEventTypes.HIDE_MAIN_MENU, hideMenu);
			_screenNavigator.addEventListener(MobileEventTypes.ANIMATE_SUMMARY, onAnimateSummary);
			_screenNavigator.addEventListener(MobileEventTypes.UPDATE_SUMMARY, onUpdateSummary);
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
			
			_alertContainer.width = GlobalConfig.stageWidth * (AbstractGameInfo.LANDSCAPE ? 0.6 : 0.8);
			_alertContainer.height = GlobalConfig.stageHeight;
			_alertContainer.x = GlobalConfig.stageWidth - _alertContainer.width;
			
			_shadow.x = GlobalConfig.stageWidth;
			_shadow.height = GlobalConfig.stageHeight;
			
			_footer.width = GlobalConfig.stageWidth;
			_footer.y = GlobalConfig.stageHeight - _footer.height;
			
			_screenNavigator.height = _footer.y;
			
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
			_loadingLogo.width = GlobalConfig.stageWidth * (AbstractGameInfo.LANDSCAPE ? ((GlobalConfig.isPhone ? 0.6 : 0.5)) : (GlobalConfig.isPhone ? 0.85 : 0.75));
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
			
			Starling.juggler.tween(_loadingLogo, 0.75, { alpha:1 });
			Starling.juggler.tween(_orangeBackground, 0.75, { alpha:1, onComplete:animateOut });
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
			
			Starling.juggler.tween(_loadingLogo, 0.75, { delay:0.75, alpha:0 });
			Starling.juggler.tween(_orangeBackground, 0.75, { delay:0.75, alpha:0, onComplete:removeSplashElements });
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
			GameCenterManager.authenticateUser();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Screen Management
		
		/**
		 * When the screen transition starts.
		 */		
		private function onScreenTransitionStarted(event:Event):void
		{
			hideMenu();
			onResize();
			
			if( _drawer.isRightDrawerOpen )
				_drawer.toggleRightDrawer();
			
			// update the badges and events
			if( _screenNavigator.activeScreenID == ScreenIds.HOME_SCREEN )
			{
				_alertContainer.fetchAlerts();
				_eventManager.getEvent();
			}
			
			AdvancedScreen(_screenNavigator.activeScreen).headerTitle == "" ? _header.hideTitle() : _header.showTitle( AdvancedScreen(_screenNavigator.activeScreen).headerTitle );
			_footer.displayNewsIcon( _screenNavigator.activeScreenID == ScreenIds.HOME_SCREEN );
			
			_shadow.visible = _drawer.openGesture == Drawers.OPEN_GESTURE_NONE ? false : true;
			
			if( _screenNavigator.activeScreenID == ScreenIds.GAME_SCREEN)
			{
				_appClearBackground.visible = _appDarkBackground.visible = _whiteBackground.visible =
					_howToWinGiftsBackground.visible = _blueBackground.visible = false;
			}
			else
			{
				
				_appClearBackground.visible = (_screenNavigator.activeScreen as AdvancedScreen).appClearBackground ? true : false;
				_appDarkBackground.visible = (_screenNavigator.activeScreen as AdvancedScreen).appDarkBackground ? true : false;
				_whiteBackground.visible = (_screenNavigator.activeScreen as AdvancedScreen).whiteBackground ? true : false;
				_blueBackground.visible = (_screenNavigator.activeScreen as AdvancedScreen).blueBackground ? true : false;
				_howToWinGiftsBackground.visible = (_screenNavigator.activeScreen as AdvancedScreen).howToWinGiftsBackground ? true : false;
			}
		}
		
		/**
		 * When the user starts the interact with the drawer (by touching the
		 * alert button or by draggind the right side of the screen), we update
		 * the content of the AlertContainer.
		 */		
		private function onStartInteractWithDrawer(event:Event):void
		{
			if( !_drawer.isRightDrawerOpen )
			{
				_shadow.visible = true;
				//_screenNavigator.clipContent = true;
				_alertContainer.updateContent();
				_alertContainer.updateList();
			}
		}
		
		/**
		 * We need to resize the screen navigator here because if we do it at the
		 * beginning of the transition of the screen navigator, the values are not
		 * correct, specially on android (because of the bottom menu bar).
		 */		
		public function onResize():void
		{
			if( AdvancedScreen(_screenNavigator.activeScreen).fullScreen )
			{
				_drawer.openGesture = Drawers.OPEN_GESTURE_NONE;
				
				_screenNavigator.y = 0;
				_screenNavigator.height = GlobalConfig.stageHeight;
				_screenNavigator.width = GlobalConfig.stageWidth;
				
				_header.y = -500;
				
				//TweenMax.to(_footer, 0.25, { y:(GlobalConfig.stageHeight + _footer.height), autoAlpha:0 });
				_footer.alpha = 0;
				_footer.visible = false;
				_footer.y = GlobalConfig.stageHeight;
			}
			else
			{
				if( (_pushManager && _pushManager.isInitialized && _pushManager.numElementsToPush > 0) || _alertContainer.numAlerts > 0 )
					_drawer.openGesture = Drawers.OPEN_GESTURE_DRAG_CONTENT_EDGE;
				else
					_drawer.openGesture = Drawers.OPEN_GESTURE_NONE;
				
				_header.y = 0;
				
				onHeaderVisibilityChanged();
				
				//if( _footer.y >= GlobalConfig.stageHeight )
					//TweenMax.to(_footer, 0.25, { y:(GlobalConfig.stageHeight - _footer.height), autoAlpha:1, onUpdate:function():void{log("Update : " + _footer.y);} });
				
				_footer.alpha = 1;
				_footer.visible = true;
				_footer.y = GlobalConfig.stageHeight - _footer.height;
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
					_mainMenu.addEventListener(MobileEventTypes.HIDE_MAIN_MENU, hideMenu);
					_mainMenu.alpha = 0;
					_mainMenu.visible = false;
					_mainMenu.width = _screenNavigator.width;
					_mainMenu.height = GlobalConfig.stageHeight - _footer.height;
					_mainMenu.alignPivot();
					_mainMenu.x = _mainMenu.width * 0.5;
					_mainMenu.y = /*_screenNavigator.y +*/ (_mainMenu.height * 0.5);
					// we need to add this now because the width and height equals to
					// 0 if we do it before, and the list item renderers width and height
					// will also be to 0
					_container.addChildAt(_mainMenu, _container.getChildIndex(_footer));
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
		 * Once the main menu is hidden, we need to set its visibility to false to improve
		 * performance, and if we are currently on the "Termes of Service" screen, we need
		 * to hide the scrollText so that it doesn't appear above the menu.
		 */		
		private static function onMenuHidden(event:Event = null):void
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
			_screenNavigator.showScreen( ScreenIds.NEWS_SCREEN );
		}
		
		/**
		 * The alert button was touched.
		 * 
		 * <p>At this time if the AlertContainer is not currently opened,
		 * we will update its content</p>
		 */		
		private function onAlertButtonTouched(event:Event = null):void
		{
			onStartInteractWithDrawer(event);
			_container.dispatchEventWith( MobileEventTypes.OPEN_ALERTS_FROM_HEADER );
			hideMenu();
		}
		
		/**
		 * The header's visibiliy have changed.
		 */		
		private function onHeaderVisibilityChanged(event:Event = null):void
		{
			// FIXME A optimiser non de Zeus !
			if( _screenNavigator.activeScreen )
			{
				if( AdvancedScreen(_screenNavigator.activeScreen).fullScreen )
				{
					_screenNavigator.y = 0;
					_screenNavigator.height = GlobalConfig.stageHeight; // FIXME A optimiser les .height
				}
				else
				{
					if( _header.visible )
					{
						/*if( _screenNavigator.y == 0 )
						{*/
							// the screen navigator is too big and too high
							_screenNavigator.y = _header.height;
							_screenNavigator.height = GlobalConfig.stageHeight - _footer.height - _header.height; // FIXME A optimiser les .height
						//}
					}
					else
					{
						/*if( _screenNavigator.y != 0 )
						{*/
							// the screen navigator is too small and too low
							_screenNavigator.y = 0;
							_screenNavigator.height = GlobalConfig.stageHeight - _footer.height; // FIXME A optimiser les .height
						//}
					}
				}
			}
		}
		
		/**
		 * The menu button was touched in the header.
		 * 
		 * <p>If the header is not displaying, we create it and then display
		 * it with a fade tween. Otherwise, the menu fades out and then is
		 * destroyed to save memory space.</p>
		 */		
		private function onMenuButtonTouched(event:Event):void
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
		private function onUpdateSummary(event:Event):void
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
		
		private function onAnimateSummary(event:Event):void
		{
			_footer.animateSummary( event.data );
		}
		
		/**
		 * Callback called when the header's title is updated from the settings screen
		 * after the language have been changed.
		 */		
		private function onUpdateHeaderTitle( event:Event ):void
		{
			_header.showTitle( String(event.data) );
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
		private function onPushUpdate(event:Event = null):void
		{
			if( _pushManager.numElementsToPush > 0 || _alertContainer.numAlerts > 0 || MemberManager.getInstance().getNumStarsEarnedInAnonymousGameSessions() > 0 || MemberManager.getInstance().getNumTrophiesEarnedInAnonymousGameSessions() > 0 || Storage.getInstance().getProperty(StorageConfig.PROPERTY_NEW_LANGUAGES).length > 0)
			{
				_header.showAlertButton( _pushManager.numElementsToPush + _alertContainer.numAlerts + (MemberManager.getInstance().getNumStarsEarnedInAnonymousGameSessions() > 0 ? 1 : 0) + (MemberManager.getInstance().getNumTrophiesEarnedInAnonymousGameSessions() > 0 ? 1 : 0) + (Storage.getInstance().getProperty(StorageConfig.PROPERTY_NEW_LANGUAGES).length > 0 ? 1 : 0));
				_drawer.openGesture = Drawers.OPEN_GESTURE_DRAG_CONTENT_EDGE;
			}
			else
			{
				_header.hideAlertButton();
				_drawer.openGesture = Drawers.OPEN_GESTURE_NONE;
			}
			
			if( _drawer.isRightDrawerOpen )
			{
				_alertContainer.updateContent();
				_alertContainer.updateList();
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
				Remote.getInstance().updatePushToken(event.token, null, null, null, 5);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Divers
		
		/**
		 * When the user have not finished the account creation process (mainly because he didn't choose a pseudo),
		 * we will lock the navigation to force the user to finish the process. 
		 */		
		private static function displayPseudoSelectionError():void
		{
			// pseudo choice screen error or for the sponsor for now
			InfoManager.showTimed(_screenNavigator.activeScreenID == ScreenIds.PSEUDO_CHOICE_SCREEN ? _("Vous devez choisir un pseudo !") : _("Merci d'entrer un code parrain ou passez cette étape pour continuer."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Logs
		
		private var _areLogsShowing:Boolean = false;
		
		public function showOrHideLogs():void
		{
			if(_areLogsShowing)
			{
				hideLogs()
			}
			else
			{
				showLogs();
			}
		}
		
		/**
		 * 
		 */
		public function showLogs():void
		{
			if( !_areLogsShowing )
			{
				addChild(LogDisplayer.getInstance());
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
				_areLogsShowing = false;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		public static function get alertData():AlertData { return _alertContainer.alertData; }
		public static function get numAlerts():int { return (_pushManager.numElementsToPush + _alertContainer.numAlerts); }
		public static function get assets():AssetManager { return _assets; }
		public static function get pushManager():PushManager { return _pushManager; }
		public static function get screenNavigator():AdvancedScreenNavigator { return _screenNavigator; }
		public static function get gameTypeSelectionManager():GameModeSelectionManager { return _gameTypeSelectionManager; }
		
		public static function get isSelectingPseudo():Boolean { return _isSelectingPseudo; }
		public static function set isSelectingPseudo(val:Boolean):void { _isSelectingPseudo = val; }
		
	}
}