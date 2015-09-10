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
		 * @param forceUpdate ?
		 */		
		public function loadLocale(locale:String, forceUpdate:Boolean = false):void
		{
			_currentLocale = locale;
			
			if( locale in _locales && !forceUpdate )
				return; // already loaded and no need to force update
			
			// retrieve the list of all PO files in the <locale> folder
			var filesToLoad:Array = File.applicationStorageDirectory.resolvePath("assets" + File.separator + "locale" + File.separator + locale).getDirectoryListing();
			var poFile:File;
			_locales[_currentLocale] = new Dictionary(false); // = domains
			for(var i:int = 0; i < filesToLoad.length; i++)
			{
				// load each language file
				poFile = filesToLoad[i] as File;
				if(poFile.isHidden || poFile.name.charAt(0) == "." || poFile.name.charAt(0) == "_") // just in case for hidden files and files to delete : "_"
					continue;
				_locales[_currentLocale][poFile.name.split(".")[0]] = parsePOFile(poFile);
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
			if( _currentLocale )
			{
				// domain contains a POFile
				_helperTrad = _locales[_currentLocale][domain].translations[ key.replace(/\n/g, "\\n") ]; // fixes a bug with multine strings like this : "blabla \n blabla"
				if( _helperTrad) _helperTrad = _helperTrad.replace(/\\n/g, "\n"); // fixes a bug with multine strings like this : "blabla \n blabla"
			}
			
			return (_helperTrad == null || _helperTrad == "" || !_currentLocale) ? key : _helperTrad;
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
			
			/* AVANT
			_helperTradTab =  _locales[_currentLocale][domain].translations[keySingular];
			if ( !_helperTradTab || _helperTradTab.length <= 0 )
				return _locales[_currentLocale][domain].getPluralIndex(n) < 1 ? keySingular : keyPlural;
			return _helperTradTab[ _locales[_currentLocale][domain].getPluralIndex(n) ];
			*/
			
			// domain contains a POFile
			if( _currentLocale )
			{
				_helperTradTab =  _locales[_currentLocale][domain].translations[keySingular.replace(/\n/g, "\\n")];
				if ( !_helperTradTab || _helperTradTab.length <= 0 )
					return _locales[_currentLocale][domain].getPluralIndex(n) < 1 ? keySingular : keyPlural;
				return _helperTradTab[ _locales[_currentLocale][domain].getPluralIndex(n) ].replace(/\\n/g, "\n");
			}
			
			return n <= 1 ? keySingular : keyPlural;
		}
	}
}