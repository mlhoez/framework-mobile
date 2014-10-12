/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 18 sept. 2013
*/
package com.ludofactory.mobile.navigation.highscore
{
	import com.ludofactory.common.gettext.aliases._;

	public class CountryData
	{
		/**
		 * The id. */		
		private var _id:int;
		
		/**
		 * The name. */		
		private var _nameTranslationKey:String;
		
		/**
		 * The short name (FR, Br, etc.). */		
		private var _diminutive:String;
		
		/**
		 * The texture name. */		
		private var _textureName:String;
		
		public function CountryData(data:Object)
		{
			_id = data.id;
			_nameTranslationKey = data.nameTranslationKey;
			_diminutive = data.diminutive;
			_textureName = data.textureName;
		}
		
		public function get id():int { return _id; }
		public function get nameTranslationKey():String { return _nameTranslationKey; }
		public function get diminutive():String { return _diminutive; }
		public function get textureName():String { return _textureName; }
		
		public function toString():String
		{
			return _( _nameTranslationKey );
		}
	}
}