/**
 * Created by Maxime on 15/12/15.
 */
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	import flash.filesystem.File;
	
	public class AvatarLocalFileData
	{
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
		
		public function AvatarLocalFileData(file:File, fileType:String)
		{
			_file = file;
			_fileNameWithExtension = _file.url.split("/").pop();
			_fileType = fileType;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Getters
		
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
			_file = null;
			_fileType = null;
		}
		
	}
}