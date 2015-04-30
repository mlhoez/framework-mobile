/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 22 août 2013
*/
package com.ludofactory.mobile.navigation.shop.vip
{
	/**
	 * Boutique category data.
	 */	
	public class BoutiqueCategoryData
	{
		private var _id:int;
		private var _title:String;
		private var _imageNameOrUrl:String;
		
		public function BoutiqueCategoryData(id:int, title:String, imageName:String)
		{
			_id = id;
			_title = title;
			_imageNameOrUrl = imageName;
		}
		
		public function get id():int { return _id; }
		public function get title():String { return _title; }
		public function get imageNameOrUrl():String { return _imageNameOrUrl; }
	}
}