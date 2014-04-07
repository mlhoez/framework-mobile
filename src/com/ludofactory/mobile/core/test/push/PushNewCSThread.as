/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 5 oct. 2013
*/
package com.ludofactory.mobile.core.test.push
{
	public class PushNewCSThread extends AbstractElementToPush
	{
		/**
		 * The theme id. */		
		private var _themeId:int;
		
		/**
		 * The theme translation key. */		
		private var _themeTranslationKey:String;
		
		/**
		 * The message. */		
		private var _message:String;
		
		public function PushNewCSThread(pushType:String = null, themeId:int = -1, themeTranslationKey:String = null, message:String = null)
		{
			super(pushType);
			
			if( themeId == -1 && themeTranslationKey == null && message == null )
				return;
			
			_themeId = themeId;
			_themeTranslationKey = themeTranslationKey;
			_message = message;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		// since this class is saved in the EncryptedLocalStore, everything has to be r/w !
		
		public function get themeId():int { return _themeId; }
		public function set themeId(val:int):void { _themeId = val; }
		
		public function get themeTranslationKey():String { return _themeTranslationKey; }
		public function set themeTranslationKey(val:String):void { _themeTranslationKey = val; }
		
		public function get message():String { return _message; }
		public function set message(val:String):void { _message = val; }
	}
}