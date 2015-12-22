/**
 * Created by Maxime on 15/12/15.
 */
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	import flash.filesystem.File;
	
	public class AvatarLocalFileData
	{
		/**
		 * Gender id associated to the file to load. */
		private var _genderId:int;
		/**
		 * The local file. */
		private var _file:File;
		/**
		 * The file name with extension. */
		private var _fileNameWithExtension:String;
		/**
		 * File type.
		 * @see com.ludofactory.mobile.core.avatar.test.manager.AvatarFileType */
		private var _fileType:String;
		
		public function AvatarLocalFileData(genderId:int, file:File, fileType:String)
		{
			_genderId = genderId;
			_file = file;
			_fileNameWithExtension = _file.url.split("/").pop();
			_fileType = fileType;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Getters
		
		/**
		 * Gender id associated to the file to load. */
		public function get genderId():int { return _genderId; }
		
		/**
		 * The local file. */
		public function get file():File { return _file; }
		
		/**
		 * The file name with extension. */
		public function get fileNameWithExtension():String { return _fileNameWithExtension; }
		
		/**
		 * File type.
		 * @see com.ludofactory.mobile.core.avatar.test.manager.AvatarFileType */
		public function get fileType():String { return _fileType; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		public function dispose():void
		{
			_genderId = null;
			_file = null;
			_fileType = null;
		}
		
	}
}