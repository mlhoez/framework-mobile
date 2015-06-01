/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Based on the work of Vincent Petithory https://github.com/vincent-petithory/as3-gettext
Framework mobile
Author  : Maxime Lhoez
Created : 7 mai 2014
*/
package com.ludofactory.common.gettext
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	/**
	 * ActionScript implementation of GNU Gettext.
	 */	
	public class Gettext
	{
		/**
		 * The default domain from where to pick the translations. */		
		private static const DEFAULT_DOMAIN:String = Domains.COMMON;
		/**
		 * The current locale. */		
		private var _currentLocale:String;
		/**
		 * The loaded locales. */		
		private var _locales:Dictionary;
		
		public function Gettext()
		{
			_locales = new Dictionary(false);
		}
		
		/**
		 * Loads a language
		 * @param locale
		 * 
		 */		
		public function loadLocale(locale:String, forceUpdate:Boolean = false):void
		{
			_currentLocale = locale;
			
			if( locale in _locales && !forceUpdate )
				return; // already loaded and no need to force update
			
			// retrieve the list of all PO files in the <locale> folder
			var filesToLoad:Array = File.applicationStorageDirectory.resolvePath("assets" + File.separator + "locale" + File.separator + locale).getDirectoryListing();
			var poFile:File;
			var parsedPOFile:POFile;
			_locales[_currentLocale] = new Dictionary(false); // = domains
			for(var i:int = 0; i < filesToLoad.length; i++)
			{
				// load each language file
				poFile = filesToLoad[i] as File;
				if( !poFile.isHidden ) // just in case for mac files
				{
					_locales[_currentLocale][poFile.name.split(".")[0]] = parsePOFile(poFile);
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	API
		
		private var _helperTrad:String;
		private var _helperTradTab:Array;
		
		/**
		 * GNU gettext implementation.
		 * 
		 * @param key
		 * 
		 * @return 
		 */		
		public function gettext(key:String):String
		{
			return dgettext(DEFAULT_DOMAIN, key);
		}
		
		/**
		 * GNU dgettext implementation.
		 * 
		 * @param domain 
		 * @param key
		 * 
		 * @return 
		 */		
		public function dgettext(domain:String, key:String):String
		{
			// domain contains a POFile
			key = key.replace(/\n/g, "\\n"); // fixes a bug with multine strings like this : "blabla \n blabla"
			_helperTrad = _locales[_currentLocale][domain].translations[key];
			if( _helperTrad) _helperTrad = _helperTrad.replace(/\\n/g, "\n"); // fixes a bug with multine strings like this : "blabla \n blabla"
			return (_helperTrad == null || _helperTrad == "") ? key : _helperTrad;
		}
		
		/**
		 * GNU ngettext implementation.
		 * 
		 * @param keySingular
		 * @param keyPlural
		 * @param n
		 * 
		 * @return 
		 */		
		public function ngettext(keySingular:String, keyPlural:String, n:int):String
		{
			return dngettext(DEFAULT_DOMAIN, keySingular, keyPlural, n);
		}
		
		/**
		 * GNU dngettext implementation.
		 * 
		 * @param domain
		 * @param keySingular 
		 * @param keyPlural
		 * @param n Value to determine the plural translation
		 * 
		 * @return 
		 */		
		public function dngettext(domain:String, keySingular:String, keyPlural:String, n:int):String
		{
			// domain contains a POFile
			// TODO maybe use the same technique as dgetext to fix the multine issues
			_helperTradTab =  _locales[_currentLocale][domain].translations[keySingular];
			if ( !_helperTradTab || _helperTradTab.length <= 0 )
				return _locales[_currentLocale][domain].getPluralIndex(n) < 1 ? keySingular : keyPlural;
			return _helperTradTab[ _locales[_currentLocale][domain].getPluralIndex(n) ];
		}
	}
}