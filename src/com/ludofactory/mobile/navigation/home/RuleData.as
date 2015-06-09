/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 26 déc. 2013
*/
package com.ludofactory.mobile.navigation.home
{
	public class RuleData
	{
		/**
		 * Type. */		
		private var _type:String;
		
		/**
		 * The rule translation key. */		
		private var _ruleText:String;
		
		/**
		 * The image name in the texture atlas. */		
		private var _imageSource:String;
		
		/**
		 * The image position in the renderer. */		
		private var _imagePosition:String;
		
		public function RuleData(data:Object)
		{
			_type = data.type;
			_ruleText = data.originalRule;
			if( data.hasOwnProperty("imageSource") && data.imageSource != null )
				_imageSource = data.imageSource;
			if( data.hasOwnProperty("imagePosition") && data.imagePosition != null )
				_imagePosition = data.imagePosition;
		}
		
		public function get type():String { return _type; }
		public function get ruleText():String { return _ruleText; }
		public function get imageSource():String { return _imageSource; }
		public function get imagePosition():String { return _imagePosition; }
	}
}