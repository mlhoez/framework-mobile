/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 21 oct. 2013
*/
package com.ludofactory.mobile.navigation.event
{
	public class EventData
	{
		/**
		 * The event type (1 = common event - 2 = rate event) */		
		private var _type:int;
		
		/**
		 * The image url. */		
		private var _imageUrl:String;
		
		/**
		 * The link url (depending on the _linkType value,
		 * it will be an url or a screen name. */		
		private var _link:String;
		
		/**
		 * The color decoration. */		
		private var _decorationColor:uint = 0xe9e9e9;
		
		/**
		 * Whether the decoration should be visible. */		
		private var _decorationVisible:Boolean = true;
		
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
		
		public function EventData(data:Object)
		{
			_type = int(data.type);
			_imageUrl = String(data.image);
			_link = String(data.lien);
			if( data.hasOwnProperty("couleur_deco") && data.couleur_deco )
				_decorationColor = uint(data.couleur_deco);
			if( data.hasOwnProperty("presence_deco") && data.presence_deco )
				_decorationVisible = int(data.presence_deco) == 0 ? false : true;
			
			// variables used for app to app tracking
			if( data.hasOwnProperty("url_scheme") && data.url_scheme )
				_urlScheme = data.url_scheme;
			
			if( data.hasOwnProperty("id_app") && data.id_app )
				_targetAppId = data.id_app;
			
			if( data.hasOwnProperty("id_app") && data.id_app )
				_targetAppId = data.id_app;
			
			if( data.hasOwnProperty("publisher_id") && data.publisher_id )
				_publisherId = data.publisher_id;
			
			if( data.hasOwnProperty("advertiser_id") && data.advertiser_id )
				_advertiserId = data.advertiser_id;
		}
		
		public function get type():int { return _type; }
		public function get imageUrl():String { return _imageUrl; }
		public function get link():String { return _link; }
		public function get decorationColor():uint { return _decorationColor; }
		public function get decorationVisible():Boolean { return _decorationVisible; }
		
		public function get urlScheme():String { return _urlScheme; }
		public function get targetAppId():String { return _targetAppId; }
		public function get offerId():String { return _offerId; }
		public function get publisherId():String { return _publisherId; }
		public function get advertiserId():String { return _advertiserId; }
	}
}