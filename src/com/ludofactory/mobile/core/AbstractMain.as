/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 29 Mars 2013
*/
package com.ludofactory.mobile.core
{
	import com.freshplanet.ane.AirDeviceId;
	import com.freshplanet.nativeExtensions.PushNotification;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.pause.PauseManager;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.debug.TouchMarkerManager;
	
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
	
	import eu.alebianco.air.extensions.analytics.Analytics;
	
	import feathers.system.DeviceCapabilities;
	
	import starling.core.Starling;
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
		/**
		 *  */		
		private var _savedAutoOrients:Boolean;
		
		public function AbstractMain()
		{
			super();
			
			Remote.getInstance();
			
			if(stage)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			mouseEnabled = mouseChildren = false;
			showLaunchImage();
			loaderInfo.addEventListener(flash.events.Event.COMPLETE, onAppLoaded);
		}
		
		/**
		 * Adds the Splash Screen.
		 * 
		 * A png file for the landscape mode is needed only if the application can start in 
		 * this orientation, which is not our case because we force the portrait orientation
		 * in the Main-app.xml. That's why we can remove it so that the application package
		 * is not so heavy.
		 */		
		private function showLaunchImage():void
		{
			var filePath:String;
			var isPortraitOnly:Boolean = false;
			if(Capabilities.manufacturer.indexOf("iOS") >= 0)
			{
				if(Capabilities.screenResolutionX == 1536 && Capabilities.screenResolutionY == 2048)
				{
					// iPad retina
					var isCurrentlyPortrait:Boolean = this.stage.orientation == StageOrientation.DEFAULT || this.stage.orientation == StageOrientation.UPSIDE_DOWN;
					filePath = isCurrentlyPortrait ? "Default-Portrait@2x.png" : "Default-Landscape@2x.png";
				}
				else if(Capabilities.screenResolutionX == 768 && Capabilities.screenResolutionY == 1024)
				{
					// iPad non retina
					isCurrentlyPortrait = this.stage.orientation == StageOrientation.DEFAULT || this.stage.orientation == StageOrientation.UPSIDE_DOWN;
					filePath = isCurrentlyPortrait ? "Default-Portrait.png" : "Default-Landscape.png";
				}
				else if(Capabilities.screenResolutionX == 640)
				{
					isPortraitOnly = true;
					if(Capabilities.screenResolutionY == 1136)
					{
						// iPhone retina >= iPhone 5
						filePath = "Default-568h@2x.png";
					}
					else
					{
						// iPhone retina < iPhone 5
						filePath = "Default@2x.png";
					}
				}
				else if(Capabilities.screenResolutionX == 320)
				{
					// iPhone non retina
					isPortraitOnly = true;
					filePath = "Default.png";
				}
			}
			else if( Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0 )
			{
				if( DeviceCapabilities.isPhone( stage ) )
				{
					filePath = "Default@2x.png";
				}
				else if( DeviceCapabilities.isTablet( stage ) )
				{
					filePath = "Default-Portrait@2x.png";
				}
			}
			
			const scaledDPI:int = DeviceCapabilities.dpi / Starling.contentScaleFactor;
			var _originalDPI:int = scaledDPI;
			_originalDPI = DeviceCapabilities.isTablet(stage) ? Theme.ORIGINAL_DPI_IPAD_RETINA : Theme.ORIGINAL_DPI_IPHONE_RETINA;
			var scale:Number = GlobalConfig.dpiScale = scaledDPI / _originalDPI;
			
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
					_launchImage = new Loader();
					_launchImage.loadBytes(bytes);
					addChild(_launchImage);
					if( Capabilities.manufacturer.indexOf("iOS") >= 0 )
					{
						_savedAutoOrients = stage.autoOrients;
						stage.autoOrients = false;
					}
					else
					{
						_launchImage.scaleX = _launchImage.scaleY = scale;
						_launchImage.width = stage.stageWidth;
						_launchImage.height = stage.stageHeight;
					}
					if(isPortraitOnly)
					{
						//this.stage.setOrientation(StageOrientation.DEFAULT); //TODO Problème avec l'iphone
					}
				}
			}
		}
		
		/**
		 * Application is ready.
		 */		
		private function onAppLoaded(event:flash.events.Event):void
		{
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			setGameInfo();
			
			Flox.init(AbstractGameInfo.FLOX_ID, AbstractGameInfo.FLOX_KEY, AbstractGameInfo.GAME_VERSION);
			Flox.traceLogs = false;
			
			GlobalConfig.android = Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0 ? true : false;
			GlobalConfig.ios = Capabilities.manufacturer.indexOf("iOS") >= 0 ? true : false;
			GlobalConfig.userHardwareData = { os:Capabilities.os, version:Capabilities.version, resolution:(Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY) };
			GlobalConfig.platformName = GlobalConfig.ios ? "ios" : "android";
			GlobalConfig.deviceId = AirDeviceId.getInstance().getID("ludofactory");
			
			// launch Starling
			Starling.multitouchEnabled = false;  // useful on mobile devices
			Starling.handleLostContext = !GlobalConfig.ios;  // not necessary on iOS. Saves a lot of memory!
			_starling = new Starling(_rootClass, stage, null, null, "auto", "auto");
			_starling.enableErrorChecking = GlobalConfig.DEBUG;
			_starling.simulateMultitouch  = false;
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			
			if(GlobalConfig.DEBUG)
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
			
			if(_launchImage)
			{
				var bgTexture:Texture = Texture.fromBitmap(_launchImage.content as Bitmap, false, false);
				
				removeChild(_launchImage);
				_launchImage.unloadAndStop(true);
				_launchImage = null;
				if( GlobalConfig.ios )
					stage.autoOrients = _savedAutoOrients;
			}
			
			appl.loadTheme(bgTexture);
			_starling.start();
			
			if( GlobalConfig.DEMO_MODE )
				new TouchMarkerManager();
			
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
			
			if(GlobalConfig.DEBUG)
				this._starling.showStatsAt(HAlign.LEFT, VAlign.TOP);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Pause / Resume handlers
		
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
		}
		
		/**
		 * Resumes the engine.
		 */		
		private function onResume(event:flash.events.Event):void
		{
			// FIXME A remettre ?
			//if( AbstractEntryPoint.pushManager )
			//	PushNotification.getInstance().setBadgeNumberValue( AbstractEntryPoint.numAlerts );
			NativeApplication.nativeApplication.removeEventListener(flash.events.Event.ACTIVATE, onResume);
			PauseManager.resume();
			
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SOUND_ENABLED)) )
				SoundManager.getInstance().unmutePlaylist("sfx", 0.5);
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_MUSIC_ENABLED)) )
				SoundManager.getInstance().unmutePlaylist("music", 0.5);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Uncaught errors
		
		/**
		 * Log any uncaught error in Flox.
		 */		
		private function onUncaughtError(event:UncaughtErrorEvent):void
		{	
			try
			{
				var stackTrace:String = Error(event.error).getStackTrace();
				if (event.error is Error)
					Flox.logError("<strong>Uncaught error :</strong>", "[{0}] {1}<br><br><strong>Occured at :</strong><br>{2}", Error(event.error).errorID, Error(event.error).message, stackTrace);
				else
					log(stackTrace);
				
				if( Analytics.isSupported() && AbstractEntryPoint.tracker )
					AbstractEntryPoint.tracker.buildException(false).withDescription(stackTrace).track();
			} 
			catch(error:Error) { }
		}
		
	}
}