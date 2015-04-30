/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 27 août 2013
*/
package com.ludofactory.mobile.navigation.shop.bid.comingsoon
{
	/**
	 * Object used in the BidHomeScreen by each ComingSoonBidItemRenderer
	 * to display a coming soon bid.
	 */	
	public class ComingSoonBidItemData
	{
		/**
		 * Name of the coming soon bid. */		
		private var _name:String;
		
		/**
		 * description of the coming soon bid. */		
		private var _description:String;
		
		/**
		 * Gift image url. */		
		private var _imageUrl:String;
		
		public function ComingSoonBidItemData(data:Object)
		{
			_name = data.name;
			_description = data.descriptif;
			_imageUrl = data.url_image_grande;
		}
		
		public function get name():String { return _name; }
		public function get description():String { return _description; }
		public function get imageUrl():String { return _imageUrl; }
	}
}