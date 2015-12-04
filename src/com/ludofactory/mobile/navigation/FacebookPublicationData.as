/**
 * Created by Maxime on 03/12/15.
 */
package com.ludofactory.mobile.navigation
{
	
	public class FacebookPublicationData
	{
		/**
		 * Title of the publication. */
		private var _title:String;
		/**
		 * Caption. */
		private var _caption:String;
		/**
		 * Description. */
		private var _description:String;
		/**
		 * Redirect link url. */
		private var _linkUrl:String;
		/**
		 * Image url. */
		private var _imageUrl:String;
		/**
		 * Extra parameters. */
		private var _extraParams:Object;
		
		public function FacebookPublicationData(title:String, caption:String, description:String, linkUrl:String = null, imageUrl:String = null, extraParams:Object = null)
		{
			_title = title;
			_caption = caption;
			_description = description;
			_linkUrl = linkUrl;
			_imageUrl = imageUrl;
			_extraParams = extraParams;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get
		
		public function get title():String { return _title; }
		public function get caption():String { return _caption; }
		public function get description():String { return _description; }
		public function get linkUrl():String { return _linkUrl; }
		public function get imageUrl():String { return _imageUrl; }
		public function get extraParams():Object { return _extraParams; }
		
	}
}