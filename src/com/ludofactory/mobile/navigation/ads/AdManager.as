/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 27 mai 2013
*/
package com.ludofactory.mobile.navigation.ads
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.jirbo.airadc.AdColonyAdAvailabilityChangeEvent;
	import com.jirbo.airadc.AdColonyAdFinishedEvent;
	import com.jirbo.airadc.AdColonyAdStartedEvent;
	import com.jirbo.airadc.AirAdColony;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.logs.logError;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.manager.TimerManager;
	import com.milkmangames.nativeextensions.AdMob;
	import com.milkmangames.nativeextensions.AdMobAdType;
	import com.milkmangames.nativeextensions.AdMobAlignment;
	import com.milkmangames.nativeextensions.events.AdMobErrorEvent;
	import com.milkmangames.nativeextensions.events.AdMobEvent;
	import com.milkmangames.nativeextensions.ios.IAd;
	import com.milkmangames.nativeextensions.ios.IAdBannerAlignment;
	import com.milkmangames.nativeextensions.ios.IAdContentSize;
	import com.milkmangames.nativeextensions.ios.events.IAdErrorEvent;
	import com.milkmangames.nativeextensions.ios.events.IAdEvent;
	import com.vidcoin.extension.ane.VidCoinController;
	import com.vidcoin.extension.ane.events.VidCoinEvents;
	
	import flash.utils.Dictionary;
	
	import starling.events.EventDispatcher;
	
	/**
	 * This is the main ad manager. It handles both iAd and AdMob networks so that both
	 * are easily working no matter if you are on iOS or Android. When no iAd is available
	 * (banner or interstitial), the AdManager fallback to the AdMob network which have a 
	 * much higher fillrate (but a lower eCPM).
	 * 
	 * <p><strong>Banners best pratice :</strong>
	 * <ul>
	 * <li>Create banners when the game starts and set visibility to false.</li>
	 * <li>Switch visibility instead of creating / destroying ads each time the pause menu is shown.</li>
	 * <li>When the game ends, destroy ads.</li>
	 * </ul></p>
	 */	
	public class AdManager extends EventDispatcher /*implements TJConnectListener, TJPlacementListener*/
	{
		private static var _instance:AdManager;
		
		/**
		 * Whether iAd is available. */		
		private var _iAdAvailable:Boolean = false;
		/**
		 * Whether AdMob is available. */		
		private var _adMobAvailable:Boolean = false;
		
		private var _timeriAd:TimerManager;
		private var _timerAdMob:TimerManager;
		
		// ----- videos
		
		/**
		 * VidCoin. */
		private var _vidCoin:VidCoinController;
		/**
		 * AdColony. */
		private var _adColony:AirAdColony;
		
		/**
		 * TapJoy. */
		//private var _statisticsVideoAccessPlacement:TJPlacement;
		
		public function AdManager(sk:SecurityKey)
		{
			if(sk == null)
				throw new Error("Erreur : Echec de l'instanciation : Utiliser Remote.getInstance() au lieu de new.");
		}
		
		/**
		 * Initializes both iAd and adMob ad networks.
		 * 
		 * <p>If iAd is available and if we are on an iPad, an interstitial
		 * will be preloaded so that be can quickly show it when needed.</p>
		 * 
		 * <p>If AdMob is available, it will be initialized for both Android
		 * and iOS devices.</p>
		 */		
		public function initialize():void
		{
			if( IAd.isSupported() )
			{
				IAd.create();
				if( !IAd.iAd.isIAdAvailable() )
				{
					IAd.iAd.dispose();
				}
				else
				{
					// preload interstitial if possible (only available on iPad)
					if( IAd.iAd.isInterstitialAvailable() )
					{
						IAd.iAd.addEventListener(IAdEvent.INTERSTITIAL_SHOWN, oniAdInterstitalShown);
						IAd.iAd.addEventListener(IAdEvent.INTERSTITITAL_DISMISSED, oniAdInterstitalDismissed);
						//IAd.iAd.addEventListener(IAdEvent.INTERSTITIAL_AD_UNLOADED, onInterstitalAdDismissed); // useless ?
						IAd.iAd.addEventListener(IAdEvent.INTERSTITIAL_AD_LOADED, oniAdInterstitialLoaded);
						IAd.iAd.addEventListener(IAdErrorEvent.INTERSTITIAL_AD_FAILED, oniAdInterstitalFailed);
						
						_timeriAd = new TimerManager(false, 6, -1, null, onReloadiAdInterstitial, null);
						if( AirNetworkInfo.networkInfo.isConnected() )
						{
							IAd.iAd.loadInterstitial(false);
						}
						else
						{
							_timeriAd.restart();
						}
						
					}
					_iAdAvailable = true;
				}
			}
			
			// initialize AdMob network on both iOS and Android devices
			if( AdMob.isSupported )
			{
				AdMob.init(AbstractGameInfo.ADMOB_ANDROID_DEFAULT_BANNER_UNIT_ID, AbstractGameInfo.ADMOB_IOS_DEFAULT_BANNER_UNIT_ID);
				// setup test devices to avoid making impressions while testing
				if( CONFIG::DEBUG )
					AdMob.enableTestDeviceIDs(AdMob.getCurrentTestDeviceIDs());
				
				// preload interstitials for both plateforms
				AdMob.addEventListener(AdMobEvent.SCREEN_PRESENTED, onAdMobInterstitialShown);
				AdMob.addEventListener(AdMobEvent.SCREEN_DISMISSED, onAdMobInterstitalDismissed);
				AdMob.addEventListener(AdMobEvent.RECEIVED_AD, onAdMobInterstitialLoaded);
				AdMob.addEventListener(AdMobErrorEvent.FAILED_TO_RECEIVE_AD, onAdMobInterstitialFailed);
				
				_timerAdMob = new TimerManager(false, 6, -1, null, onReloadAdMobInterstitial, null);
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					AdMob.loadInterstitial(AbstractGameInfo.ADMOB_ANDROID_INTERSTITIAL_ID, false, AbstractGameInfo.ADMOB_IOS_INTERSTITIAL_ID);
				}
				else
				{
					_timerAdMob.restart();
				}
				

				_adMobAvailable = true;
			}
			
			// initialize AdColony
			_adColony = new AirAdColony();
			if(_adColony.isSupported())
			{
				//_adColony.adcContext.addEventListener(StatusEvent.STATUS, handleAdColonyEvent);
				//_adColony.addEventListener(AdColonyV4VCRewardEvent.EVENT_TYPE, handleV4VCEvent);
				_adColony.addEventListener(AdColonyAdStartedEvent.EVENT_TYPE, onAdColonyAdStarted);
				_adColony.addEventListener(AdColonyAdFinishedEvent.EVENT_TYPE, onAdColonyAdFinished);
				_adColony.addEventListener(AdColonyAdAvailabilityChangeEvent.EVENT_TYPE, onAdColonyAvailabilityChange);
				// client_options on Android, app version number on iOS, then app id from adcolony.com and all the placements ids (video zone ids)
				_adColony.configure(AbstractGameInfo.GAME_VERSION, AbstractGameInfo.ADCOLONY_APP_ID, AbstractGameInfo.ADCOLONY_STATS_PLACEMENT_ID, AbstractGameInfo.ADCOLONY_GAME_PLACEMENT_ID);
			}
			
			// initialize VidCoin
			try
			{
				_vidCoin = new VidCoinController();
				_vidCoin.startWithGameId(AbstractGameInfo.VIDCOIN_GAME_ID);
				_vidCoin.setLoggingEnabled(CONFIG::DEBUG);
				if( MemberManager.getInstance().isLoggedIn() )
				{
					var dict:Dictionary = new Dictionary();
					dict[VidCoinController.kVCUserGameID] = MemberManager.getInstance().id;
					dict[VidCoinController.kVCUserBirthYear] = MemberManager.getInstance().birthDate.split("-")[0];
					dict[VidCoinController.kVCUserGenderKey]= MemberManager.getInstance().title == "Mr." ? VidCoinController.kVCUserGenderMale : VidCoinController.kVCUserGenderFemale;
					_vidCoin.updateUserDictionary(dict);
				}
			}
			catch(error:Error)
			{
				logError("Erreur lors de l'intialisation de VidCoin.")
			}
			
			// initialize TapJoy
			/*try
			{
				var connectFlags:Object = {};
				connectFlags["enable_logging"] = CONFIG::DEBUG; // Do not set logging for released builds!
				TapjoyAIR.connect((GlobalConfig.ios ? AbstractGameInfo.TAPJOY_IOS_KEY : AbstractGameInfo.TAPJOY_ANDROID_KEY), connectFlags, _instance);
				
				// create placements
				_statisticsVideoAccessPlacement = new TJPlacement("StatisticsVideoAccess", _instance);
				// prepare placements
				//prepareTapjoyContent();
			}
			catch(error:Error)
			{
				log("[AdManager] Error loading TapJoy !");
				log(error);
			}*/
		}
		
		public function updateVidCoinData():void
		{
			if( _vidCoin )
			{
				var dict:Dictionary = new Dictionary();
				dict[VidCoinController.kVCUserGameID] = MemberManager.getInstance().id;
				dict[VidCoinController.kVCUserBirthYear] = MemberManager.getInstance().birthDate.split("-")[0];
				dict[VidCoinController.kVCUserGenderKey]= MemberManager.getInstance().title == "Mr." ? VidCoinController.kVCUserGenderMale : VidCoinController.kVCUserGenderFemale;
				_vidCoin.updateUserDictionary(dict);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	iAd and AdMob Banners
		
		/**
		 * Creates an iAd banner and sets its visibility.
		 * 
		 * @param vAlign Banner vertical alignment (use IAdBannerAlignment)
		 * @param autoShow Whether the banner should be automatically shown.
		 * @param offsetY Banner Y offset.
		 */		
		public function createiAdBanner(vAlign:String = IAdBannerAlignment.TOP, visible:Boolean = false, animate:Boolean = false, offsetY:Number = 0):void
		{
			if( _iAdAvailable )
				IAd.iAd.createBannerAd(vAlign, IAdContentSize.PORTRAIT_AND_LANDSCAPE, offsetY);
			setiAdBannerVisibility(visible, animate);
		}
		
		/**
		 * Shows an AdMob banner.
		 * 
		 * @param hAlign Banner horizontal alignment (use AdMobAlignment).
		 * @param valign Banner vertical alignment (use AdMobAlignment).
		 * @param offsetX Banner X offset.
		 * @param offsetY Banner Y offset.
		 * @param customAndroidBannerUnitId Custom banner unit id for Android (if multiple banners are defined).
		 * @param customiOSBannerUnitId Custom banner unit id for iOS (if multiple banners are defined).
		 */		
		public function crateAdMobBanner(hAlign:String = AdMobAlignment.CENTER, vAlign:String = AdMobAlignment.TOP, visible:Boolean = false, offsetX:Number = 0, offsetY:Number = 0, customAndroidBannerUnitId:String = null, customiOSBannerUnitId:String = null):void
		{
			if( _adMobAvailable )
			{
				// change the current banner unit ids for both iOS and Android if necessary.
				// It is useful when multiple banners have been defined on the AdMob interface.
				if( customAndroidBannerUnitId && customiOSBannerUnitId )
					AdMob.setBannerAdUnitID(customAndroidBannerUnitId, customiOSBannerUnitId);
				AdMob.showAd(AdMobAdType.SMART_BANNER, hAlign, vAlign, offsetX, offsetY);
				setAdMobBannerVisibility(visible);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Interstitials
		
		/**
		 * Shows an interstitial ad.
		 * 
		 * If iAd is available, we first try to display an iAd interstitial. If no interstitial
		 * can be retreived, we try to load an AdMob interstitial instead.
		 * 
		 * If iAd is not available but AdMob is, we display an AdMob interstitial directly.
		 * 
		 * @return true if there is network, false otherwise
		 * 
		 */		
		public function showInterstitial():Boolean
		{
			if( _iAdAvailable && IAd.iAd.isInterstitialAvailable() )
			{
				if(IAd.iAd.isInterstitialReady())
				{
					IAd.iAd.showPendingInterstitial();
					return true;
				}
				
			}
			
			if( _adMobAvailable )
			{
				if( AdMob.isInterstitialReady() )
				{
					AdMob.showPendingInterstitial();
					return true;
				}
			}
			
			return false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Chnage banners visibility
		
		/**
		 * Changes the visibility of all banners (both AdMob and iAd banners).
		 */		
		public function setBannersVisibility(visible:Boolean, animate:Boolean = false):void
		{
			setiAdBannerVisibility(visible, animate);
			setAdMobBannerVisibility(visible);
		}
		
		/**
		 * Changes the visibility of iAd banners.
		 * 
		 * @param visible Whether the banner should be visible.
		 * @param animate Whether the banner is animated.
		 */		
		public function setiAdBannerVisibility(visible:Boolean, animate:Boolean = false):void
		{
			if( _iAdAvailable )
			{
				try
				{
					IAd.iAd.setBannerVisibility(visible, animate);
				} 
				catch(err:Error)
				{
					// probably no banner currently created and/or visible
				}
			}
		}
		
		/**
		 * Changes the visibility of AdMob banners.
		 * 
		 * @param visible Whether the banner should be visible.
		 */		
		public function setAdMobBannerVisibility(visible:Boolean):void
		{
			if( _adMobAvailable )
			{
				try
				{
					AdMob.setVisibility(visible);
				} 
				catch(err:Error)
				{
					// probably no banner currently created and/or visible
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Events
		
	// Interstitial loaded
		
		/**
		 * When the interstitial have been loaded and now ready to display.
		 */
		public function oniAdInterstitialLoaded(event:IAdEvent):void
		{
			_timeriAd.stop();
			log("[AdManager] iAd interstitial loaded.");
		}
		
		/**
		 * When the interstitial have been loaded and now ready to display.
		 */
		public function onAdMobInterstitialLoaded(event:AdMobEvent):void
		{
			if(event.isInterstitial)
			{
				_timerAdMob.stop();
				log("[AdManager] AdMob interstitial loaded.");
			}
		}
		
	// Interstitial dismissed
		
		/**
		 * When the interstitial was dismissed by the user. In this case we can load another one for the next time.
		 */
		public function oniAdInterstitalDismissed(event:IAdEvent):void
		{
			log("[AdManager] iAd interstitial dismissed.");
			
			// interstitial dismissed, so we can load another one for the next time
			try
			{
				_timeriAd.stop();
				IAd.iAd.loadInterstitial(false);
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload iAd interstitial again yet.");
			}
		}
		
		/**
		 * When the interstitial was dismissed by the user. In this case we can load another one for the next time.
		 */
		public function onAdMobInterstitalDismissed(event:AdMobEvent):void
		{
			log("[AdManager] AdMob interstitial dismissed.");
			
			// interstitial dismissed, so we can load another one for the next time
			try
			{
				_timerAdMob.stop();
				AdMob.loadInterstitial(AbstractGameInfo.ADMOB_ANDROID_INTERSTITIAL_ID, false, AbstractGameInfo.ADMOB_IOS_INTERSTITIAL_ID);
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload AdMob interstitial again yet.");
			}
		}
		
	// Interstitial shown
		
		/**
		 * The interstitial was successfully shown.
		 */
		public function oniAdInterstitalShown(event:IAdEvent):void
		{
			_timeriAd.stop();
			log("[AdManager] Showing iAd interstitial.");
		}
		
		/**
		 * The interstitial was successfully shown.
		 */
		public function onAdMobInterstitialShown(event:AdMobEvent):void
		{
			_timerAdMob.stop();
			log("[AdManager] Showing AdMob interstitial.");
		}
		
	// Interstitial failed
		
		/**
		 * When the interstitial failed to load. In this case we try to load another one.
		 */
		public function oniAdInterstitalFailed(event:IAdErrorEvent):void
		{
			log("[AdManager] iAd interstitial failed to load.");
			
			// interstitial failed to load, so we can load another one for the next time
			try
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_timeriAd.stop();
					IAd.iAd.loadInterstitial(false);
				}
				else
				{
					_timeriAd.restart();
				}
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload iAd again yet.");
			}
		}
		
		public function onReloadiAdInterstitial():void
		{
			trace("[AdManager] Reload iAd interstitial from timer callback.");
			try
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_timeriAd.stop();
					IAd.iAd.loadInterstitial(false);
				}
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload iAd again yet.");
			}
		}
		
		/**
		 * When the interstitial failed to load. In this case we try to load another one.
		 */
		public function onAdMobInterstitialFailed(event:AdMobErrorEvent):void
		{
			log("[AdManager] AdMob interstitial failed to load.");
			
			// interstitial failed to load, so we can load another one for the next time
			try
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_timerAdMob.stop();
					AdMob.loadInterstitial(AbstractGameInfo.ADMOB_ANDROID_INTERSTITIAL_ID, false, AbstractGameInfo.ADMOB_IOS_INTERSTITIAL_ID);
				}
				else
				{
					_timerAdMob.restart();
				}
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload AdMob interstitial again yet.");
			}
		}
		
		public function onReloadAdMobInterstitial():void
		{
			log("[AdManager] Reload AdMob interstitial from timer callback.");
			try
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_timerAdMob.stop();
					AdMob.loadInterstitial(AbstractGameInfo.ADMOB_ANDROID_INTERSTITIAL_ID, false, AbstractGameInfo.ADMOB_IOS_INTERSTITIAL_ID);
				}
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload AdMob interstitial again yet.");
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Video management
		
	// ---------- common api
		
		/**
		 * Statistics zone. */
		public static const VIDEO_ZONE_STATS:String = "video-zone-stats";
		/**
		 * Game zone. */
		public static const VIDEO_ZONE_GAME:String = "video-zone-game";
		
		/**
		 * Whether a video is available for the given zone id.
		 * 
		 * @param zoneName Use the constants from  AdManager.XXX
		 * 
		 * @return
		 */
		public function isVideoAvailableForZone(zoneName:String):Boolean
		{
			return isAdColonyVideoAvailableForZone(zoneName) || isVidCoinVideoAvailableForZone(zoneName);
		}
		
		/**
		 * Plays a video ad for the given zone id.
		 * 
		 * @param zoneName Use the constants from  AdManager.XXX
		 */
		public function playVideoForZone(zoneName:String):void
		{
			// this is called when a video is available and the user wants to play it
			// so here we need to check wich platform is available
			if(isAdColonyVideoAvailableForZone(zoneName))
				playAdColonyVideoForZone(zoneName);
			else if(isVidCoinVideoAvailableForZone(zoneName))
				playVidcoinVideoForZone(zoneName);
		}
		
		/**
		 * When one of the networks updates the availability of a zone.
		 * 
		 * Listen to the event dispatched by this function in order to update the button state for example.
		 */
		private function onVideoAvailabilityChange():void
		{
			dispatchEventWith(MobileEventTypes.VIDEO_AVAILABILITY_UPDATE);
		}
		
		private function onVideoSuccess():void
		{
			// when a video have been completely viewed
			dispatchEventWith(MobileEventTypes.VIDEO_SUCCESS);
		}
		
		private function onVideoFail():void
		{
			// when a video have been cancelled or there was an error
			dispatchEventWith(MobileEventTypes.VIDEO_FAIL);
		}
		
	// ---------- AdColony
		
		/**
		 * 
		 * @param zoneName
		 * 
		 * @return
		 */
		private function isAdColonyVideoAvailableForZone(zoneName:String):Boolean
		{
			switch (zoneName)
			{
				case VIDEO_ZONE_STATS:
				{
					return _adColony.isVideoAvailable(AbstractGameInfo.ADCOLONY_STATS_PLACEMENT_ID);
				}
				
				case VIDEO_ZONE_GAME:
				{
					return _adColony.isVideoAvailable(AbstractGameInfo.ADCOLONY_GAME_PLACEMENT_ID);
				}
				
				default:
				{
					log("[AdManager] Wrong zone name : " + zoneName);
					return false;
				}
			}
		}
			
		/**
		 * Plays an AdColony ad video
		 * 
		 * @param zoneName
		 */
		private function playAdColonyVideoForZone(zoneName:String):void
		{
			switch (zoneName)
			{
				case VIDEO_ZONE_STATS:
				{
					_adColony.showVideoAd(AbstractGameInfo.ADCOLONY_STATS_PLACEMENT_ID);
					break;
				}
				
				case VIDEO_ZONE_GAME:
				{
					_adColony.showVideoAd(AbstractGameInfo.ADCOLONY_GAME_PLACEMENT_ID);
					break;
				}
				
				default:
				{
					log("[AdManager] Wrong zone name : " + zoneName);
				}
			}
		}
		
		/**
		 * When an AdColony ad starts.
		 */
		private function onAdColonyAdStarted(event:AdColonyAdStartedEvent):void
		{
			log("[AdManager] AdColony ad started.");
		}
		
		/**
		 * When an AdColony ad is over.
		 */
		private function onAdColonyAdFinished(event:AdColonyAdFinishedEvent):void
		{
			if(event.success)
			{
				log("[AdManager] AdColony ad play success.");
				onVideoSuccess()
			}
			else
			{
				log("[AdManager] AdColony ad play fail.");
				onVideoFail();
			}
		}
		
		/**
		 * When the AdColony video ability changes.
		 */
		public function onAdColonyAvailabilityChange(event:AdColonyAdAvailabilityChangeEvent):void
		{
			log("[AdManager] Video for zone : " + event.zone + " is " + (event.available ? "" : "not") + " available");
			onVideoAvailabilityChange();
		}
		
	// --------- VidCoin
		
		/**
		 *
		 * @param zoneName
		 *
		 * @return
		 */
		private function isVidCoinVideoAvailableForZone(zoneName:String):Boolean
		{
			switch (zoneName)
			{
				case VIDEO_ZONE_STATS:
				{
					return _vidCoin.videoIsAvailableForPlacement(AbstractGameInfo.VIDCOIN_STATS_PLACEMENT_ID);
				}
				
				case VIDEO_ZONE_GAME:
				{
					return _vidCoin.videoIsAvailableForPlacement(AbstractGameInfo.VIDCOIN_GAME_PLACEMENT_ID);
				}
				
				default:
				{
					log("[AdManager] Wrong zone name : " + zoneName);
					return false;
				}
			}
		}
		
		/**
		 * Plays a Vidcoin ad video.
		 *
		 * @param zoneName
		 */
		private function playVidcoinVideoForZone(zoneName:String):void
		{
			switch (zoneName)
			{
				case VIDEO_ZONE_STATS:
				{
					_vidCoin.playAdForPlacement(AbstractGameInfo.VIDCOIN_STATS_PLACEMENT_ID);
					break;
				}
				
				case VIDEO_ZONE_GAME:
				{
					_vidCoin.playAdForPlacement(AbstractGameInfo.VIDCOIN_GAME_PLACEMENT_ID);
					break;
				}
				
				default:
				{
					log("[AdManager] Wrong zone name : " + zoneName);
				}
			}
		}
		
		public function handleVidCoinEvent(event:VidCoinEvents):void
		{
			var eventCode:String = event.code;
			switch (eventCode)
			{
				case "vidcoinViewWillAppear":
				case "vidCoinViewWillAppear":
				{
					// the video appears, here we need to insert a line in the database, stop sounds, etc.
					break;
				}
				case "vidcoinViewDidDisappearWithInformation":
				case "vidCoinViewDidDisappearWithViewInformation":
				{
					// the video left the screen, here we can resume audio and refresh the stakes if necessary
					if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeSuccess)
					{
						// success
						onVideoSuccess();
					}
					else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeError)
					{
						// error
						onVideoFail();
					}
					else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeCancel)
					{
						// cancelled
						onVideoFail();
					}
					break;
				}
				
				case "vidcoinDidValidateView":
				case "vidCoinDidValidateView":
				{
					// always called after the delegate method "vidcoinViewDidDisappearWithInformation"
					if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeSuccess)
					{
						// success
						//Flox.logEvent("Affichages d'une vidéo VidCoin", {Visionnage:"Validé"});
					}
					else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeError)
					{
						// error
						//Flox.logEvent("Affichages d'une vidéo VidCoin", {Visionnage:"Erreur"});
					}
					else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeCancel)
					{
						// cancelled
						//Flox.logEvent("Affichages d'une vidéo VidCoin", {Visionnage:"Annulée"});
					}
					
					break;
				}
				case "vidcoinCampaignsUpdate":
				case "vidCoinCampaignsUpdate":
				{
					// maybe a new video available
					onVideoAvailabilityChange();
					break;
				}
			}
		}
		
		
		
//------------------------------------------------------------------------------------------------------------
//	TapJoy API
		
		// ----- connect handlers
		
		/*public function onConnectSuccess():void
		{
			log("TapJoy connect success");
			prepareTapjoyContent();
		}*/
		
		/*public function onConnectFail():void
		{
			log("TapJoy connect fail");
		}*/
		
	// ----- fsdfs
		
		/**
		 * This call should be made in advance in order the "prepare" the content that will be show
		 * (caching a video ad for example).
		 * 
		 * This won't show the content right after, to do so, call showTapjoyContent instead
		 */
		/*public function prepareTapjoyContent():void
		{
			_statisticsVideoAccessPlacement.requestContent();
		}*/
		
		/**
		 * Shows the content.
		 */
		/*public function showTapjoyContent():void
		{
			if(_statisticsVideoAccessPlacement.isContentReady)
			{
				_statisticsVideoAccessPlacement.showContent();
			}
			else
			{
				//Handle situation where content is not available or not yet loaded
			}
		}*/
		
	// ----- placement handlers
		
		/**
		 * TapJoy pacement request success.
		 */
		/*public function onRequestSuccess(placement:TJPlacement):void
		{
			// request succeeded, not necessarily any content to show
		}*/
		
		/**
		 * Placement request failure.
		 * 
		 * @param placement
		 * @param error
		 */
		/*public function onRequestFailure(placement:TJPlacement, error:String):void
		{
			
		}*/
		
		/**
		 * The content is ready to show.
		 * 
		 * @param placement
		 */
		/*public function onContentReady(placement:TJPlacement):void
		{
			// called when content is ready to show
			
		}*/
		
		/**
		 * When the content is shown.
		 * 
		 * @param placement
		 */
		/*public function onContentShow(placement:TJPlacement):void
		{
			// when the content is shown ?
		}*/
		
		/**
		 * When the content is dismissed.
		 * 
		 * @param placement
		 */
		/*public function onContentDismiss(placement:TJPlacement):void
		{
			// TODO check this : after a content have been shown, we must prepare another one
			_statisticsVideoAccessPlacement.requestContent();
		}*/
		
		//called when user clicks the product link in IAP promotion content
		/*public function onPurchaseRequest(placement:TJPlacement, request:TJActionRequest, productId:String):void
		{
			
		}*/
		
		//called when the reward content is closed by the user
		/*public function onRewardRequest(placement:TJPlacement, request:TJActionRequest, itemId:String, quantity:int):void
		{
			
		}*/
		
//------------------------------------------------------------------------------------------------------------
//	Dispose banners
		
		/**
		 * Dispose all banners.
		 */		
		public function disposeBanners():void
		{
			if( _iAdAvailable )
			{
				try
				{
					IAd.iAd.destroyBannerAd();
				} 
				catch(err:Error)
				{
					// probably no banner currently created and/or visible
				}
			}
			
			if( _adMobAvailable )
			{
				try
				{
					AdMob.destroyAd()
				} 
				catch(err:Error)
				{
					// probably no banner currently created and/or visible
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
		
		public static function getInstance():AdManager
		{
			if(_instance == null)
				_instance = new AdManager(new SecurityKey());
			return _instance;
		}
		
	}
}

internal class SecurityKey{}