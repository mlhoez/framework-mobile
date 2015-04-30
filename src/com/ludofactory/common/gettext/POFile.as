/*
Copyright © 2006-2015 Ludo Factory
Based on the work of Vincent Petithory https://github.com/vincent-petithory/as3-gettext
Framework mobile
Author  : Maxime Lhoez
Created : 7 mai 2014
*/
package com.ludofactory.common.gettext
{
	import flash.utils.Dictionary;
	
	import r1.deval.D;

	/**
	 * The <code>POFile</code> class holds the data extracted from a binary PO
	 * file : the metadatas and translations.
	 * 
	 * <p>The most important property is the <code>translations</code> property. 
	 * It is a <code>Dictionary</code> instance holding the original strings 
	 * (used as keys) and their translation (the values) of the PO file.
	 * 
	 * <p>Note that in case of a multiple plural form translation, the value of
	 * the key in the Dictionary will be an array containing in [0] the translated
	 * string of the singular form and the others will be the different plural
	 * translations (the number of plural forms will vary depending on the language).
	 * 
	 * The correct plural form will be determined by using the plural expression
	 * extracted from the PO file, which will return an index in the array.</p>
	 */
	public class POFile
	{
		/**
		 * Project-Id-Version */
		private var _projectIdVersion:String;
		/**
		 * POT-Creation-Date. */
		private var _potCreationDate:Date;
		/**
		 * POT-Revision-Date. */
		private var _potRevisionDate:Date;
		/**
		 * Last-Translation */
		private var _lastTranslator:String;
		/**
		 * Language-Team */
		private var _languageTeam:String;
		/**
		 * Language */
		private var _language:String;
		/**
		 * MIME-Version */
		private var _mimeVersion:String;
		/**
		 * Content-Type */
		private var _contentType:String;
		/**
		 * Charset */
		private var _charset:String;
		/**
		 * Content-Transfert-Encoding */
		private var _contentTransfertEncoding:String;
		/**
		 * Plural-Forms (nplurals)  */
		private var _pluralFormsCount:String;
		/**
		 * Plural-Forms (expression)  */
		private var _pluralFormsExpression:String;
		/**
		 * Translations */
		private var _translations:Dictionary;
		
		public function POFile()
		{
			_translations = new Dictionary();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Getters - Setters
		
		/**
		 * "Project-Id-Version" */
		public function get projectIdVersion():String { return _projectIdVersion; }
		public function set projectIdVersion(value:String):void { _projectIdVersion = value; }
		
		/**
		 * POT-Creation-Date. */
		public function get potCreationDate():Date { return _potCreationDate; }
		public function set potCreationDate(value:Date):void { _potCreationDate = value; }
		
		/**
		 * POT-Revision-Date. */
		public function get potRevisionDate():Date { return _potRevisionDate; }
		public function set potRevisionDate(value:Date):void { _potRevisionDate = value; }
		
		/**
		 * Last-Translation */
		public function get lastTranslator():String { return _lastTranslator; }
		public function set lastTranslator(value:String):void { _lastTranslator = value; }
		
		/**
		 * Language-Team */
		public function get languageTeam():String { return _languageTeam; }
		public function set languageTeam(value:String):void { _languageTeam = value; }
		
		/**
		 * Language */
		public function get language():String { return _language; }
		public function set language(value:String):void { _language = value; }
		
		/**
		 * MIME-Version */
		public function get mimeVersion():String { return _mimeVersion; }
		public function set mimeVersion(value:String):void { _mimeVersion = value; }
		
		/**
		 * Content-Type */
		public function get contentType():String { return _contentType; }
		public function set contentType(value:String):void { _contentType = value; }
		
		/**
		 * Charset */
		public function get charset():String { return _charset; }
		public function set charset(value:String):void { _charset = value; }
		
		/**
		 * Content-Transfert-Encoding */
		public function get contentTransfertEncoding():String { return _contentTransfertEncoding; }
		public function set contentTransfertEncoding(value:String):void { _contentTransfertEncoding = value; }
		
		/**
		 * Plural-Forms (nplurals)  */
		public function get pluralFormsCount():String { return _pluralFormsCount; }
		public function set pluralFormsCount(value:String):void { _pluralFormsCount = value; }
		
		/**
		 * Plural-Forms (expression)  */
		public function get pluralFormsExpression():String { return _pluralFormsExpression; }
		public function set pluralFormsExpression(value:String):void { _pluralFormsExpression = value; }
		
		/**
		 * Translations */
		public function get translations():Dictionary { return _translations; }
		public function set translations(value:Dictionary):void { _translations = value; }
		
		/**
		 * Retrieve the plural form index in the array */		
		public function getPluralIndex(val:int):int { return D.evalToInt(_pluralFormsExpression, null, { n:val }); }
		
	}
}