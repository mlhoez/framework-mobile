/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 27 sept. 2013
*/
package com.ludofactory.mobile.navigation.sponsor.info
{
	public class FacebookBonusData
	{
		private var _iconTextureName:String;
		
		private var _title:String;
		
		public function FacebookBonusData( data:Object )
		{
			_iconTextureName = data.iconTextureName;
			_title = data.title;
		}
		
		public function get iconTextureName():String { return _iconTextureName; }
		public function get title():String { return _title; }
	}
}