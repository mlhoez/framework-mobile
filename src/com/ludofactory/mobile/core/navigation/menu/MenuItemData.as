/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.core.navigation.menu
{
	/**
	 * Data used by the menu to display the categories.
	 * 
	 * @see com.ludofactory.mobile.core.navigation.menu.Menu
	 */	
	public class MenuItemData
	{
		/**
		 * Name of the texture to retrieve from the atlas. */		
		private var _iconTextureName:String;
		
		/**
		 * Title of the category in the menu. */		
		private var _title:String;
		
		/**
		 * The screen where this category redirects. */		
		private var _screenLinked:String;
		
		/**
		 * The badge number displayed a the top right when there
		 * are some alerts related to this category. */		
		private var _badgeNumber:int;
		
		public function MenuItemData(iconTextureName:String, title:String, screenLinked:String, badgeNumber:int = 0)
		{
			_iconTextureName = iconTextureName;
			_title = title;
			_screenLinked = screenLinked;
			_badgeNumber = badgeNumber;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get /Set
		
		public function get textureName():String { return _iconTextureName; }
		public function set textureName(val:String):void { _iconTextureName = val; }
		public function get title():String { return _title; }
		public function set title(val:String):void { _title = val; }
		public function get screenLinked():String { return _screenLinked; }
		public function get badgeNumber():int { return _badgeNumber; }
		public function set badgeNumber(val:int):void { _badgeNumber = val; }
		
	}
}