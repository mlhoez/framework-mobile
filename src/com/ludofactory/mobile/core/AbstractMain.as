/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 29 Mars 2013
*/
package com.ludofactory.mobile.core
{
	
	import com.freshplanet.ane.AirDeviceId;
	import com.freshplanet.nativeExtensions.PushNotification;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.pause.PauseManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.debug.TouchMarkerManager;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.system.DeviceCapabilities;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import org.gestouch.core.Gestouch;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.extensions.starling.StarlingDisplayListAdapter;
	import org.gestouch.extensions.starling.StarlingTouchHitTester;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.input.NativeInputAdapter;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	// don't forget to add this in the subclasses :
	// [SWF(frameRate="60", backgroundColor="#000000")]
	
	public class AbstractMain extends Sprite
	{
		/**
		 * Starling instance. */		
		protected var _starling:Starling;
		
		/**
		 * The root class used by Starling for its initialization.
		 * This class should extend AbstractEntryPoint.
		 * 
		 * @see com.ludofactory.mobile.core.AbstractEntryPoint */		
		protected var _rootClass:Class;
		
		/**
		 *  */		
		private var _launchImage:Loader;
		
		public function AbstractMain()
		{
			super();
			
			GlobalConfig.android = Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0;
			GlobalConfig.ios = Capabilities.manufacturer.indexOf("iOS") >= 0;
			GlobalConfig.userHardwareData = { os:Capabilities.os, version:Capabilities.version, resolution:(Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY) };
			GlobalConfig.platformName = GlobalConfig.ios ? "ios" : (GlobalConfig.android ? "android" : "simulator");
			AirDeviceId.getInstance().getID(null, function(deviceId:String):void{ GlobalConfig.deviceId = deviceId; });
			showLaunchImage();
			
			if(stage)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				GlobalConfig.stageWidth = stage.stageWidth;
				GlobalConfig.stageHeight = stage.stageHeight;
			}
			
			Remote.getInstance();
			LanguageManager.getInstance();
			
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			mouseEnabled = mouseChildren = false;
			setGameInfo();
			loaderInfo.addEventListener(flash.events.Event.COMPLETE, onAppLoaded);
		}
		
		/**
		 * Adds the Splash Screen.
		 * 
		 * A png file for the landscape mode is needed only if the application can start in  this orientation, which is
		 * not our case because we force the portrait orientation in the Main-app.xml. That's why we can remove it so
		 * that the application package is not so heavy.
		 */		
		private function showLaunchImage():void
		{
			var filePath:String;
			var isCurrentlyPortrait:Boolean = this.stage.orientation == StageOrientation.DEFAULT || this.stage.orientation == StageOrientation.UPSIDE_DOWN;
			
			if(GlobalConfig.ios)
			{
				if((Capabilities.screenResolutionX == 1242 || Capabilities.screenResolutionY == 1242) && (Capabilities.screenResolutionY == 2208 || Capabilities.screenResolutionX == 2208))
				{
					//iphone 6 plus
					filePath = isCurrentlyPortrait ? "Default-414w-736h@3x.png" : "Default-414w-736h-Landscape@3x.png";
				}
				else if((Capabilities.screenResolutionX == 1536 || Capabilities.screenResolutionY == 1536) && (Capabilities.screenResolutionY == 2048 || Capabilities.screenResolutionX == 2048))
				{
					//ipad retina
					filePath = isCurrentlyPortrait ? "Default-Portrait@2x.png" : "Default-Landscape@2x.png";
				}
				else if((Capabilities.screenResolutionX == 768 || Capabilities.screenResolutionY == 768) && (Capabilities.screenResolutionY == 1024 || Capabilities.screenResolutionX == 1024))
				{
					//ipad classic
					filePath = isCurrentlyPortrait ? "Default-Portrait.png" : "Default-Landscape.png";
				}
				else if(isCurrentlyPortrait && (Capabilities.screenResolutionX == 750))
				{
					//iphone 6
					filePath = "Default-375w-667h@2x.png";
				}
				else if(Capabilities.screenResolutionX == 640 || Capabilities.screenResolutionY == 640)
				{
					//iphone retina
					if(Capabilities.screenResolutionY == 1136 || Capabilities.screenResolutionX == 1136)
					{
						filePath = "Default-568h@2x.png";
					}
					else
					{
						filePath = "Default@2x.png";
					}
				}
				else if(Capabilities.screenResolutionX == 320 || Capabilities.screenResolutionY == 320)
				{
					//iphone classic
					filePath = "Default.png";
				}
			}
			else if( Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0 )
			{
				if( DeviceCapabilities.isPhone( stage ) )
				{
					filePath = isCurrentlyPortrait ? "Default@2x.png" : "Default-Landscape.png";
				}
				else if( DeviceCapabilities.isTablet( stage ) )
				{
					filePath = isCurrentlyPortrait ? "Default-Portrait@2x.png" : "Default-Landscape@2x.png";
				}
			}
			
			if(filePath)
			{
				var file:File = File.applicationDirectory.resolvePath(filePath);
				if(file.exists)
				{
					var bytes:ByteArray = new ByteArray();
					var stream:FileStream = new FileStream();
					stream.open(file, FileMode.READ);
					stream.readBytes(bytes, 0, stream.bytesAvailable);
					stream.close();
					this._launchImage = new Loader();
					this.addChild(this._launchImage);
					
					this.stage.autoOrients = GlobalConfig.android;
					
					_launchImage.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, function(event:flash.events.Event):void
					{
						_launchImage.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE, arguments.callee);
						
						if( GlobalConfig.android )
						{
							//_launchImage.width = stage.stageWidth;
							//_launchImage.height = stage.stageHeight;
							_launchImage.scaleX = _launchImage.scaleY = Utilities.getScaleToFill(_launchImage.width, _launchImage.height, Capabilities.screenResolutionX, Capabilities.screenResolutionY, true);
							_launchImage.x = (Capabilities.screenResolutionX - _launchImage.width) * 0.5;
							_launchImage.y = (Capabilities.screenResolutionY - _launchImage.height) * 0.5;
						}
						else
						{
							if(!isCurrentlyPortrait)
							{
								if(_launchImage.height > _launchImage.width)
								{
									// landscape but the image is portrait
									_launchImage.width = Capabilities.screenResolutionY;
									_launchImage.height = Capabilities.screenResolutionX;
									_launchImage.rotation = -90;
									_launchImage.x = 0;
									_launchImage.y = Capabilities.screenResolutionY;
								}
							}
							else
							{
								// portrait but the image is landscape
								if(_launchImage.width > _launchImage.height)
								{
									_launchImage.width = Capabilities.screenResolutionY;
									_launchImage.height = Capabilities.screenResolutionX;
									_launchImage.rotation = 45;
									_launchImage.x = 0;
									_launchImage.y = 0;
								}
							}
						}
						
					});
					
					this._launchImage.loadBytes(bytes);
				}
			}
			
			
			/*if(filePath)
			{
				var file:File = File.applicationDirectory.resolvePath(filePath);
				if(file.exists)
				{
					var bytes:ByteArray = new ByteArray();
					var stream:FileStream = new FileStream();
					stream.open(file, FileMode.READ);
					stream.readBytes(bytes, 0, stream.bytesAvailable);
					stream.close();
					
					_launchImage = new Loader();
					_launchImage.loadBytes(bytes);
					addChild(_launchImage);

					if( Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0 )
					{
						_launchImage.width = stage.stageWidth;
						_launchImage.height = stage.stageHeight;
					}
					
					if(isPortraitOnly)
					{
						if( AbstractGameInfo.LANDSCAPE )
						{
							_launchImage.rotation = -45;
							_launchImage.y = stage.fullScreenHeight;
						}
					}
					
					
				}
			}*/
		}
		
		/**
		 * Application is ready.
		 */		
		private function onAppLoaded(event:flash.events.Event):void
		{
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			Flox.init(AbstractGameInfo.FLOX_ID, AbstractGameInfo.FLOX_KEY, AbstractGameInfo.GAME_VERSION);
			Flox.traceLogs = false;
			
			// launch Starling
			Starling.multitouchEnabled = false;  // useful on mobile devices
			Starling.handleLostContext = true; //!GlobalConfig.ios;  // not necessary on iOS. Saves a lot of memory! // FIXME Fait buguer vid coin sur ipad voir si ça vient pas du UI qq chose aussi (statusbar visible en haut)
			_starling = new Starling(_rootClass, stage, null, null, "auto", "auto");
			_starling.enableErrorChecking = CONFIG::DEBUG;
			_starling.simulateMultitouch  = false;
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			
			if(CONFIG::DEBUG)
			{
				_starling.showStats = true;
				_starling.showStatsAt(HAlign.LEFT, VAlign.TOP);
			}
			
			stage.addEventListener(flash.events.Event.RESIZE, onResize, false, int.MAX_VALUE, true);
		}
		
		protected function setGameInfo():void
		{
			throw new Error("setGameInfo must be overriden in subclass.");
		}
		
		/**
		 * Starling's root have been created.
		 */		
		protected function onRootCreated(event:starling.events.Event, appl:AbstractEntryPoint):void
		{
			_starling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			
			if(_launchImage && _launchImage.content)
			{
				var bgTexture:Texture = Texture.fromBitmap(_launchImage.content as Bitmap, false, false);
			}
			
			try
			{
				removeChild(_launchImage);
				_launchImage.unloadAndStop(true);
				_launchImage = null;
			}
			catch(error:Error)
			{
				
			}
			
			appl.loadTheme(bgTexture);
			_starling.start();
			
			if( GlobalConfig.DEMO_MODE )
				new TouchMarkerManager();
			
			Gestouch.addDisplayListAdapter(DisplayObject, new StarlingDisplayListAdapter());
			
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, onPause, false, 0, true);
		}
		
		/**
		 * Good when the application can change the orientation, otherwise, this function is called
		 * only once when the application is starting.
		 */		
		private function onResize(event:flash.events.Event):void
		{
			_starling.stage.stageWidth = stage.stageWidth;
			_starling.stage.stageHeight = stage.stageHeight;
			
			const viewPort:Rectangle = _starling.viewPort;
			viewPort.width = GlobalConfig.stageWidth = stage.stageWidth;
			viewPort.height = GlobalConfig.stageHeight = stage.stageHeight;
			try
			{
				this._starling.viewPort = viewPort;
				if(_starling.root)
					(_starling.root as AbstractEntryPoint).onResize();
			}
			catch(error:Error) {}
			
			if( _launchImage )
			{
				_launchImage.scaleX = _launchImage.scaleY = 1;
				_launchImage.scaleX = _launchImage.scaleY = Utilities.getScaleToFill(_launchImage.width, _launchImage.height, GlobalConfig.stageWidth, GlobalConfig.stageHeight, true);
				_launchImage.x = (GlobalConfig.stageWidth - _launchImage.width) * 0.5;
				_launchImage.y = (GlobalConfig.stageHeight - _launchImage.height) * 0.5;
			}
			
			if(CONFIG::DEBUG)
				this._starling.showStatsAt(HAlign.LEFT, VAlign.TOP);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Pause / Resume handlers
		
		/**
		 * Saved date when the app is deactivated. */
		private var _deactivationDate:Date;
		
		/**
		 * Saved date when the app is reactivated. */
		private var _reactivationDate:Date;
		
		/**
		 * Pauses the engine.
		 * 
		 * <p>When the game becomes inactive, we pause Starling, otherwise, the enter frame
		 * event would report a very long 'passedTime' when the app is reactivated.</p>
		 * 
		 * <p>We also update the badge number if there are some elements to push.</p>
		 */		
		private function onPause(event:flash.events.Event):void
		{
			Flox.flushLocalData();
			
			if( AbstractEntryPoint.pushManager )
				PushNotification.getInstance().setBadgeNumberValue( AbstractEntryPoint.numAlerts );
			PauseManager.pause();
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, onResume, false, 0, true);
			
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED)) )
				SoundManager.getInstance().mutePlaylist("sfx", 0);
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED)) )
				SoundManager.getInstance().mutePlaylist("music", 0);
			
			_deactivationDate = new Date();
		}
		
		/**
		 * Resumes the engine.
		 */		
		private function onResume(event:flash.events.Event):void
		{
			NativeApplication.nativeApplication.removeEventListener(flash.events.Event.ACTIVATE, onResume);
			PauseManager.resume();
			
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED)) )
				SoundManager.getInstance().unmutePlaylist("sfx", 0.5);
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED)) )
				SoundManager.getInstance().unmutePlaylist("music", 0.5);
			
			_reactivationDate = new Date();
			if( _deactivationDate && (_reactivationDate.time - _deactivationDate.time) > Storage.getInstance().getProperty(StorageConfig.PROPERTY_IDLE_TIME) ) // 3 600 000 = 1 hour
				Storage.getInstance().initialize();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Uncaught errors
		
		/**
		 * Log any uncaught error in Flox.
		 */		
		/*private function onUncaughtError(event:UncaughtErrorEvent):void
		{	
			try
			{
				var stackTrace:String = Error(event.error).getStackTrace();
				if (event.error is Error)
					Flox.logError("<strong>Uncaught error :</strong>", "[{0}] {1}<br><br><strong>Occured at :</strong><br>{2}", Error(event.error).errorID, Error(event.error).message, stackTrace);
				else
					log(stackTrace);
				
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackException(stackTrace, false, MemberManager.getInstance());
			} 
			catch(error:Error) { }
		}*/
		
		public static function onUncaughtError(event:UncaughtErrorEvent):void
		{
			try
			{
				throw event.error;
			}
			catch(error:Error)
			{
				var stackTrace:String = error.getStackTrace();
				reportError(error);
				
				Flox.logError("<strong>Uncaught error :</strong>", "[{0}] {1}<br><br><strong>Occured at :</strong><br>{2}", Error(event.error).errorID, Error(event.error).message, stackTrace);
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackException(stackTrace, false, MemberManager.getInstance());
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * Tap gesture. */
		private static var _tapGesture:TapGesture;
		/**
		 * Starling touch hit tester. */
		private static var _starlingTouchHitTester:StarlingTouchHitTester;
		/**
		 * Whether the logs are enabled. */
		private static var _areLogsEnabled:Boolean = false;
		
		public static function checkToEnableLogs():void
		{
			if( MemberManager.getInstance().isAdmin() )
				enableLogs();
			else
				disableLogs();
		}
		
		/**
		 * Enables the logs (for an admin user).
		 */
		public static function enableLogs():void
		{
			if( !_areLogsEnabled )
			{
				if(!Starling.current)
					return;
				
				if( !GlobalConfig.ios && !GlobalConfig.android && !GlobalConfig.amazon )
				{
					_areLogsEnabled = false;
					return;
				}
				
				// Initialized native (default) input adapter. Needed for non-DisplayList usage.
				Gestouch.inputAdapter ||= new NativeInputAdapter(Starling.current.nativeStage);
				
				_starlingTouchHitTester = new StarlingTouchHitTester(Starling.current);
				Gestouch.addTouchHitTester(_starlingTouchHitTester, -1);
				
				_tapGesture = new TapGesture(Starling.current.root);
				_tapGesture.numTapsRequired = 3;
				_tapGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onGesture);
				
				_areLogsEnabled = true;
			}
		}
		
		/**
		 * Gesture detected.
		 */
		private static function onGesture(event:GestureEvent):void
		{
			if( Starling.current && MemberManager.getInstance().isAdmin() ) // just in case
			{
				(Starling.current.root as AbstractEntryPoint).showOrHideLogs();
			}
		}
		
		/**
		 * disables the logs (for a non admin user).
		 */
		public static function disableLogs():void
		{
			if( _areLogsEnabled )
			{
				if(Starling.current)
					(Starling.current.root as AbstractEntryPoint).hideLogs();
				
				(Gestouch.inputAdapter as NativeInputAdapter).onDispose();
				
				Gestouch.removeTouchHitTester(_starlingTouchHitTester);
				
				_starlingTouchHitTester = null;
				
				_tapGesture.removeEventListener(GestureEvent.GESTURE_RECOGNIZED, onGesture);
				_tapGesture.dispose();
				_tapGesture = null;
				
				_areLogsEnabled = false;
			}
		}
		
	}
}