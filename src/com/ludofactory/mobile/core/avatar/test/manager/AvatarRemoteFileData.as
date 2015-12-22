/**
 * Created by Maxime on 15/12/15.
 */
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	public class AvatarRemoteFileData
	{
		/**
		 * Url of the file to download. */
		private var _url:String;
		/**
		 * Name of the file to download, without extension. */
		private var _name:String;
		/**
		 * The extracted gender name. */
		private var _genderName:String;
		/**
		 * Extension of the file to download. */
		private var _extension:String;
		/**
		 * File type.
		 * @see com.ludofactory.mobile.core.avatar.test.manager.AvatarFileType */
		private var _fileType:String;
		
		public function AvatarRemoteFileData(url:String, fileType:String)
		{
			_url = url;
			_name = url.split("?")[0].split("/").pop().split(".")[0];
			_genderName = url.split("?")[0].split("/").pop().split(".")[0].split("-")[0];
			_extension = url.split("?")[0].split("/").pop().split(".")[1];
			_fileType = fileType;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Getters
		
		/**
		 * Url of the file to download. */
		public function get url():String { return _url; }
		
		/**
		 * Name of the file to download, without extension. */
		public function get name():String { return _name; }
		
		/**
		 * The extracted gender name. */
		public function get genderName():String { return _genderName; }
		
		/**
		 * Extension of the file to download. */
		public function get extension():String { return _extension; }
		
		/**
		 * File type.
		 * @see com.ludofactory.mobile.core.avatar.test.manager.AvatarFileType */
		public function get fileType():String { return _fileType; }
		
	}
}