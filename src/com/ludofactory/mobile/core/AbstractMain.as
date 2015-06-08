/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 29 Mars 2013
*/
package com.ludofactory.mobile.core
{
	
	import com.freshplanet.nativeExtensions.PushNotification;
	import com.gamua.flox.Flox;
	import com.gamua.flox.utils.createUID;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.sound.SoundManager;
	import com.ludofactory.common.utils.log;
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
		
		public function AbstractMain()
		{
			super();
			
			Remote.getInstance();
			LanguageManager.getInstance();
			
			if(stage)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			
			GlobalConfig.android = Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0;
			GlobalConfig.ios = Capabilities.manufacturer.indexOf("iOS") >= 0;
			GlobalConfig.userHardwareData = { os:Capabilities.os, version:Capabilities.version, resolution:(Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY) };
			GlobalConfig.platformName = GlobalConfig.ios ? "ios" : "android";
			GlobalConfig.deviceId = (!GlobalConfig.ios && !GlobalConfig.android) ? "simulator" : createUID(16, "ludofactory");
			
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			mouseEnabled = mouseChildren = false;
			setGameInfo();
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
							_launchImage.width = stage.stageWidth;
							_launchImage.height = stage.stageHeight;
						}
						else
						{
							if(!isCurrentlyPortrait)
							{
								if(_launchImage.height > _launchImage.width)
								{
									// landscape but the image is portrait
									_launchImage.width = GlobalConfig.stageHeight;
									_launchImage.height = GlobalConfig.stageWidth;
									_launchImage.rotation = -90;
									_launchImage.x = 0;
									_launchImage.y = GlobalConfig.stageHeight * 0.5;
								}
							}
							else
							{
								// portrait but the image is landscape
								if(_launchImage.height > _launchImage.width)
								{
									_launchImage.width = GlobalConfig.stageHeight;
									_launchImage.height = GlobalConfig.stageWidth;
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
			Starling.handleLostContext = !GlobalConfig.ios;  // not necessary on iOS. Saves a lot of memory!
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
				
				removeChild(_launchImage);
				_launchImage.unloadAndStop(true);
				_launchImage = null;
			}
			
			appl.loadTheme(bgTexture);
			_starling.start();
			
			if( GlobalConfig.DEMO_MODE )
				new TouchMarkerManager();
			
			stage.autoOrients = true;
			
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
			
			if(CONFIG::DEBUG)
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
				
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackException(stackTrace, false, MemberManager.getInstance());
			} 
			catch(error:Error) { }
		}
		
	}
}