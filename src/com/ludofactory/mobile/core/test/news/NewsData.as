/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 18 sept. 2013
*/
package com.ludofactory.mobile.core.test.news
{
	public class NewsData
	{
		/**
		 * The news id.
		 * Obsolete ? */		
		private var _id:int;
		
		/**
		 * The image to display. */		
		private var _imageUrl:String;
		
		/**
		 * Title of the news. */		
		private var _title:String;
		
		/**
		 * Description of the news. */		
		private var _description:String;
		
		/**
		 * The link to redirect if the user doesn't have the game installed. */		
		private var _link:String;
		
		/**
		 * The url scheme of the game (ex : pyramid://) */		
		private var _urlScheme:String;
		
		/**
		 * The offer id used for app to app tracking purpose.
		 * Mainly used to measure efficience of some advertising
		 * campaigns. */		
		private var _offerId:String;
		
		/**
		 * Bundle identifier of the target app. */		
		private var _targetAppId:String;
		
		/**
		 * To define... */		
		private var _publisherId:String;
		
		/**
		 * To define... */		
		private var _advertiserId:String;
		
		public function NewsData(data:Object = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			if( !data ) return;
			
			if( data.hasOwnProperty("id") && data.id )
				_id = int(data.id);
			
			if( data.hasOwnProperty("titre") && data.titre )
				_title = data.titre;
			
			if( data.hasOwnProperty("description") && data.description )
				_description = data.description;
			
			if( data.hasOwnProperty("url_image") && data.url_image )
				_imageUrl = data.url_image;
			
			if( data.hasOwnProperty("lien") && data.lien )
				_link = data.lien;
			
			if( data.hasOwnProperty("url_scheme") && data.url_scheme )
				_urlScheme = data.url_scheme;
			
			// variables used for app to app tracking
			if( data.hasOwnProperty("id_app") && data.id_app )
				_targetAppId = data.id_app;
			
			if( data.hasOwnProperty("id_offre") && data.id_offre )
				_offerId = data.id_offre;
			
			if( data.hasOwnProperty("publisher_id") && data.publisher_id )
				_publisherId = data.publisher_id;
			
			if( data.hasOwnProperty("advertiser_id") && data.advertiser_id )
				_advertiserId = data.advertiser_id;
		}
		
		// private variables must be r/w
		public function get id():int { return _id; }
		public function set id(val:int):void { _id = val; }
		
		public function get imageUrl():String { return _imageUrl; }
		public function set imageUrl(val:String):void { _imageUrl = val; }
		
		public function get title():String { return _title; }
		public function set title(val:String):void { _title = val; }
		
		public function get description():String { return _description; }
		public function set description(val:String):void { _description = val; }
		
		public function get link():String { return _link; }
		public function set link(val:String):void { _link = val; }
		
		public function get urlScheme():String { return _urlScheme; }
		public function set urlScheme(val:String):void { _urlScheme = val; }
		
		public function get targetAppId():String { return _targetAppId; }
		public function set targetAppId(val:String):void { _targetAppId = val; }
		
		public function get offerId():String { return _offerId; }
		public function set offerId(val:String):void { _offerId = val; }
		
		public function get publisherId():String { return _publisherId; }
		public function set publisherId(val:String):void { _publisherId = val; }
		
		public function set advertiserId(val:String):void { _advertiserId = val; }
		public function get advertiserId():String { return _advertiserId; }
	}
}