/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 2 mai 2013
*/
package com.ludofactory.mobile.core
{
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	/**
	 * This is the class handling the localization technique for the application.
	 * The language is stored in a SharedObject so that this preference is
	 * automatically saved between every launch of the application.
	 * éhttp://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/Capabilities.html#language
	 */	
	public class Localizer
	{
		// FIXME A retirer plus tard ? car c'est dans StorageConfig maintenant
		public static const ALL:Vector.<String> = Vector.<String>( [FRENCH, ENGLISH, RUSSIAN, CHINESE, JAPANESE] );
		public static const FRENCH:String   = "fr";
		public static const ENGLISH:String  = "en";
		public static const RUSSIAN:String  = "ru";
		public static const CHINESE:String  = "ch";
		public static const JAPANESE:String = "ja";
		
		/**
		 * Localizer instance */		
		private static var _instance:Localizer;
		
		/**
		 * The current language */		
		private var _lang:String;
		
		/**
		 * The native language */		
		private var _nativeLanguage:String;
		
		/**
		 * All the languages loaded */		
		private var _languagesLoaded:Dictionary;
		
		/**
		 * When the instance is created, the native language will be detected and
		 * the associated language file parsed so that the correct language is
		 * available from the begining.
		 */		
		public function Localizer(sk:SecurityKey)
		{
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_LANGUAGE) != StorageConfig.DEFAULT_LANGUAGE )
			{
				// if the SharedObject has this property, this means that all the languages
				// have already been loaded and stored, so the only thing we need to do here
				// is to retreive all the translations and set the correct language.
				
				_lang = Storage.getInstance().getProperty(StorageConfig.PROPERTY_LANGUAGE);
				_languagesLoaded = Storage.getInstance().getProperty(StorageConfig.PROPERTY_TRANSLATIONS) as Dictionary;
			}
			else
			{
				// this is the first time the user launches the application here we need to define
				// first the user's native language, then we load all the available languages
				
				switch(Capabilities.language)
				{
					case "fr":    { _lang = _nativeLanguage = FRENCH;   break; }
					case "en":    { _lang = _nativeLanguage = ENGLISH;  break; }
					case "ru":    { _lang = _nativeLanguage = RUSSIAN;  break; }
					case "zh-CN":
					case "zh-TW": { _lang = _nativeLanguage = CHINESE;  break; }
					case "ja":    { _lang = _nativeLanguage = JAPANESE; break; }
					default:      { _lang = _nativeLanguage = ENGLISH;  break; }
				}
				
				parseAllLanguages();
				Storage.getInstance().setProperty(StorageConfig.PROPERTY_LANGUAGE, _lang);
				Storage.getInstance().setProperty(StorageConfig.PROPERTY_TRANSLATIONS, _languagesLoaded);
			}
			
			log("[Localizer] Preferred language is " + _lang);
		}
		
		/**
		 * Loads all the available languages and store them in the SharedObject.
		 * This function will only be called once when the user starts the app
		 * for the first time.
		 */		
		private function parseAllLanguages():void
		{
			_languagesLoaded = new Dictionary();
			const len:int = ALL.length;
			for(var i:int = 0; i < len; i++)
				parseLanguage( ALL[i] );
		}
		
		/**
		 * Loads the language given in parameter.
		 * @param language The language file name to load
		 */		
		private function parseLanguage(language:String):void
		{
			if( language in _languagesLoaded )
				return;
			
			var fileStream:FileStream = new FileStream();
			var languageFile:File = File.applicationDirectory.resolvePath( "assets/lang/" + language + ".csv" );
			
			if( languageFile.exists )
			{
				fileStream.open( languageFile, FileMode.READ );
				var splitted:Array = fileStream.readUTFBytes(fileStream.bytesAvailable).split("\n");
				fileStream.close();
				
				var len:int = splitted.length - 1;
				var value:String;
				var final:Dictionary = new Dictionary();
				var elt:Object = {};
				for(var i:int = len; i >= 0; i--)
				{
					value = splitted[i];
					if(value.charAt(0) == "#" || value == "")
					{
						continue;
					}
					else if( value.charAt(0) == "@" ) // global version
					{
						elt.version = int(value.split("\t")[1]);
						continue;
					}
					else if( value.charAt(0) == "$" )
					{
						elt.faqVersion = int(value.split("\t")[1]);
						continue;
					}
					else if( value.charAt(0) == "£" )
					{
						elt.vipVersion = int(value.split("\t")[1]);
						continue;
					}
					else if( value.charAt(0) == "§" )
					{
						elt.newsVersion = int(value.split("\t")[1]);
						continue;
					}
					final[value.split("\t")[0]] = (value.split("\t")[1] as String).replace(/\\n/g, "\n");
				}
				
				elt.translation = final;
				_languagesLoaded[language] = elt;
				
				splitted.length = 0;
				splitted = null;
				final = null;
			}
			
			fileStream = null;
			languageFile = null;
		}
		
		/**
		 * Updates all the translations.
		 * 
		 * <p>The parameter newTranslations is an array...</p>
		 * 
		 * [fr] => object
		 *     version => int
		 *     translation => object
		 *         key (translation key) => value, idCat, idVip, etc.
		 */		
		public function updateTranslations(newTranslations:Object):void
		{
			if( newTranslations )
			{
				var change:Boolean = false;
				
				for(var language:String in newTranslations)
				{
					if( language in _languagesLoaded )
					{
						change = true;
						// the language has been stored before, so we can update the values
						_languagesLoaded[language].version = int(newTranslations[language].version);
						for(var key:String in newTranslations[language].translation)
							_languagesLoaded[language].translation[key] = newTranslations[language].translation[key];
					}
				}
				if( change )
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_TRANSLATIONS, _languagesLoaded);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Main function
		
		/**
		 * Get the translation of the key given in parameter.
		 * @param key
		 */		
		public function translate(key:String):String
		{
			if( key in _languagesLoaded[_lang].translation )
				return  _languagesLoaded[_lang].translation[key];
			return "{" + key + "}";
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get lang():String
		{
			return _lang;
		}
		
		public function set lang(val:String):void
		{
			_lang = val;
			Storage.getInstance().setProperty(StorageConfig.PROPERTY_LANGUAGE, _lang);
		}
		
		/**
		 * Returns an indexed array (whose each key is the name of an available
		 * language, ex : "fr") and the corresponding value is its version.
		 */		
		public function getGlobalLanguagesVersion():Object
		{
			var result:Object = new Object();
			for(var language:String in _languagesLoaded)
			{
				log("Language : " + language + " - version : " + _languagesLoaded[language].version);
				result[language] = int(_languagesLoaded[language].version);
			}
			return result;
		}
		
		/**
		 * Returns the FAQ version number associated to the current
		 * loaded language.
		 */		
		public function getFaqVersion():int { return int(_languagesLoaded[_lang]["faqVersion"]); }
		public function setFaqVersion(version:int):void { _languagesLoaded[_lang]["faqVersion"] = version; }
		
		/**
		 * Returns the VIP version number associated to the current
		 * loaded language.
		 */		
		public function getVipVersion():int { return int(_languagesLoaded[_lang]["vipVersion"]); }
		public function setVipVersion(version:int):void { _languagesLoaded[_lang]["vipVersion"] = version; }
		
		/**
		 * Returns the NEWS version number associated to the current
		 * loaded language.
		 */		
		public function getNewsVersion():int { return int(_languagesLoaded[_lang]["newsVersion"]); }
		public function setNewsVersion(version:int):void { _languagesLoaded[_lang]["newsVersion"] = version; }
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
		
		/**
		 * Returns Localizer instance.
		 */		
		public static function getInstance():Localizer
		{			
			if(_instance == null)
				_instance = new Localizer(new SecurityKey());			
			return _instance;
		}
		
	}
}

internal class SecurityKey{};