/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 nov. 2013
*/
package com.ludofactory.mobile.navigation.ads.store
{
	public class AdStoreData
	{
		/**
		 * The image url. */		
		private var _imageUrl:String;
		
		/**
		 * The link to redirect. */		
		private var _link:String;
		
		private var _imageWidth:Number;
		
		private var _imageHeight:Number;
		
		public function AdStoreData( data:Object )
		{
			_imageUrl = data.image;
			_link = data.lien;
			_imageWidth = data.width;
			_imageHeight = data.height;
		}
		
		public function get imageUrl():String { return _imageUrl; }
		public function get link():String { return _link; }
		public function get imageWidth():Number { return _imageWidth; }
		public function get imageHeight():Number { return _imageHeight; }
	}
}