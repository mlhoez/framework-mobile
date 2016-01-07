/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 6 juillet 2015
*/
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	import com.adobe.images.PNGEncoder;
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.encryption.Base64;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.logs.logError;
	import com.ludofactory.common.utils.logs.logWarning;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarDisplayerType;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.animation.WorldClock;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedSuperclassName;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.textures.TextureSmoothing;
	
	/**
	 * Avatar manager.
	 */
	public class AvatarManager extends EventDispatcher
	{
		
		/**
		 * Avatar manager singleton. */
		private static var _instance:AvatarManager;
		
	// ---------- Consts
		
		/**
		 * Allowed extension for the armatures file. */
		private static const ALLOWED_ARMATURES_FILE_EXTENSION:String = "dbswf";
		/**
		 * Allowed extension for the items files. */
		private static const ALLOWED_ITEMS_FILE_EXTENSION:String = "swf";
		
	// ---------- Helper values
		
		/**
		 * Helper matrix used to scale the assets when the avatar is rasterized or for Starling display. */
		private var HELPER_MATRIX:Matrix;
		/**
		 * Helper bitamp data used to avoid too much memory allocations. */
		private var HELPER_BITMAP_DATA:BitmapData;
		/**
		 * Helper bitamp used to avoid too much memory allocations. */
		private var HELPER_BITMAP:Bitmap;
		/**
		 * Helper content used to store the assets retrieved from the SWFs assets. */
		private var HELPER_CONTENT:DisplayObject;
		
		/**
		 * Helper container used to store the rasterized assets (only for native display). */
		private var HELPER_CONTAINER:Sprite;
		
		/**
		 * Helper array used to store the clip labels. */
		protected static var HELPER_LABELS:Array = [];
		/**
		 * Helper value used to store the labels array length. */
		protected static var HELPER_LABELS_LENGTH:int = 0;
		
	// ---------- Other
		
		/**
		 * Whether the manager is ready. It will be ready once the check if the language files have been
		 * cloned to the application storage directory is done. If the files haven't been cloned yet, it
		 * will boe ready right after the clone is complete, otherwise it will be ready right away. */
		private var _isInitialized:Boolean;
		/**
		 * Whether the manager is loading files. */
		private var _isUpdating:Boolean;
		/**
		 * Path of the assets files in the application storage directory, which is "assets/avatars/" by default. */
		private var _assetsPath:String;
		
		/**
		 * Factory manager used to handle multiple factories. */
		private var _factoryManager:FactoryManager;
		
		/**
		 * The avatar itself. */
		private var _avatar:Armature;
		/**
		 * The scale factor (used when the avatar is rasterized). */
		private var _scale:Number;
		
		/**
		 * Helper bone. */
		private var _helperBone:Bone;
		/**
		 * Helper display. */
		private var _helperDisplay:Object;
		
		/**
		 * The assets loader. */
		private var _assetsLoader:Loader;
		/**
		 * Array of assets to load. */
		private var _assetsToLoad:Array;
		/**
		 * The stored assets. */
		private var _assets:Dictionary;
		
		private var _rasterized:Boolean = false;
		
		/**
		 *  */
		private var _binaryDataLoader:URLLoader;
		private var _armatureUrl:String;
		private var _urlRequest:URLRequest;
		
	// ---------- Update
		
		/**
		 * Queue of asset files to download, parse and store. */
		private var _queue:Array;
		
		public function AvatarManager(sk:SecurityKey)
		{
			if(sk == null)
				throw new Error("Erreur : Echec de l'instanciation : Utiliser AvatarManager.getInstance() au lieu de new.");
			
			_isUpdating = false;
			_isInitialized = false;
			
			_scale = GlobalConfig.dpiScale;
			
			_assetsPath = "assets" + File.separator + "avatars" + File.separator;
			
			// load the assets from disk
			_factoryManager = new FactoryManager();
			
			// build the dictionary
			_assets = new Dictionary();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Initialization
		
		/**
		 * We first need to load the asset files (before we check for updates, this way we can still use the app
		 * while everything is updating in the background.
		 * 
		 * As Adobe states, it is not recomended to write/update files into the applicationDirectory
		 * as it invalidates the application’s signature. Among other things, that means we also
		 * won’t have access to the encrypted local store anymore which is for us not possible.
		 *
		 * <p>In addition sometimes, for some reasons we cannot acces the modification date of
		 * files or folders stored whithin the application directory which prevents us from
		 * implementing the checking system directly into the application folder.</p>
		 *
		 * <p>To avoid all these problems, we must copy the assets files at the first initialization
		 * into the applicationStorageDirectory, which is readable / writable. Then we can update
		 * those files later if necessary by checking the last modification date of all files.</p>
		 *
		 * Source : http://blogs.adobe.com/simplicity/2008/06/dont_write_to_app_dir.html
		 */
		public function initialize():void
		{
			log(File.applicationStorageDirectory.resolvePath(_assetsPath).nativePath);
			log(File.cacheDirectory.resolvePath(_assetsPath).nativePath);
			if( !File.applicationStorageDirectory.resolvePath(_assetsPath).exists )
			{
				// the assets files have not been moved into the application storage
				// directory yet (because it is probably the first launch of the app), 
				// or the data have been cleared for some reason, so let's do it now.
				
				if(GlobalConfig.android)
				{
					// the process is rather slow on Android, so we do it asynchronously
					var copyAsync:File = File.applicationDirectory.resolvePath(_assetsPath);
					 copyAsync.addEventListener(flash.events.Event.COMPLETE, onInitializeComplete);
					 copyAsync.copyToAsync(File.applicationStorageDirectory.resolvePath(_assetsPath), true);
				}
				else
				{
					// synchronous way on iOS because it's rather quick
					var copySync:File = File.applicationDirectory.resolvePath(_assetsPath);
					copySync.copyTo(File.applicationStorageDirectory.resolvePath(_assetsPath), true);
					File.applicationStorageDirectory.resolvePath("assets" + File.separator).preventBackup = true; // necessary for iOS
					
					onInitializeComplete();
				}
			}
			else
			{
				onInitializeComplete();
			}
			
			//checkFileIntegrity(); // TODO a terminer
		}
		
		/**
		 * The assets files have successfully been cloned into the application storage directory
		 * of the app (if it wasn't done yet). The class is now ready and will first load the current
		 * locale in order to be able to display some text, then it will send a requets to the server
		 * in order to check if an update is available.
		 */
		private function onInitializeComplete(event:flash.events.Event = null):void
		{
			if(event)
			{
				// an event only when using the asynchronous way to clone language files
				log("[AvatarManager] Assets files successfully copied to the application storage directory.");
				(event.target as File).removeEventListener(flash.events.Event.COMPLETE, onInitializeComplete);
				File.applicationStorageDirectory.resolvePath("assets" + File.separator).preventBackup = true; // necessary for iOS*/
			}
			
			checkForUpdates();
		}
		
		private function loadAll():void
		{
			// load from disk
			var stream:FileStream = new FileStream();
			try
			{
				stream.open(File.applicationStorageDirectory.resolvePath((_assetsPath + File.separator + "armatures" + File.separator + "ludokado-armatures.dbswf")), FileMode.READ);
			}
			catch(error:Error)
			{
				// could not find the file for some reason
				var copySync:File = File.applicationDirectory.resolvePath((_assetsPath + "armatures" + File.separator + "ludokado-armatures.dbswf"));
				copySync.copyTo(File.applicationStorageDirectory.resolvePath((_assetsPath + "armatures" + File.separator + "ludokado-armatures.dbswf")), true);
				stream.open(File.applicationStorageDirectory.resolvePath((_assetsPath + File.separator + "armatures" + File.separator + "ludokado-armatures.dbswf")), FileMode.READ); // try again
			}
			var bytes:ByteArray = new ByteArray();
			stream.readBytes(bytes, 0, stream.bytesAvailable);
			
			_factoryManager.addEventListener(LKAvatarMakerEventTypes.ALL_FACTORIES_READY, onFactoriesReady);
			_factoryManager.parseData(bytes);
		}
		
//------------------------------------------------------------------------------------------------------------
//
		
		/**
		 * Once the factory is ready and the armature data parsed, we can start to load all the assets
		 *
		 * //_avatar.animation.timeScale = 0.5;
		 * 
		 * @param event
		 */
		private function onFactoriesReady(event:starling.events.Event):void
		{
			_factoryManager.removeEventListener(LKAvatarMakerEventTypes.ALL_FACTORIES_READY, onFactoriesReady);
			
			_assetsToLoad = [ new AvatarLocalFileData(AvatarGenderType.BOY, File.applicationStorageDirectory.resolvePath(_assetsPath + "/items/boy-assets.swf"), AvatarFileType.ITEMS),
							  new AvatarLocalFileData(AvatarGenderType.GIRL, File.applicationStorageDirectory.resolvePath(_assetsPath + "/items/girl-assets.swf"), AvatarFileType.ITEMS),
							  new AvatarLocalFileData(AvatarGenderType.POTATO, File.applicationStorageDirectory.resolvePath(_assetsPath + "/items/potato-assets.swf"), AvatarFileType.ITEMS)
							];
			
			loadLocalFile(_assetsToLoad[0]);
		}
		
		private function loadLocalFile(fileToLoadData:AvatarLocalFileData):void
		{
			log("[AvatarManager] Loading " + fileToLoadData.file.url);
			
			log(File.cacheDirectory.resolvePath(_assetsPath).exists, "Vérification du dossier cache");
			log(File.cacheDirectory.resolvePath(_assetsPath + fileToLoadData.fileType + File.separator + fileToLoadData.fileNameWithExtension).exists, "Vérification du fichier dans le cache");
			if(File.cacheDirectory.resolvePath(_assetsPath).exists)
			{
				logWarning(File.cacheDirectory.resolvePath(_assetsPath).getDirectoryListing(), "Directory listing");
			}
			
			// first unload the previous file if necessary and clear the cache
			if(_assets[fileToLoadData.genderId] != null)
			{
				logWarning("[AvatarManager] Unloading deprecated assets for " + AvatarGenderType.gerGenderNameById(fileToLoadData.genderId) + " !");
				(_assets[fileToLoadData.genderId] as LoaderInfo).loader.unloadAndStop(true);
				_assets[fileToLoadData.genderId] = null;
				delete _assets[fileToLoadData.genderId];
				
				// clear the cache for this file
				if(File.cacheDirectory.resolvePath(_assetsPath + fileToLoadData.fileType + File.separator + fileToLoadData.fileNameWithExtension).exists)
				{
					File.cacheDirectory.resolvePath(_assetsPath + fileToLoadData.fileType + File.separator + fileToLoadData.fileNameWithExtension).deleteFile();
				}
			}
			
			// load the first file from disk
			var stream:FileStream = new FileStream();
			try
			{
				stream.open(fileToLoadData.file, FileMode.READ);
			}
			catch(error:Error)
			{
				// the file is missing for some reason, let's bring it back from the app directory
				var copySync:File = File.applicationDirectory.resolvePath(_assetsPath + fileToLoadData.fileType + File.separator + fileToLoadData.fileNameWithExtension);
				copySync.copyTo(File.applicationStorageDirectory.resolvePath(_assetsPath + fileToLoadData.fileType + File.separator + fileToLoadData.fileNameWithExtension), true);
				stream.open(fileToLoadData.file, FileMode.READ); // try again
			}
			var bytes:ByteArray = new ByteArray();
			stream.readBytes(bytes, 0, stream.bytesAvailable);
			
			// necessary to load it on the same application domain on ios
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.applicationDomain = GlobalConfig.android ? null : ApplicationDomain.currentDomain; // multiple domains are not supported on iOS   
			loaderContext.allowCodeImport = true;
			bytes.position = 0;
			
			// the load the byte to get a working swf
			_assetsLoader = new Loader();
			_assetsLoader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, processNextLocalFile);
			_assetsLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_assetsLoader.loadBytes(bytes, loaderContext);
		}
		
		private function processNextLocalFile(event:flash.events.Event):void
		{
			_assetsLoader.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE, processNextLocalFile);
			_assetsLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			if (_assetsToLoad.length > 0)
			{
				var data:AvatarLocalFileData = _assetsToLoad.shift();
				_assets[data.genderId] = event.target as LoaderInfo;
				data.dispose();
				data = null;
			}
			
			if (_assetsToLoad.length > 0)
			{
				// we need to create a new one or the contentLoaderInfo will be erased at each new loading
				loadLocalFile(_assetsToLoad[0]);
			}
			else
			{
				_isInitialized = true; // a mettre à la fin
				
				Starling.current.nativeStage.addEventListener(flash.events.Event.ENTER_FRAME, onNativeEnterFrameHandler);
				
				// FIXME chercher comment améliorer ça, si pas de délais, certains éléments ne s'affichent pas 'ne semblent pas être dispo)
				Starling.juggler.delayCall(dispatchEventWith, 1, LKAvatarMakerEventTypes.AVATAR_READY);
				//dispatchEventWith(LKAvatarMakerEventTypes.AVATAR_READY);
			}
		}
	
		/**
		 * IO error.
		 *
		 * This in theory should never happen.
		 */
		private function onError(error:IOErrorEvent):void
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * Sets the temporary items to the given armature.
		 * 
		 * @param avatar
		 */
		private function setTempItems(avatar:Armature):void
		{
			var currentConfig:LKAvatarConfig = LKConfigManager.getConfigByGender(AvatarData(avatar.userData).genderId);
			
			// then update the graphics accordingly (not all of them because some are linked)
			// the skin color will update the right and left hands, the head, nose and body (for the humans only), faceCustom (boy & girl)
			update(avatar, LudokadoBones.SKIN_COLOR, currentConfig.skinColor.tempLinkageName);
			// the hair color will update the hair, eyebrows, back hair, moustache (potato & boy), beard (boy) and only for the potato : body
			update(avatar, LudokadoBones.HAIR_COLOR, currentConfig.hairColor.tempLinkageName);
			// the eyes color will update the eyes
			update(avatar, LudokadoBones.EYES_COLOR, currentConfig.eyesColor.tempLinkageName);
			// the lips color will update the mouth
			update(avatar, LudokadoBones.LIPS_COLOR, currentConfig.lipsColor.tempLinkageName);
			// update the shirt
			update(avatar, LudokadoBones.SHIRT, currentConfig.shirt.tempLinkageName);
			// update the hat
			update(avatar, LudokadoBones.HAT, currentConfig.hat.tempLinkageName);
			// and the pant for humans
			if(LKConfigManager.currentGenderId != AvatarGenderType.POTATO)
				update(avatar, LudokadoBones.PANT, currentConfig.pant.tempLinkageName);
			// the epaulet for the potato
			if(LKConfigManager.currentGenderId == AvatarGenderType.POTATO)
				update(avatar, LudokadoBones.EPAULET, currentConfig.epaulet.tempLinkageName);
		}
		
		/**
		 * Sets the user items for the given armature.
		 * 
		 * @param avatar
		 */
		private function setUserItems(avatar:Armature):void
		{
			var currentConfig:LKAvatarConfig = LKConfigManager.getConfigByGender(AvatarData(avatar.userData).genderId);
			
			//log("Current config = ");
			//log(currentConfig);
			
			// then update the graphics accordingly (not all of them because some are linked)
			// the skin color will update the right and left hands, the head, nose and body (for the humans only), faceCustom (boy & girl)
			update(avatar, LudokadoBones.SKIN_COLOR, currentConfig.skinColor.linkageName);
			// the hair color will update the hair, eyebrows, back hair, moustache (potato & boy), beard (boy) and only for the potato : body
			update(avatar, LudokadoBones.HAIR_COLOR, currentConfig.hairColor.linkageName);
			// the eyes color will update the eyes
			update(avatar, LudokadoBones.EYES_COLOR, currentConfig.eyesColor.linkageName);
			// the lips color will update the mouth
			update(avatar, LudokadoBones.LIPS_COLOR, currentConfig.lipsColor.linkageName);
			// update the shirt
			update(avatar, LudokadoBones.SHIRT, currentConfig.shirt.linkageName);
			// update the hat
			update(avatar, LudokadoBones.HAT, currentConfig.hat.linkageName);
			// and the pant for humans
			if(LKConfigManager.currentGenderId != AvatarGenderType.POTATO)
				update(avatar, LudokadoBones.PANT, currentConfig.pant.linkageName);
			// the epaulet for the potato
			if(LKConfigManager.currentGenderId == AvatarGenderType.POTATO)
				update(avatar, LudokadoBones.EPAULET, currentConfig.epaulet.linkageName);
		}
		
		/**
		 * Main update loop.
		 */
		/*private function onStarlingEnterFrameHandler(event:starling.events.Event):void
		{
			WorldClock.clock.advanceTime(-1);
		}*/
		
		/**
		 * Main update loop.
		 */
		private function onNativeEnterFrameHandler(event:flash.events.Event):void
		{
			WorldClock.clock.advanceTime(-1);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update
		
		/**
		 * Updates the armature section with the new display.
		 *
		 * @param avatar The avatar to update
		 * @param armatureSection
		 * @param linkageName
		 */
		public function update(avatar:Armature, armatureSection:String, linkageName:String):void
		{
			linkageName = linkageName == "" ? (armatureSection + "_0") : linkageName;
			//log("Setting " + linkageName + " for " + armatureSection);
			
			if(armatureSection == LudokadoBones.HAT) // Changement de chapeau
			{
				if(AvatarData(avatar.userData).genderId == AvatarGenderType.POTATO)
				{
					// update the back hair for the potato because the back hair is linked to the hat
					LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName = (LudokadoBones.BACK_HAIR + "_" + LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAT).tempLinkageExtractedId);
					update(avatar, LudokadoBones.BACK_HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName);
				}
				else
				{
					// for humans, we need to update the hair because a hat can only be worn with the hair_0
					update(avatar, LudokadoBones.HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAIR).tempLinkageName);
				}
			}
			
			if(armatureSection == LudokadoBones.HAIR) // Changement de cheveux
			{
				if(AvatarData(avatar.userData).genderId != AvatarGenderType.POTATO)
				{
					if(LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAT).tempLinkageExtractedId != 0)
					{
						// we updated the hair for the humans. Because the hair cannot be updated if a hat is worn, we
						// need to force the hair_0
						linkageName = LudokadoBones.HAIR +"_0";
					}
					
					LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName = (LudokadoBones.BACK_HAIR + "_" + LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAIR).tempLinkageExtractedId);
					update(avatar, LudokadoBones.BACK_HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName);
				}
			}
			
			if(armatureSection == LudokadoBones.HAIR_COLOR) // Changement de couleur des cheveux
			{
				update(avatar, LudokadoBones.EYEBROWS, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.EYEBROWS).tempLinkageName);
				update(avatar, LudokadoBones.HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAIR).tempLinkageName);
				update(avatar, LudokadoBones.BACK_HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName);
				
				if(AvatarData(avatar.userData).genderId == AvatarGenderType.POTATO)
				{
					update(avatar, LudokadoBones.BODY, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BODY).tempLinkageName);
				}
				
				if(AvatarData(avatar.userData).genderId == AvatarGenderType.POTATO || AvatarData(avatar.userData).genderId == AvatarGenderType.BOY)
				{
					update(avatar, LudokadoBones.MOUSTACHE, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.MOUSTACHE).tempLinkageName);
				}
				
				if(AvatarData(avatar.userData).genderId == AvatarGenderType.BOY)
				{
					update(avatar, LudokadoBones.BEARD, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BEARD).tempLinkageName);
				}
				
				return;
			}
			
			if(armatureSection == LudokadoBones.SKIN_COLOR) // Changement de couleur de peau
			{
				// changement de la frame des mains, tête, bouche et body (sauf Mr Patate)
				update(avatar, LudokadoBones.LEFT_HAND, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.LEFT_HAND).tempLinkageName);
				update(avatar, LudokadoBones.RIGHT_HAND, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.RIGHT_HAND).tempLinkageName);
				update(avatar, LudokadoBones.HEAD, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HEAD).tempLinkageName);
				update(avatar, LudokadoBones.NOSE, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.NOSE).tempLinkageName);
				
				if(AvatarData(avatar.userData).genderId != AvatarGenderType.POTATO)
				{
					update(avatar, LudokadoBones.BODY, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BODY).tempLinkageName);
					update(avatar, LudokadoBones.FACE_CUSTOM, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.FACE_CUSTOM).tempLinkageName);
				}
				
				return;
			}
			
			if(armatureSection == LudokadoBones.EYES_COLOR) // Changements de la couleur des yeux :
			{
				// = changement de la frame des yeux
				update(avatar, LudokadoBones.EYES, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.EYES).tempLinkageName);
				return;
			}
			
			if(armatureSection == LudokadoBones.LIPS_COLOR) // Changements de la couleur des lèvres :
			{
				// = changement de la frame de la bouche
				update(avatar, LudokadoBones.MOUTH, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.MOUTH).tempLinkageName);
				return;
			}
			
			if(armatureSection == LudokadoBones.AGE) // Changement de l'age
			{
				update(avatar, LudokadoBones.HEAD, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HEAD).tempLinkageName);
				return;
			}
			
			// ------------------
			
			// retrieve the bone from the avatar
			_helperBone = avatar.getBone(armatureSection);
			// then get the asset from the correct asset file
			_helperDisplay = getAsset(avatar, armatureSection, linkageName);
			
			// we found both of them
			if (_helperBone && _helperDisplay)
			{
				_helperDisplay.name = armatureSection;
				_helperBone.display = _helperDisplay;
				if(getQualifiedSuperclassName(_helperDisplay).indexOf("flash") != -1)
				{
					// for flash assets (i.e. vector assets, we enable the click on bones)
					_helperDisplay.mouseChildren = false;
					_helperDisplay.mouseEnabled = true;
				}
				else
				{
					// for Starling assets, we make them non touchable (because the textures are squared, we would need
					// to use pixel pefect touch to be able to click on bones)
					_helperDisplay.touchable = AvatarData(avatar.userData).isTouchable;
				}
				// tell the app we updated a bone
				dispatchEventWith(LKAvatarMakerEventTypes.UPDATED_BONE);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		
		/**
		 * Finds an asset by linkage name and returns it.
		 *
		 * The result will be a Sprite if the items must be rasterized, something else otherwise.
		 * 
		 * @param avatar
		 * @param boneName
		 * @param assetLinkageName
		 * 
		 * @return
		 */
		private function getAsset(avatar:Armature, boneName:String, assetLinkageName:String):*
		{
			// no matter what happens and specially if the item is not found, it's better to empty the section
			removeDisplayFromBone(avatar, _helperBone);
			
			try
			{
				HELPER_CONTENT = new (_assets[AvatarData(avatar.userData).genderId].applicationDomain.getDefinition(assetLinkageName) as Class)();
			}
			catch(error:Error)
			{
				logWarning("[WARNING] The item " + assetLinkageName + " from the section " + boneName + " does not exist.");
				return new MovieClip();
			}
			
			if (HELPER_CONTENT is MovieClip)
			{
				// first go to the good main frame (which is the declination)
				if(hasLabel(HELPER_CONTENT as MovieClip, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, boneName).tempFrameName))
					(HELPER_CONTENT as MovieClip).gotoAndStop(LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, boneName).tempFrameName);
				
				// then check for any linked sub movie clips
				checkForClipsToChange(LKConfigManager.getConfigByGender(AvatarData(avatar.userData).genderId), HELPER_CONTENT as MovieClip);
			}
			
			try
			{
				if (_rasterized || AvatarData(avatar.userData).displayType == AvatarDisplayerType.STARLING)
				{
					var bounds:Rectangle = HELPER_CONTENT.getBounds(HELPER_CONTENT);
					if(bounds.width == 0 && bounds.height == 0)
						return HELPER_CONTAINER = new Sprite();
					
					// retrieve the bounds
					HELPER_MATRIX = new Matrix();
					HELPER_MATRIX.translate(bounds.x * -1, bounds.y * -1);
					
					if(HELPER_BITMAP)
					{
						HELPER_BITMAP.bitmapData.dispose();
						HELPER_BITMAP.bitmapData = null;
					}
					HELPER_BITMAP = null;
					
					if(HELPER_BITMAP_DATA)
					{
						HELPER_BITMAP_DATA.dispose();
					}
					HELPER_BITMAP_DATA = null;
					
					// then draw tha MovieClip / Sprite into a Bitmap
					HELPER_BITMAP_DATA = new BitmapData(getNearest2N(HELPER_CONTENT.width), getNearest2N(HELPER_CONTENT.height), true, 0xFFFFFF);
					HELPER_BITMAP_DATA.drawWithQuality(HELPER_CONTENT, HELPER_MATRIX, null, null, null, true, StageQuality.BEST);
					HELPER_BITMAP = new Bitmap(HELPER_BITMAP_DATA, PixelSnapping.NEVER, true);
				
					if(AvatarData(avatar.userData).displayType == AvatarDisplayerType.NATIVE)
					{
						// native
						// handle pivot point in native display list
						HELPER_BITMAP.x = bounds.x;
						HELPER_BITMAP.y = bounds.y;
						
						HELPER_CONTAINER = new Sprite();
						HELPER_CONTAINER.addChild(HELPER_BITMAP);
					}
					else
					{
						// starling
						var image:Image = Image.fromBitmap(HELPER_BITMAP, false); // FIXME PAs de mipmaps : très important pour l'appli du site, peut améliorer les perfs surement si false au lie ude ture par défaut
						image.smoothing = TextureSmoothing.BILINEAR;
						image.pivotX = -bounds.x;
						image.pivotY = -bounds.y;
						return image;
					}
				
					// just in case, stop it
					if( (HELPER_CONTENT is MovieClip))
						(HELPER_CONTENT as MovieClip).gotoAndStop(1);
				
					HELPER_CONTENT = null;
					return HELPER_CONTAINER;
				}
				else
				{
					return HELPER_CONTENT;
				}
			}
			catch(error:Error)
			{
				log("Error when rasterizing : " + error);
			}
		}
		
		
		
		private function hasLabel(clip:MovieClip, frameLabelToCheck:String):Boolean
		{
			if(frameLabelToCheck == null || frameLabelToCheck == "")
				return false;
			
			HELPER_LABELS = clip.currentLabels;
			HELPER_LABELS_LENGTH = HELPER_LABELS.length;
			for (var i:int = 0; i < HELPER_LABELS_LENGTH; i++)
			{
				if(frameLabelToCheck == FrameLabel(HELPER_LABELS[i]).name)
					return true;
			}
			return false;
		}
		
		/**
		 * recursively
		 */
		private function checkForClipsToChange(config:LKAvatarConfig, clip:MovieClip):void
		{
			if( clip.getChildByName(LudokadoBones.AGE) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.AGE) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.AGE]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.AGE) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.AGE]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.AGE) as MovieClip);
			}
			
			if( clip.getChildByName(LudokadoBones.HAIR_COLOR) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.HAIR_COLOR) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.HAIR_COLOR]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.HAIR_COLOR) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.HAIR_COLOR]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.HAIR_COLOR) as MovieClip);
			}
			
			if( clip.getChildByName(LudokadoBones.SKIN_COLOR) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.SKIN_COLOR) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.SKIN_COLOR]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.SKIN_COLOR) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.SKIN_COLOR]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.SKIN_COLOR) as MovieClip);
			}
			
			if( clip.getChildByName(LudokadoBones.EYES_COLOR) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.EYES_COLOR) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.EYES_COLOR]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.EYES_COLOR) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.EYES_COLOR]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.EYES_COLOR) as MovieClip);
			}
			
			if( clip.getChildByName(LudokadoBones.LIPS_COLOR) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.LIPS_COLOR) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.LIPS_COLOR]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.LIPS_COLOR) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.LIPS_COLOR]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.LIPS_COLOR) as MovieClip);
			}
		}
		
		/**
		 * Helper function to quickly remove a displayObject from a bone.
		 */
		public function removeDisplayFromBone(avatar:Armature, bone:Bone):void
		{
			if (!bone || !bone.display)
				return;
			
			if(bone.display.parent)
			{
				if(AvatarData(avatar.userData).displayType == AvatarDisplayerType.NATIVE)
				{
					bone.display.parent.removeChild(bone.display);
				}
				else
				{
					// also dispose the texture or we get the following error :
					// Error #3691: La limite de ressources correspondant à ce type de ressources a été dépassée.
					Image(bone.display).texture.dispose();
					Image(bone.display).removeFromParent(true);
				}
			}
			bone.display = null;
		}
		
		/**
		 * Returns the nearest POT value.
		 */
		private static function getNearest2N(_n:uint):uint
		{
			return _n & _n - 1 ? 1 << _n.toString(2).length : _n;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Image creation (only for native display list)
		
		//private var _tempImg:Image;
		
		public function getPng(genderId:int, useTemporaryItems:Boolean):void
		{
			var avatar:Armature = getAvatar(genderId, AvatarDisplayerType.NATIVE);
			WorldClock.clock.add(avatar);
			avatar.animation.gotoAndPlay("fixed");
			
			if(useTemporaryItems) setTempItems(avatar);
			else setUserItems(avatar);
			
			Starling.juggler.delayCall(getBitmapData, 0.5, avatar);
		}
		
		/**
		 * get image to avatar
		 */
		public function getBitmapData(avatarToDraw:Armature):void
		{
			// get bounds
			var bounds:Rectangle = (avatarToDraw.display as DisplayObject).getBounds(avatarToDraw.display as DisplayObject);
			// then scale the avatar to fit the reference size
			var scale:Number = Utilities.getScaleToFill(LKConfigManager.getConfigByGender(AvatarData(avatarToDraw.userData).genderId).imageRefDimensions.width, LKConfigManager.getConfigByGender(AvatarData(avatarToDraw.userData).genderId).imageRefDimensions.height, LKConfigManager.getConfigByGender(AvatarData(avatarToDraw.userData).genderId).imageDimensions.width, LKConfigManager.getConfigByGender(AvatarData(avatarToDraw.userData).genderId).imageDimensions.height); // 440x600 = ref (avatar designed for) - other is the size to fit in
			
			HELPER_MATRIX = new Matrix();
			HELPER_MATRIX.scale(scale, scale);
			var gap:int = 70;
			HELPER_MATRIX.translate((LKConfigManager.getConfigByGender(AvatarData(avatarToDraw.userData).genderId).imageDimensions.width * 0.5 + gap), (LKConfigManager.getConfigByGender(AvatarData(avatarToDraw.userData).genderId).imageDimensions.height + ((bounds.height + bounds.y) * -scale)));
			
			HELPER_BITMAP_DATA = new BitmapData(LKConfigManager.getConfigByGender(AvatarData(avatarToDraw.userData).genderId).imageDimensions.width, LKConfigManager.getConfigByGender(AvatarData(avatarToDraw.userData).genderId).imageDimensions.height, true, 0xFFFFFF);
			HELPER_BITMAP_DATA.drawWithQuality(avatarToDraw.display as Sprite, HELPER_MATRIX, null, null, null, true, StageQuality.HIGH);
			
			HELPER_BITMAP = new Bitmap(HELPER_BITMAP_DATA, PixelSnapping.NEVER, true);
			HELPER_BITMAP.smoothing = true;
			
			/*if(!_tempImg)
			{
				_tempImg = new Image(Texture.fromBitmap(HELPER_BITMAP));
				_tempImg.touchable = false;
				_tempImg.scaleX = _tempImg.scaleY = 0.85;
				_tempImg.alpha = 0.75;
				(Starling.current.root as StarlingRoot).addChild(_tempImg);
			}
			else
			{
				_tempImg.texture = Texture.fromBitmap(HELPER_BITMAP);
			}*/
			
			dispatchEventWith(LKAvatarMakerEventTypes.AVATAR_IMAGE_CREATED, false, Base64.encodeByteArray(PNGEncoder.encode(HELPER_BITMAP.bitmapData)));
			
			HELPER_BITMAP.bitmapData.dispose();
			HELPER_BITMAP.bitmapData = null;
			HELPER_BITMAP = null;
			
			WorldClock.clock.remove(avatarToDraw);
			avatarToDraw.dispose();
			avatarToDraw = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * Changes the current avatar.
		 * 
		 * @param avatarDisplayType Whether native or starling display
		 */
		public function changeAvatar(avatarDisplayType:String):void
		{
			disposeCurrent();
			
			var savedPosition:Point = _avatar ? new Point(_avatar.display.x, _avatar.display.y) : new Point();
			
			_avatar = _factoryManager.buildArmature(avatarDisplayType, AvatarGenderType.gerGenderNameById(LKConfigManager.currentGenderId));
			_avatar.userData = new AvatarData(LKConfigManager.currentGenderId, avatarDisplayType, false);
			_avatar.cacheFrameRate = 60;
			WorldClock.clock.add(_avatar);
			
			_avatar.animation.gotoAndPlay(LKConfigManager.getConfigByGender(AvatarData(_avatar.userData).genderId).defaultAnimationName);
			_avatar.display.scaleX = _avatar.display.scaleY = _scale;
			_avatar.display.x = savedPosition.x;
			_avatar.display.y = savedPosition.y;
			
			savedPosition = null;
			
			setUserItems(_avatar); // if it's delayed here, some items won't show..................
			
			dispatchEventWith(starling.events.Event.COMPLETE);
		}
		
		/**
		 * Returns an avatar, built with the current gender configuration.
		 * 
		 * @param genderId The gender id
		 * @param avatarDisplayType Whether native or starling display
		 * 
		 * @return
		 */
		public function getAvatar(genderId:int, avatarDisplayType:String):Armature
		{
			var avatar:Armature = _factoryManager.buildArmature(avatarDisplayType, AvatarGenderType.gerGenderNameById(genderId));
			avatar.userData = new AvatarData(genderId, avatarDisplayType, true);
			avatar.animation.gotoAndPlay(LKConfigManager.getConfigByGender(AvatarData(avatar.userData).genderId).defaultAnimationName);
			
			// if the avatar is owned, we need to show its configuration so that the user is not confused
			if(LKConfigManager.getConfigByGender(genderId).isOwned)
				setUserItems(avatar);
			
			return avatar;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get currentAvatar():Armature { return _avatar; }
		public function get currentAvatarDisplayType():String { return AvatarData(_avatar.userData).displayType; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		public function disposeAvatar(avatar:Armature):void
		{
			if( _avatar )
			{
				if(_avatar.userData)
				{
					if(AvatarData(_avatar.userData).displayType == AvatarDisplayerType.STARLING)
					{
						//_avatar.display.removeEventListener(starling.events.Event.ENTER_FRAME, onStarlingEnterFrameHandler);
						_avatar.display.removeFromParent(true);
					}
					else
					{
						//_avatar.display.removeEventListener(flash.events.Event.ENTER_FRAME, onNativeEnterFrameHandler);
						_avatar.display.parent.removeChild(_avatar.display);
					}
				}
				WorldClock.clock.remove(_avatar);
				_avatar.dispose();
				_avatar = null;
			}
		}
		
		public function disposeCurrent():void
		{
			if( _avatar )
			{
				if(AvatarData(currentAvatar.userData).displayType == AvatarDisplayerType.STARLING)
				{
					//_avatar.display.removeEventListener(starling.events.Event.ENTER_FRAME, onStarlingEnterFrameHandler);
					_avatar.display.removeFromParent(true);
				}
				else
				{
					//_avatar.display.removeEventListener(flash.events.Event.ENTER_FRAME, onNativeEnterFrameHandler);
					_avatar.display.parent.removeChild(_avatar.display);
				}
				WorldClock.clock.remove(_avatar);
				_avatar.dispose();
				_avatar = null;
				
				// TODO unload assets
			}
		}
		
		public function dispose():void
		{
			// TODO dispose tout
			
			disposeCurrent();
			
			// remove events, etc.
		}
		
		
//------------------------------------------------------------------------------------------------------------
//	UPDATE SECTION
		
	// ---------- Remote call
		
		/**
		 * This function is called at the launch of the app or when the user is trying to
		 * change the langugae whithin the settings screen.
		 *
		 * <p>It will retireve and store in an object all the downloaded languages and
		 * specially the modification date of each file, by checking the application
		 * storage directory (the files have necessarily been cloned into this folder,
		 * the contrary is impossible so no need to check the application installation
		 * folder) and then request an update by calling the server.</p>
		 */
		public function checkForUpdates():void
		{
			// not ready or already loading : do nothing
			if( _isUpdating )
				return;
			
			_isUpdating = true;
			
			if( AirNetworkInfo.networkInfo.isConnected() && !GlobalConfig.ios ) // dynamic assets update won't work on iOS
				Remote.getInstance().initAvatarMaker(getAssetsLastModificationDate(), onCheckUpdateSuccess, onCheckUpdateFailure, onCheckUpdateFailure, 1, "lol"); // TODO changer le nom de l'écran
			else
				onCheckUpdateFailure();
		}
		
		/**
		 * We
		 * @param result
		 */
		private function onCheckUpdateSuccess(result:Object):void
		{
			if(result.code == 1)
			{
				if(Array(result.avatarsAssetsInfos.armatures).length == 0 && Array(result.avatarsAssetsInfos.items).length == 0)
				{
					// there is nothing to update
					_isUpdating = false;
					if(!_isInitialized)
						loadAll();
					else
						dispatchEventWith(LKAvatarMakerEventTypes.AVATAR_READY);
				}
				else
				{
					// there are some files to update
					enqueue(result);
				}
			}
			else
			{
				onCheckUpdateFailure();
			}
		}
		
		/**
		 * Failure updating the asset files, then we have nothing more to do here, the next check will be
		 * done when the user wants to display the avatar maker screen or at the next launch of the app.
		 */
		private function onCheckUpdateFailure(error:Object = null):void
		{
			logWarning("[AvatarManager] Failure updating the asset files or no network.");
			
			_isUpdating = false;
			
			if(!_isInitialized)
				loadAll();
			else
				dispatchEventWith(LKAvatarMakerEventTypes.AVATAR_READY);
		}
		
	// ---------- Data processing
		
		/**
		 * This is called only when there are assets to update.
		 *
		 * @param data
		 */
		private function enqueue(data:Object):void
		{
			var fileFirstCharacter:String;
			var fileUrl:String;
			var i:int;
			
			_assetsToLoad = [];
			_queue = [];
			
			// if the armatures needs to be updated, we first process this file
			if(Array(data.avatarsAssetsInfos.armatures).length > 0) // the armatures file needs to be updated
			{
				for (i = 0; i < data.avatarsAssetsInfos.armatures.length; i++)
				{
					// retrieve the file name url
					fileUrl = data.avatarsAssetsInfos.armatures[i];
					
					// we first check if the server have sent unauthorized files (such as hidden files or with unsupported extension)
					fileFirstCharacter = String(fileUrl.split("?")[0].split("/").pop()).charAt(0);
					if(fileFirstCharacter == "." || fileFirstCharacter == "_" || (fileUrl.split("?")[0].split("/").pop().split(".")[1]) != ALLOWED_ARMATURES_FILE_EXTENSION)
						continue; // we won't process this file
					
					// it's a valid file, we can enqueue it
					log("[AvatarUpdater] Enqueuing file '" + fileUrl + "' for type " + AvatarFileType.ARMATURES);
					_queue.push(new AvatarRemoteFileData(fileUrl, AvatarFileType.ARMATURES));
				}
			}
			
			// if the items needs to be updated
			if(Array(data.avatarsAssetsInfos.items).length > 0) // the assets file needs to be updated
			{
				for (i = 0; i < data.avatarsAssetsInfos.items.length; i++)
				{
					// retrieve the file name url
					fileUrl = data.avatarsAssetsInfos.items[i];
					
					// we first check if the server have sent unauthorized files (such as hidden files or with unsupported extension)
					fileFirstCharacter = String(fileUrl.split("?")[0].split("/").pop()).charAt(0);
					if (fileFirstCharacter == "." || fileFirstCharacter == "_" || (fileUrl.split("?")[0].split("/").pop().split(".")[1]) != ALLOWED_ITEMS_FILE_EXTENSION)
						continue; // we won't process this file
					
					// it's a valid file, we can enqueue it
					log("[AvatarUpdater] Enqueuing file '" + fileUrl + "' for type " + AvatarFileType.ITEMS);
					_queue.push(new AvatarRemoteFileData(fileUrl, AvatarFileType.ITEMS));
				}
			}
			
			processNextRemoteFile();
		}
		
		/**
		 * Process next file ine the queue.
		 */
		private function processNextRemoteFile():void
		{
			if( _queue.length <= 0 )
			{
				complete();
				return;
			}
			
			// get the file info
			var fileToLoadInfo:AvatarRemoteFileData = _queue.pop();
			
			// then load it from the remote source
			_urlRequest = new URLRequest();
			_urlRequest.url = fileToLoadInfo.url;
			_urlRequest.cacheResponse = false;
			_urlRequest.useCache = false;
			var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
			_urlRequest.data = new URLVariables("cache=no+cache");
			_urlRequest.method = URLRequestMethod.POST;
			_urlRequest.requestHeaders.push(header);
			
			var urlLoader:URLLoader = null;
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			urlLoader.addEventListener(flash.events.Event.COMPLETE, onUrlLoaderComplete);
			urlLoader.load(_urlRequest);
			
			function onIoError(event:IOErrorEvent):void
			{
				log("[AvatarUpdater] Cannot download " + event.text);
				
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				urlLoader.removeEventListener(flash.events.Event.COMPLETE, onUrlLoaderComplete);
				
				urlLoader.close();
				urlLoader = null;
				
				// process next anyway
				processNextRemoteFile();
			}
			
			function onUrlLoaderComplete(event:Object):void
			{
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				urlLoader.removeEventListener(flash.events.Event.COMPLETE, onUrlLoaderComplete);
				
				// retrieve the file binary content
				var bytes:ByteArray = urlLoader.data as ByteArray;
				
				// "?v="+getTimer()
				var file:File = File.applicationStorageDirectory.resolvePath(_assetsPath + fileToLoadInfo.fileType + File.separator + fileToLoadInfo.name + "." + fileToLoadInfo.extension);
				//file.deleteFile();
				file.deleteFile();
				
				var file:File = File.applicationStorageDirectory.resolvePath(_assetsPath + fileToLoadInfo.fileType + File.separator + fileToLoadInfo.name + "." + fileToLoadInfo.extension);
				
				// FIXME essayer openAsync si ça freeze
				// save the file in the application storage directory
				var fileStream:FileStream = new FileStream();
				var path:String = File.applicationStorageDirectory.nativePath + File.separator + "assets" + File.separator + "avatars" + File.separator + fileToLoadInfo.fileType + File.separator + fileToLoadInfo.name + "." + fileToLoadInfo.extension;
				fileStream.open(file/*new File(path)*/, FileMode.WRITE);
				fileStream.writeBytes(bytes, 0, bytes.length);
				fileStream.close();
				fileStream = null;
				
				urlLoader.close();
				urlLoader = null;
				
				// reload the assets
				// TODO voir comment gérer une màj de l'armature...
				if(fileToLoadInfo.fileType == AvatarFileType.ITEMS)
				{
					logError(fileToLoadInfo);
					_assetsToLoad.push( new AvatarLocalFileData(AvatarGenderType.getGenderIdByName(fileToLoadInfo.genderName), File.applicationStorageDirectory.resolvePath(_assetsPath + "/items/" + fileToLoadInfo.name + ".swf"), fileToLoadInfo.fileType) );
					logError(_assetsToLoad[_assetsToLoad.length-1].file.url);
				}
				
				// process next
				processNextRemoteFile();
			}
			
			// FIXME :
			// if it's an armature : we have to reload all the stuff... maybe we can wait till the next launch
			// if it's the items, we can simply dispatch an event that will refresh the current items (with a setUserItems)
		}
		
		/**
		 * Everything have been downloaded and stored.
		 */
		private function complete():void
		{
			// else nothing to do, files will be parsed only when the user changes the language
			_isUpdating = false;
			
			// everything is up to date (for sure)
			Storage.getInstance().setProperty(StorageConfig.PROPERTY_AVATARS_NEED_UPDATE, false);
			
			logWarning("[AvatarManager] Update is complete (" + _assetsToLoad.length + " are deprecated).");
			if(_isInitialized)
			{
				logWarning("[AvatarManager] The manager is initialized and there are " + _assetsToLoad.length + " to reload !");
				// load the new files
				if(_assetsToLoad.length > 0)
					loadLocalFile(_assetsToLoad[0]);
				else
					dispatchEventWith(LKAvatarMakerEventTypes.AVATAR_READY);
			}
			else
			{
				logWarning("[AvatarManager] The manager is not yet initialized. Initializing...");
				loadAll();
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		/**
		 * Retrieves the lat modification date of all the asset files.
		 *
		 * @return
		 */
		public function getAssetsLastModificationDate():Object
		{
			// build the output
			var output:Object = { armatures:{}, items:{} };
			var forceOlDate:Boolean = Storage.getInstance().getProperty(StorageConfig.PROPERTY_AVATARS_NEED_UPDATE);
			var oldDate:Date = new Date();
			oldDate.setTime(0);
			
			// in case it have not been moved yet
			var armmatureFilesList:Array; // retrieve the list of all installed armatures
			var itemFilesList:Array; // retrieve the list of all installed items
			if(File.applicationStorageDirectory.resolvePath(_assetsPath).exists)
			{
				// if the files have been moved, we can check in this folder
				armmatureFilesList = File.applicationStorageDirectory.resolvePath(_assetsPath + "armatures" + File.separator).getDirectoryListing();
				itemFilesList = File.applicationStorageDirectory.resolvePath(_assetsPath + "items" + File.separator).getDirectoryListing();
			}
			else
			{
				// otherwise we check in the app directory
				armmatureFilesList = File.applicationDirectory.resolvePath(_assetsPath + "armatures" + File.separator).getDirectoryListing();
				itemFilesList = File.applicationDirectory.resolvePath(_assetsPath + "items" + File.separator).getDirectoryListing();
				
				Storage.getInstance().setProperty(StorageConfig.PROPERTY_AVATARS_NEED_UPDATE, true);
				forceOlDate = true;
			}
			
			
			var i:int;
			
			// now retrieve the modification date of all files whithin the armatures folder
			var file:File;
			for(i = 0; i < armmatureFilesList.length; i++)
			{
				file = armmatureFilesList[i];
				if(!file.isHidden) // avoid hidden files like .DS_Store that could have been sent to the app by mistake by PHP
				{
					try
					{
						
						output.armatures[ file.name ] = forceOlDate ? oldDate : file.modificationDate;
					}
					catch(error:Error)
					{
						output.armatures[ file.name ] = oldDate;
						// on some OS we cannot get the modification date from the application directry
					}
				}
			}
			
			for(i = 0; i < itemFilesList.length; i++)
			{
				file = itemFilesList[i];
				if(!file.isHidden) // avoid hidden files like .DS_Store that could have been sent to the app by mistake by PHP
				{
					try
					{
						output.items[ file.name ] = forceOlDate ? oldDate : file.modificationDate;
					}
					catch(error:Error)
					{
						output.items[ file.name ] = oldDate;
						// on some OS we cannot get the modification date from the application directry
					}
				}
			}
			
			// now return the object being used by php
			return output;
		}
		
		
		/**
		 * Simply check if all files are within the folder.
		 */
		private function checkFileIntegrity():void
		{
			// retrieve the list of all installed armatures
			var armatureFilesList:Array = File.applicationDirectory.resolvePath(_assetsPath + "armatures" + File.separator).getDirectoryListing();
			// retrieve the list of all installed items
			var itemFilesList:Array = File.applicationDirectory.resolvePath(_assetsPath + "items" + File.separator).getDirectoryListing();
			
			var i:int;
			
			// now retrieve the modification date of all files whithin the armatures folder
			var file:File;
			for(i = 0; i < armatureFilesList.length; i++)
			{
				file = armatureFilesList[i];
				if(!file.isHidden) // avoid hidden files like .DS_Store that could have been sent to the app by mistake by PHP
				{
					log(file.url);
					//output.armatures[ file.name ] = file.modificationDate;
				}
			}
			
			for(i = 0; i < itemFilesList.length; i++)
			{
				file = itemFilesList[i];
				if(!file.isHidden) // avoid hidden files like .DS_Store that could have been sent to the app by mistake by PHP
				{
					log(file.url);
					//output.items[ file.name ] = file.modificationDate;
				}
			}
			
			/*
			 // retrieve the list of all installed armatures
			 var armatureFilesList:Array = File.applicationStorageDirectory.resolvePath(_assetsPath + "armatures" + File.separator).getDirectoryListing();
			 // retrieve the list of all installed items
			 var itemFilesList:Array = File.applicationStorageDirectory.resolvePath(_assetsPath + "items" + File.separator).getDirectoryListing();
			
			 var i:int;
			
			 // now retrieve the modification date of all files whithin the armatures folder
			 var file:File;
			 for(i = 0; i < armatureFilesList.length; i++)
			 {
			 file = armatureFilesList[i];
			 if(!file.isHidden) // avoid hidden files like .DS_Store that could have been sent to the app by mistake by PHP
			 output.armatures[ file.name ] = file.modificationDate;
			 }
			
			 for(i = 0; i < itemFilesList.length; i++)
			 {
			 file = itemFilesList[i];
			 if(!file.isHidden) // avoid hidden files like .DS_Store that could have been sent to the app by mistake by PHP
			 output.items[ file.name ] = file.modificationDate;
			 }
			 */
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
		
		/**
		 * Singleton.
		 */
		public static function getInstance():AvatarManager
		{
			if(_instance == null)
				_instance = new AvatarManager(new SecurityKey());
			return _instance;
		}
		
	}
}

internal class SecurityKey{}