/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 26 août 2013
*/
package com.ludofactory.mobile.core.shop.bid.pending
{
	/**
	 * Object used in the BidHomeScreen by each PendingBidItemRenderer
	 * to display a pending bid.
	 */	
	public class PendingBidItemData
	{
		/**
		 * The user was not connected when he displayed the bid. */		
		public static const STATE_NOT_CONNECTED:int = 0;
		/**
		 * The user can bid. */		
		public static const STATE_CAN_BID:int = 1;
		/**
		 * The user is the actual winner of the bid. */		
		public static const STATE_ACTUAL_WINNER:int = 2;
		/**
		 * The bid is finished (waiting for the CRON task). */		
		public static const STATE_FINISHED:int = 3;
		
		/**
		 * Bid id. */		
		private var _id:int;
		
		/**
		 * Name of the gift to win. */		
		private var _name:String;
		
		/**
		 * Description of the gift to win. */		
		private var _description:String;
		
		/**
		 * Name of the last bidder. */		
		private var _lastBidder:String;
		
		/**
		 * Minimum bid value. */		
		private var _minimumBid:int;
		
		/**
		 * The time left before the bid is finished. */		
		private var _timeLeft:int;
		
		/**
		 * The image url */		
		private var _imageUrl:String;
		
		/**
		 * Bid state :
		 * <p>0 = not logged in so the user cannot make a bid</p>
		 * <p>1 = the user is logged in and can make a bid</p>
		 * <p>2 = the user is logged in and is actually the winner of the bid.</p>
		 * <p>3 = The bid is finished (waiting for the CRON task to determine the winner.</p> */		
		private var _state:int;
		
		public function PendingBidItemData(data:Object)
		{
			_id = data.id;
			_name = data.nom;
			_description = data.descriptif;
			_lastBidder = data.encherisseur;
			_minimumBid = data.enchere_mini;
			_timeLeft = data.temps_restant;
			_imageUrl = data.url_image_grande;
			_state = data.etat;
		}
		
		public function get id():int { return _id; }
		public function get name():String { return _name; }
		public function get description():String { return _description; }
		public function get lastBidder():String { return _lastBidder; }
		public function get minimumBid():int { return _minimumBid; }
		public function get timeLeft():int { return _timeLeft; }
		public function get imageUrl():String { return _imageUrl; }
		public function get state():int { return _state; }
	}
}