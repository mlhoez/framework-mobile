/*
Copyright © 2006-2015 Ludo Factory
Based on the work of Vincent Petithory https://github.com/vincent-petithory/as3-gettext
Framework mobile
Author  : Maxime Lhoez
Created : 7 mai 2014
*/
package com.ludofactory.common.gettext
{
	public class LanguageQueuedData
	{
		/**
		 * Name of the file to download, without extension. */		
		private var _name:String;
		/**
		 * Extension of the file to download. */		
		private var _extension:String;
		/**
		 * Url of the file to download. */		
		private var _url:String;
		/**
		 * Associated language. */		
		private var _language:String;
		
		public function LanguageQueuedData(name:String, extension:String, url:String, language:String)
		{
			_name = name;
			_extension = extension;
			_url = url;
			_language = language;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Getters
		
		/**
		 * Name of the file to download, without extension. */		
		public function get name():String { return _name; }
		
		/**
		 * Extension of the file to download. */		
		public function get extension():String { return _extension; }
		
		/**
		 * Url of the file to download. */		
		public function get url():String { return _url; }
		
		/**
		 * Associated language. */		
		public function get language():String { return _language; }
		
	}
}