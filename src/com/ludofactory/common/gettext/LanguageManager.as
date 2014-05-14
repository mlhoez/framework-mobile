/*
Copyright © 2006-2014 Ludo Factory
Based on the work of Vincent Petithory https://github.com/vincent-petithory/as3-gettext
Framework mobile
Author  : Maxime Lhoez
Created : 7 mai 2014
*/
package com.ludofactory.common.gettext
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import starling.events.EventDispatcher;

	/**
	 * Language manager.
	 */	
	public class LanguageManager extends EventDispatcher
	{
		public static const FRENCH:String   = "fr";
		public static const ENGLISH:String  = "en";
		
		// ---- DEBUG ONLY
		
		/**
		 * Sample queue for testing purpose. */		
		public static var SAMPLE_QUEUE:Object = { es : ["http://ludokadom.mlhoez.ludofactory.dev/_testTrad/game.po"] };
		
		// ----
		
		/**
		 * LanguageManager instance. */		
		private static var _instance:LanguageManager;
		
		/**
		 * The default language used if there are no translations whithin
		 * the application storage directory.
		 * 
		 * @see com.ludofactory.common.gettext.ISO_639_1 */		
		private static const DEFAULT_LANGUAGE:String = ISO_639_1.codes[ISO_639_1.EN];
		
		/**
		 * The allowed extension file. Used to check the file being
		 * parsed by <code>parsePoFile</code> for security reasons. */		
		private static const ALLOWED_EXTENSION_FILE:String = "po";
		
		/**
		 * The current locale.
		 * 
		 * @see com.ludofactory.common.gettext.ISO_639_1 */		
		private var _currentLocale:String = DEFAULT_LANGUAGE;
		
		/**
		 * Queue of language files to download, parse and store. */		
		private var _queue:Array;
		
		/**
		 * Whether the manager is ready. It will be ready once the check if the
		 * language files have been cloned to the application storage directory
		 * is done. If the files haven't been cloned yet, it will boe ready right
		 * after the clone is complete, otherwise it will be ready right away. */		
		private var _isReady:Boolean;
		/**
		 * Whether the manager is loading files. */		
		private var _isUpdating:Boolean;
		/**
		 * Whether the translations for the current language are deprecated. */		
		private var _isCurrentLanguageDeprecated:Boolean;
		
		/**
		 * Path of the language files in the application storage directory,
		 * which is "assets/locale/" by default. */		
		private var _localePath:String;
		
		public function LanguageManager(sk:SecurityKey):void
		{
			_queue = [];
			
			_isCurrentLanguageDeprecated = false;
			_isUpdating = false;
			_isReady = false;
			
			_localePath = "assets" + File.separator + "locale" + File.separator;
			
			initialize();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Initialization
		
		/**
		 * As Adobe states, it is not recomended to write/update files into the applicationDirectory
		 * as it invalidates the application’s signature. Among other things, that means we also
		 * won’t have access to the encrypted local store anymore which is for not possible.
		 * 
		 * <p>In addition sometimes, for some reasons we cannot acces the modification date of
		 * files or folders stored whithin the application directory which prevents us from
		 * implementing the checking system directly into the application folder.</p>
		 * 
		 * <p>To avoid all these problems, we must copy the lang files at the first initialization
		 * into the applicationStorageDirectory, which is readable / writable. Then we can update
		 * those files later if necessary by checking the last modification date of all files.</p>
		 * 
		 * Source : http://blogs.adobe.com/simplicity/2008/06/dont_write_to_app_dir.html
		 */		
		public function initialize():void
		{
			if( !File.applicationStorageDirectory.resolvePath(_localePath).exists )
			{
				// the language files have not been moved into the application storage
				// directory yet (because it is probably the first launch of the app), 
				// or the data have been cleared for some reason, so let's do it now.
				
				// the process is rather slow on Android, so we do it asynchronously
				/*var copyAsync:File = File.applicationDirectory.resolvePath(_localePath);
				copyAsync.addEventListener(Event.COMPLETE, onInitializeComplete);
				copyAsync.copyToAsync(File.applicationStorageDirectory.resolvePath(_localePath), true);*/
				
				// synchronous way
				var copySync:File = File.applicationDirectory.resolvePath(_localePath);
				copySync.copyTo(File.applicationStorageDirectory.resolvePath(_localePath), true);
			}
			
			onInitializeComplete();
		}
		
		/**
		 * The language files have successfully been cloned into the application storage directory
		 * of the app (if it wasn't done yet). The class is now ready and will first load the current
		 * locale in order to be able to display some text, then it will send a requets to the server
		 * in order to check if an update is available.
		 */		
		private function onInitializeComplete(event:Event = null):void
		{
			_isReady = true;
			
			if( event )
			{
				// an event only when using the asynchronous way to clone language files
				log("[LanguageManager] Language files successfully copied to the application storage directory.");
				(event.target as File).removeEventListener(Event.COMPLETE, onInitializeComplete);
			}
			
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_LANGUAGE) != StorageConfig.DEFAULT_LANGUAGE )
			{
				// if the SharedObject has this property, this means that the default language have
				// already been determined in a previous launch, then we can set the <_lang> property
				// and then parse the current language
				_currentLocale = Storage.getInstance().getProperty(StorageConfig.PROPERTY_LANGUAGE);
			}
			else
			{
				// if the language returned by the player is not available, we need to fall back to
				// the default language which is English, then we save this value in the Storage
				if( getInstalledLanguages().indexOf(Capabilities.language) == -1 )
					_currentLocale = DEFAULT_LANGUAGE;
				Storage.getInstance().setProperty(StorageConfig.PROPERTY_LANGUAGE, _currentLocale);
			}
			
			// load current locale
			ASGettext.loadLocale(_currentLocale);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update
		
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
		public function checkForUpdate(checkCurrentLanguageOnly:Boolean = true):void
		{
			// not ready or already loading : do nothing
			if( !_isReady || _isUpdating )
				return;
			
			_isUpdating = true;
			
			/*if( AirNetworkInfo.networkInfo.isConnected() )
				Remote.getInstance().checkForLanguageUpdate(getInstalledLanguageLastModificationDates(checkCurrentLanguageOnly), onUpdateSuccess, onUpdateFailure, onUpdateFailure, 1);
			else
				onUpdateFailure();*/
			
			onUpdateSuccess(SAMPLE_QUEUE);
		}
		
	// Callbacks
		
		/**
		 * Check if there are some files to update.
		 */		
		private function onUpdateSuccess(result:Object):void
		{
			log("[LanguageManager] The language files have been sucessfully updated.");
			enqueue(result);
		}
		
		/**
		 * Failure updating the language files, then we have nothing more to do here, the
		 * next check will be done when the user wants to change the language in the settings
		 * screen or at the next launch of the app.
		 */		
		private function onUpdateFailure(error:Object = null):void
		{
			// TODO DispatchEvent : ready (for the settings screen)
			_isUpdating = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Enqueuing .po files
		
		/**
		 * Enqueues the data returned by amfPhp.
		 * 
		 * <p>The data structure is a follows (indexed object containing arrays) :
		 * <dl>
		 * 	<dt>fr</dt>
		 * 		<dd>[0] => url .mo file n°1 for language fr</dd>
		 * 		<dd>[1] => url .mo file n°2 for language fr</dd>
		 * 		<dd>[n] => url .mo file n°n for language fr</dd>
		 * 	<dt>en</dt>
		 * 		<dd>[0] => url .mo file n°1 for language en</dd>
		 * 		<dd>[1] => url .mo file n°2 for language en</dd>
		 * 		<dd>[n] => url .mo file n°n for language en</dd>
		 * </dl>
		 * </p>
		 * 
		 * @param data
		 */		
		public function enqueue(data:Object):void
		{
			var moFileUrlList:Array;
			for(var languageIsoName:String in data)
			{
				moFileUrlList = data[languageIsoName];
				if( languageIsoName == _currentLocale && moFileUrlList && moFileUrlList.length > 0 ) _isCurrentLanguageDeprecated = true;
				for(var i:int = 0; i < moFileUrlList.length; i++)
					enqueueWithName(moFileUrlList[i], languageIsoName);
			}
			
			moFileUrlList.length = 0;
			moFileUrlList = null;
			
			loadQueue();
		}
		
		/**
		 * Enqueues a single file to the list.
		 * 
		 * <p>It will add an object with the following parameters :
		 * 	- 'fileName' = it is the name of the mo file
		 * 	- 'fileExtension' = extension of the file (can only be .po normally)
		 * 	- 'fileUrl' = url of the .mo file to download and store
		 * 	- 'languageIsoName' = name of the associated language, which also is the folder name
		 * 
		 * @param fileUrl The url of the file to download
		 * @param lang The related lang of the file (i.e the folder where to save the file)
		 */		
		public function enqueueWithName(fileUrl:String, lang:String):void
		{
			log("[LanguageManager] Enqueuing file '" + fileUrl + "' in " + lang);
			// can only be a .po file
			if( (fileUrl.split("?")[0].split("/").pop().split(".")[1]) != ALLOWED_EXTENSION_FILE ) return;
			_queue.push( new LanguageQueuedData( (fileUrl.split("?")[0].split("/").pop().split(".")[0]), 
												 (fileUrl.split("?")[0].split("/").pop().split(".")[1]),
												 fileUrl,
												 lang ) );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Downloading and storing .po files
		
		/**
		 * Loads all enqueued language files (xxx.po) files asynchronously.
		 */		
		private function loadQueue():void
		{
			processNext();
		}
		
		/**
		 * Process next file ine the queue.
		 */		
		private function processNext():void
		{
			if( _queue.length <= 0 )
			{
				complete();
				return;
			}
			
			var fileToLoadInfo:LanguageQueuedData = _queue.pop();
			
			var urlLoader:URLLoader = null;
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
			urlLoader.load(new URLRequest(fileToLoadInfo.url));
			
			function onIoError(event:IOErrorEvent):void
			{
				log("[LanguageManager] Cannot download " + event.text);
				
				urlLoader.close();
				urlLoader = null;
				
				// process next anyway
				processNext();
			}
			
			function onUrlLoaderComplete(event:Object):void
			{
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
				
				if( !File.applicationStorageDirectory.resolvePath(_localePath + fileToLoadInfo.language).exists )
				{
					log("[LanguageManager] New language added : " + fileToLoadInfo.language);
					var arr:Array = Storage.getInstance().getProperty(StorageConfig.PROPERTY_NEW_LANGUAGES).concat();
					arr.push(fileToLoadInfo.language);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_NEW_LANGUAGES, arr);
					dispatchEventWith(LudoEventType.ALERT_COUNT_UPDATED);
				}
				
				// retrieve the file binary content
				var bytes:ByteArray = urlLoader.data as ByteArray;
				// read the file content (uncleaned)
				var fileContent:String = bytes.readUTFBytes(bytes.bytesAvailable);
				// replace all the comments => /^#.*$/gm ----- or /^#.*$(\r|\n)|(\n|\r){3,}/gm
				fileContent = fileContent.replace(/^#.*$/gm, "");
				// then reconstruct the strings that are on 2 a more lines = /"(\r|\n)"/g
				fileContent = fileContent.replace(/"(\r|\n)"/g, " ");
				// then replace the line breaks greater than 2 => /(\r|\n){2,}/g
				fileContent = fileContent.replace(/(\r|\n){2,}/g, "\n\n");
				// clear the byteArray (the new one will be shorter so this is necessary or it
				// will generate weird files when we rewrite it)
				bytes.clear();
				// finally rewrite the file
				bytes.writeMultiByte(fileContent, "UTF-8");
				
				// FIXME essayer openAsync si ça freeze
				// save the file in the application storage directory
				var fileStream:FileStream = new FileStream();
				var path:String = File.applicationStorageDirectory.nativePath + File.separator + _localePath + fileToLoadInfo.language + File.separator + fileToLoadInfo.name + "." + fileToLoadInfo.extension;
				fileStream.open(new File(path), FileMode.WRITE);
				fileStream.writeBytes(bytes, 0, bytes.length);
				fileStream.close();
				fileStream = null;
				
				urlLoader.close();
				urlLoader = null;
				
				// process next
				processNext();
			}
		}
		
		/**
		 * Everything have been downloaded and stored.
		 */		
		private function complete():void
		{
			if( _isCurrentLanguageDeprecated )
			{
				// the current language have been updated, so we need to parse the
				// associated .po files again to be up to date
				ASGettext.loadLocale(_currentLocale, true);
				_isCurrentLanguageDeprecated = false;
			}
			
			// else nothing to do, files will be parsed only when the user changes the language
			_isUpdating = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utilities
		
		/**
		 * Loop through all the sub directories under "assets/locale/" (or another path if specified)
		 * stored in the application storage directory and retrieve the modification date of each file
		 * in order to determine later in PHP which files needs to be updated in the application.
		 * 
		 * <p>Typically, the "assets/locale" folder have this structure :
		 * assets
		 * 	locale
		 * 		[lang]
		 * 			xxx.mo
		 * 			...
		 * 		...
		 * </p>
		 * 
		 * <p>The output is then returned for later use in php.</p>
		 */		
		public function getInstalledLanguageLastModificationDates(checkCurrentLanguageOnly:Boolean):Object
		{
			// retrieve the list of all installed languages
			var installedLanguageList:Array = File.applicationStorageDirectory.resolvePath(_localePath).getDirectoryListing();
			
			var output:Object = {};
			var languageFolder:File;
			var moFileList:Array = [];
			var moFile:File;
			
			// now retrieve the modification date of all files whithin each language folder
			for(var i:int = 0; i < installedLanguageList.length; i++)
			{
				// retrieve all the files within the language folder
				languageFolder = installedLanguageList[i] as File;
				if( !languageFolder.isDirectory ) // just in case for hidden files crated by mac
					continue;
				
				// if we need the informations for the current language only (for speed reasons)
				if( checkCurrentLanguageOnly && languageFolder.name != _currentLocale )
					continue;
				
				// build the output for this languge
				output[ languageFolder.name ] = {};
				
				// loop through all files and store their last modification date
				moFileList = languageFolder.getDirectoryListing();
				for(var j:int = 0; j < moFileList.length; j++)
				{
					moFile = moFileList[j];
					output[ languageFolder.name ][ moFile.name ] = moFile.modificationDate;
				}
			}
			
			languageFolder = null;
			moFileList.length = 0;
			moFileList = null;
			moFile = null;
			
			// now return the object being used by php
			return output;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function getInstalledLanguages():Array
		{
			// retrieve the list of all installed languages
			var installedLanguageList:Array = File.applicationStorageDirectory.resolvePath(_localePath).getDirectoryListing();
			var installedLanguages:Array = [];
			
			// list all languages
			for(var i:int = 0; i < installedLanguageList.length; i++)
				installedLanguages.push( (installedLanguageList[i] as File).name );
			
			// now return the list
			return installedLanguages;
		}
		
		public function get lang():String { return _currentLocale; }
		public function set lang(val:String):void
		{
			_currentLocale = val;
			ASGettext.loadLocale(_currentLocale);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
		
		/**
		 * Returns Localizer instance.
		 */		
		public static function getInstance():LanguageManager
		{			
			if(_instance == null)
				_instance = new LanguageManager(new SecurityKey());			
			return _instance;
		}
		
	}
}

internal class SecurityKey{};