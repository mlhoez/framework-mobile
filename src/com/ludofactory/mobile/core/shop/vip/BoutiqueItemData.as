/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 22 août 2013
*/
package com.ludofactory.mobile.core.shop.vip
{
	public class BoutiqueItemData
	{
		private var _id:int;
		private var _title:String;
		private var _description:String;
		private var _points:String;
		private var _imageUrl:String;
		private var _discount:String;
		
		public function BoutiqueItemData(data:Object)
		{
			_id = data.id;
			_title = data.nom;
			_description = data.descriptif;
			_points = data.nb_points;
			_imageUrl = data.url_image_apercu;
			_discount = data.remise_texte;
		}
		
		public function get id():int { return _id; }
		public function get title():String { return _title; }
		public function get description():String { return _description; }
		public function get points():String { return _points; }
		public function get imageUrl():String { return _imageUrl; }
		public function get discount():String { return _discount; }
	}
}