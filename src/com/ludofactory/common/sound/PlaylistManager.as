/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 20 nov. 2013
*/
package com.ludofactory.common.sound
{
	public class PlaylistManager
	{
		/**
		 * The playlists */		
		private static var _playlists:Object = {};
		
		/**
		 * Returns a playlist whose name is passed as a parameter. If the playlist already
		 * exists, the function will simply returns its instance. Otherwise, the function
		 * will creates a new one with the name passed as a parameter.
		 * 
		 * @param playlistName Name of the playlist to get.
		 * 
		 * @return A playlist.
		 */ 
		public static function getPlaylist(playlistName):Playlist 
		{
			if( !(playlistName in _playlists) )
				_playlists[playlistName] = new Playlist(playlistName);
			
			return _playlists[playlistName];
		}
		
		/**
		 * Removes and destroys a playlist whose name is passed as parameters and deletes
		 * all the sounds that were included inside. If the playlist doesn't exists, an
		 * error is thrown.
		 * 
		 * @param playlistName Name of the playlist to remove and delete.
		 */ 
		public static function removePlaylist(playlistName:String):void
		{
			if( !(playlistName in _playlists) )
				return;
			
			Playlist(_playlists[playlistName]).dispose();
			delete _playlists[playlistName];
		}
	}
}