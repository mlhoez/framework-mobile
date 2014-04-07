/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 27 août 2013
*/
package com.ludofactory.mobile.core.shop.bid.finished
{
	/**
	 * Object used in the BidHomeScreen by each FinishedBidItemRenderer
	 * to display a finished bid.
	 */	
	public class FinishedBidItemData
	{
		/**
		 * The date when the bid was won. */		
		private var _date:String;
		
		/**
		 * Name of the gift that was won. */		
		private var _name:String;
		
		/**
		 * Description of the gift that was won. */		
		private var _description:String;
		
		/**
		 * Name of the winner. */		
		private var _winnerName:String;
		
		/**
		 * Gift image url. */		
		private var _imageUrl:String;
		
		public function FinishedBidItemData(data:Object)
		{
			_date = data.date;
			_name = data.nom;
			_description = data.descriptif;
			_winnerName = data.nom_joueur;
			_imageUrl = data.url_image_grande;
		}
		
		public function get date():String { return _date; }
		public function get name():String { return _name; }
		public function get description():String { return _description; }
		public function get winnerName():String { return _winnerName; }
		public function get imageUrl():String { return _imageUrl; }
	}
}