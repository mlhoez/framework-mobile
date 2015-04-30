/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 25 juil. 2013
*/
package com.ludofactory.mobile.application.ads
{
	public class AdData
	{
		private var _imageName:String;
		private var _title:String;
		private var _buttonLabel:String;
		
		public function AdData(imageName:String, title:String, buttonLabel:String)
		{
			_imageName = imageName;
			_title = title;
			_buttonLabel = buttonLabel;
		}
		
		public function get imageName():String   { return _imageName; }
		public function get title():String       { return _title; }
		public function get buttonLabel():String { return _buttonLabel; }
	}
}